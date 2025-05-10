import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:city_pickers/city_pickers.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../config.dart';
import '../../models/general_type.dart';
import '../../pages/utils/common_toast.dart';
import '../../pages/utils/scoped_model_helper.dart';
import '../../pages/utils/store.dart';
import '../../scoped_model/city.dart';
import '../common_image.dart';

class SearchBar extends StatefulWidget {
  final bool? showLocation; //是否显示位置
  final Function? goBackCallback; //回退
  final String? inputValue; //搜索框值
  final String defaultInputValue; //默认显示值
  final Function? onCancel; //取消按钮
  final bool? showMap; //是否显示地图按钮
  final Function? onSearch; //点击搜索框触发
  final ValueChanged<String>? onSearchSubmit; // 点击回车触发

  const SearchBar(
      {super.key,
      this.showLocation,
      this.goBackCallback,
      this.inputValue = '',
      this.defaultInputValue = '请输入搜索词',
      this.onCancel,
      this.showMap,
      this.onSearch,
      this.onSearchSubmit});

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  String _searchWord = '';
  late TextEditingController _controller;
  late FocusNode _focus; // 焦点对象

  void _onClean() {
    setState(() {
      _controller.clear();
      _searchWord = '';
    });
  }

  _saveCity(GeneralType city) async {
    // 保存城市到本地存储
    ScopedModelHelper.getModel<CityModel>(context).city = city;
    var store = await Store.getInstance();
    var cityString = json.encode(city.toJson());
    store.setString(StoreKeys.city, cityString);
    if (mounted) {
      CommonToast.showToast('城市已切换为${city.name}');
      setState(() {}); // 更新UI以显示新的城市名称
    }
  }

  Future<void> _determinePositionAndSetCity() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      CommonToast.showToast('位置服务已禁用。');
      _loadSavedCityOrDefault(); // 加载已保存的城市或默认城市
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        CommonToast.showToast('位置权限被拒绝。');
        _loadSavedCityOrDefault();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      CommonToast.showToast('位置权限被永久拒绝，无法请求权限。');
      _loadSavedCityOrDefault();
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      print('当前经纬度: ${position.latitude}, ${position.longitude}'); // 添加日志
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        String? cityName = place.locality; // locality 通常是城市
        String? street = place.street;
        String? subLocality = place.subLocality;
        String? administrativeArea = place.administrativeArea;
        print('反向地理编码结果: $place'); // 添加日志
        print('获取到的城市名 (locality): $cityName, 街道 (street): $street, 区 (subLocality): $subLocality, 省 (administrativeArea): $administrativeArea'); // 添加日志

        if (cityName != null && cityName.isNotEmpty) {
          // 查找配置中是否存在该城市
          var foundCity = Config.availableCitys.firstWhere(
            (city) => cityName.startsWith(city.name) || (administrativeArea != null && administrativeArea.startsWith(city.name)), // 尝试匹配省份（直辖市）
            orElse: () {
              CommonToast.showToast('当前城市 ($cityName / $administrativeArea) 尚未开通，已切换到默认城市。');
              print('城市 ($cityName / $administrativeArea) 未在 Config.availableCitys 找到，使用默认城市'); // 添加日志
              return Config.availableCitys.first; // 返回默认城市
            },
          );
          print('最终匹配到的城市: ${foundCity.name}'); // 添加日志
          _saveCity(foundCity);
        } else {
          CommonToast.showToast('无法获取城市名称 (locality为空)，已切换到默认城市。');
          print('无法获取城市名称 (locality为空)，使用默认城市'); // 添加日志
          _saveCity(Config.availableCitys.first); // 保存默认城市
        }
      } else {
        CommonToast.showToast('无法通过坐标获取位置信息 (placemarks为空)，已切换到默认城市。');
        print('无法通过坐标获取位置信息 (placemarks为空)，使用默认城市'); // 添加日志
        _saveCity(Config.availableCitys.first);
      }
    } catch (e) {
      CommonToast.showToast('获取位置失败: $e');
      print('获取位置或反向地理编码失败: $e'); // 添加日志
      _loadSavedCityOrDefault();
    }
  }

  // 选择城市
  _changeLocation() async {
    var result = await CityPickers.showCitiesSelector(
        context: context, theme: ThemeData(primaryColor: Colors.green));
    String? cityNameFromResult = result?.cityName;
    if (cityNameFromResult == null) {
      return;
    }
    var city = Config.availableCitys.firstWhere(
      (c) => cityNameFromResult.startsWith(c.name),
      orElse: () {
        CommonToast.showToast('该城市尚未开通');
        return Config.availableCitys.first;
      },
    );
    _saveCity(city);
  }

  _loadSavedCityOrDefault() async {
    var store = await Store.getInstance();
    var cityString = await store.getString(StoreKeys.city);
    if (cityString != null) {
      var city = GeneralType.fromJson(json.decode(cityString));
      ScopedModelHelper.getModel<CityModel>(context).city = city;
      if (mounted) setState(() {});
    } else {
      // 如果没有保存的城市，则设置一个默认城市
      _saveCity(Config.availableCitys.first);
    }
  }


  @override
  void initState() {
    super.initState();
    _focus = FocusNode();
    _controller = TextEditingController(text: widget.inputValue);
    _getCityThenDeterminePosition();
  }

  _getCityThenDeterminePosition() async {
    await _loadSavedCityOrDefault(); // 先尝试加载已保存的城市
    // 如果 CityModel 中的城市仍然是默认的或者空的，再尝试获取真实位置
    var currentCity = ScopedModelHelper.getModel<CityModel>(context).city;
    if (currentCity == null || currentCity.id == Config.availableCitys.first.id) {
       await _determinePositionAndSetCity();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          // 是否显示位置
          if (widget.showLocation ?? false) // 默认为 false
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () {
                  _changeLocation();
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.room,
                      color: Colors.green,
                      size: 14,
                    ),
                    ScopedModelDescendant<CityModel>(
                      builder: (context, child, model) {
                        return Text(
                          model.city?.name ?? '定位中...', // 从CityModel获取城市名称
                          style: const TextStyle(color: Colors.black, fontSize: 14),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          // 返回按钮
          if (widget.goBackCallback != null)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: (widget.goBackCallback ?? () {})
                    as GestureTapCallback, // 强转
                child: const Icon(
                  Icons.chevron_left,
                  color: Colors.black87,
                ),
              ),
            ),
          // 弹性输入框
          Expanded(
            child: Container(
              height: 34,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17),
                color: Colors.grey[200],
              ),
              child: TextField(
                controller: _controller, // 控制正在编辑的文档
                focusNode: _focus, // 控制焦点
                onTap: () {
                  if (widget.onSearchSubmit == null) {
                    _focus.unfocus(); // 不是搜索页则失去焦点
                  }
                  if (widget.onSearch != null) {
                    widget.onSearch!();
                  }
                },
                onSubmitted: widget.onSearchSubmit,
                textInputAction: TextInputAction.search, // 键盘回车文本
                onChanged: (value) {
                  setState(() => _searchWord = value);
                },
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.only(top: 1, left: -10), // 负数
                  border: InputBorder.none,
                  hintText: '请输入搜索词',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  suffixIcon: GestureDetector(
                    onTap: () => _onClean(),
                    child: Icon(
                      Icons.clear,
                      size: 18,
                      color: _searchWord == '' ? Colors.grey[200] : Colors.grey,
                    ),
                  ),
                  icon: const Padding(
                    padding: EdgeInsets.only(left: 10, top: 2),
                    child: Icon(
                      Icons.search,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 取消按钮
          if (widget.onCancel != null)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: (widget.onCancel ?? () {}) as GestureTapCallback,
                child: const Text(
                  '取消',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          // 显示地图
          if (widget.showMap ?? false)
            const CommonImage(
              'static/icons/widget_search_bar_map.png',
              width: 40,
              height: 40,
            ),
        ],
      ),
    );
  }
}
