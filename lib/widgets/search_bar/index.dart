import 'dart:convert';
import 'dart:async'; // <--- 添加对 dart:async 的导入

import 'package:flutter/material.dart';
// import 'package:city_pickers/city_pickers.dart'; // Commented out or remove if no longer needed elsewhere
import 'package:geolocator/geolocator.dart';
import '../../pages/city_selection_page.dart'; // Import for the new city selection page
import 'package:geocoding/geocoding.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../config.dart';
import '../../pages/home/tab_search/filter_bar/data.dart' as file_data;
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

  _saveCity(file_data.GeneralType city) async {
    // 保存城市到本地存储
    ScopedModelHelper.getModel<CityModel>(context).city = city;
    var store = await Store.getInstance();
    var cityString = json.encode({'name': city.name, 'id': city.id});
    store.setString(StoreKeys.city, cityString);
    if (mounted) {
      CommonToast.showToast('城市已切换为${city.name}');
      setState(() {}); // 更新UI以显示新的城市名称
    }
  }

  Future<void> _determinePositionAndSetCity() async {
    print("_determinePositionAndSetCity: 开始执行");
    bool serviceEnabled;
    LocationPermission permission;

    try {
      print("_determinePositionAndSetCity: 检查位置服务是否启用...");
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print("_determinePositionAndSetCity: 位置服务启用状态: $serviceEnabled");
      if (!serviceEnabled) {
        CommonToast.showToast('位置服务已禁用。');
        print("_determinePositionAndSetCity: 位置服务已禁用，调用 _loadSavedCityOrDefault");
        _loadSavedCityOrDefault();
        return;
      }

      print("_determinePositionAndSetCity: 检查位置权限...");
      permission = await Geolocator.checkPermission();
      print("_determinePositionAndSetCity: 当前位置权限: $permission");

      if (permission == LocationPermission.denied) {
        print("_determinePositionAndSetCity: 位置权限被拒绝，请求权限...");
        permission = await Geolocator.requestPermission();
        print("_determinePositionAndSetCity: 请求后的位置权限: $permission");
        if (permission == LocationPermission.denied) {
          CommonToast.showToast('位置权限被拒绝。');
          print("_determinePositionAndSetCity: 权限再次被拒绝，调用 _loadSavedCityOrDefault");
          _loadSavedCityOrDefault();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        CommonToast.showToast('位置权限被永久拒绝，无法请求权限。');
        print("_determinePositionAndSetCity: 权限被永久拒绝，调用 _loadSavedCityOrDefault");
        _loadSavedCityOrDefault();
        return;
      }

      print("_determinePositionAndSetCity: 权限检查通过 ($permission)，尝试获取当前位置...");
      Position? position;
      try {
        print("_determinePositionAndSetCity: 尝试获取当前位置 (超时10秒)...");
        position = await Geolocator.getCurrentPosition(
          timeLimit: const Duration(seconds: 10), // 设置10秒超时
        );
        // geolocator 插件在成功时保证 position 不为 null，如果为 null 通常意味着 timeLimit 生效前发生了其他错误或插件内部逻辑问题
        // 但为保险起见，可以保留一个检查，尽管 timeLimit 超时会抛 TimeoutException
        if (position == null) {
           print('_determinePositionAndSetCity: getCurrentPosition 返回 null (这通常不应在成功路径发生)');
           throw Exception('未能获取到位置信息 (返回null)');
        }
        print('_determinePositionAndSetCity: 当前经纬度: ${position.latitude}, ${position.longitude}');
      } on TimeoutException catch (e, s) {
        print('_determinePositionAndSetCity: 获取当前位置超时 (10秒): $e');
        print('_determinePositionAndSetCity: 超时异常堆栈: $s');
        CommonToast.showToast('获取当前位置超时，将使用已保存或默认城市。');
        _loadSavedCityOrDefault();
        return;
      } catch (e, s) {
        print('_determinePositionAndSetCity: 调用 Geolocator.getCurrentPosition 失败: $e');
        print('_determinePositionAndSetCity: getCurrentPosition 异常堆栈: $s');
        // 尝试提取更简洁的错误信息给用户
        String errorMessage = e.toString();
        if (e is Exception) {
          // 尝试去除 "Exception: " 前缀
          errorMessage = errorMessage.replaceFirst(RegExp(r'^Exception: '), '');
        } else if (e is Error) {
           errorMessage = errorMessage.replaceFirst(RegExp(r'^Error: '), '');
        }
        CommonToast.showToast('无法获取当前位置: $errorMessage');
        _loadSavedCityOrDefault();
        return;
      }
      
      print("_determinePositionAndSetCity: 尝试进行反向地理编码...");
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      print('_determinePositionAndSetCity: 反向地理编码结果 placemarks isNotEmpty: ${placemarks.isNotEmpty}');

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        String? cityName = place.locality;
        String? street = place.street;
        String? subLocality = place.subLocality;
        String? administrativeArea = place.administrativeArea; // 省或直辖市
        print('_determinePositionAndSetCity: 反向地理编码详细结果: $place');
        print('_determinePositionAndSetCity: 获取到的城市名 (locality): $cityName, 街道 (street): $street, 区 (subLocality): $subLocality, 省/直辖市 (administrativeArea): $administrativeArea');

        String? finalCityNameForSave;
        String? cityIdForSave;

        if (cityName != null && cityName.isNotEmpty) {
          finalCityNameForSave = cityName;
        } else if (administrativeArea != null && administrativeArea.isNotEmpty) {
          // 如果 locality 为空，但 administrativeArea 存在 (例如某些情况下，直辖市可能 locality 为空)
          finalCityNameForSave = administrativeArea;
          print('_determinePositionAndSetCity: locality 为空，使用 administrativeArea: $finalCityNameForSave');
        }

        if (finalCityNameForSave != null) {
          // 优先使用 administrativeArea 作为城市名，如果它看起来更像一个城市并且与 locality 不同
          // (例如 locality 是 "朝阳区", administrativeArea 是 "北京市")
          if (administrativeArea != null &&
              administrativeArea.isNotEmpty &&
              administrativeArea.endsWith('市') && // 确保是 xx市
              finalCityNameForSave != administrativeArea && // 确保不重复
              !finalCityNameForSave.startsWith(administrativeArea.replaceAll('市', '')) // 避免 "北京市北京"
              ) {
            // 进一步判断，如果 locality 只是 administrativeArea 的一部分 (如区名)
            if (administrativeArea.contains(finalCityNameForSave) && finalCityNameForSave.length < administrativeArea.length) {
                 print('_determinePositionAndSetCity: administrativeArea ($administrativeArea) 看起来更像城市名，覆盖 locality ($finalCityNameForSave)');
                 finalCityNameForSave = administrativeArea;
            } else if (!finalCityNameForSave.contains(administrativeArea) && !administrativeArea.contains(finalCityNameForSave)) {
                 // 如果两者不互相包含，且 administrativeArea 是城市，也优先用它
                 print('_determinePositionAndSetCity: administrativeArea ($administrativeArea) 与 locality ($finalCityNameForSave) 不包含，优先使用 administrativeArea');
                 finalCityNameForSave = administrativeArea;
            }
          }
          
          // 去除末尾的“市”字，除非是单字城市名
          String processedCityName = finalCityNameForSave;
          if (processedCityName.endsWith('市') && processedCityName.length > 1) {
            processedCityName = processedCityName.substring(0, processedCityName.length - 1);
          }
          cityIdForSave = processedCityName; // ID 使用处理后的城市名

          print('_determinePositionAndSetCity: 最终用于保存的城市名: $processedCityName, ID: $cityIdForSave');
          _saveCity(file_data.GeneralType(processedCityName, cityIdForSave));
        } else {
          CommonToast.showToast('无法获取有效城市名称，已切换到默认城市。');
          print('_determinePositionAndSetCity: 无法获取有效城市名称 (finalCityNameForSave is null)，使用默认城市');
          if (Config.availableCitys.isNotEmpty) {
            _saveCity(Config.availableCitys.first);
          } else {
            print("_determinePositionAndSetCity: 错误：无法设置默认城市，因为 Config.availableCitys 为空。");
          }
        }
      } else {
        CommonToast.showToast('无法通过坐标获取位置信息 (placemarks为空)，已切换到默认城市。');
        print('_determinePositionAndSetCity: 无法通过坐标获取位置信息 (placemarks为空)，使用默认城市');
        if (Config.availableCitys.isNotEmpty) {
          _saveCity(Config.availableCitys.first);
        } else {
            print("_determinePositionAndSetCity: 错误：无法设置默认城市，因为 Config.availableCitys 为空。");
        }
      }
    } catch (e, s) {
      CommonToast.showToast('获取位置失败: $e');
      print('_determinePositionAndSetCity: 获取位置或反向地理编码失败: $e');
      print('_determinePositionAndSetCity: 异常堆栈: $s');
      _loadSavedCityOrDefault();
    }
    print("_determinePositionAndSetCity: 执行完毕");
  }

  // 选择城市
  _changeLocation() async {
    // Navigate to the new CitySelectionPage
    final selectedCity = await Navigator.push<file_data.GeneralType>(
      context,
      MaterialPageRoute(builder: (context) => const CitySelectionPage()),
    );

    if (selectedCity != null) {
      // We have a city selected from our new page
      // The existing _saveCity method can be reused.
      print('手动选择的城市 (来自新页面): ${selectedCity.name}, 使用的ID: ${selectedCity.id}');
      _saveCity(selectedCity);
    } else {
      // User might have backed out of CitySelectionPage without choosing
      print('未从新页面选择城市。');
    }
  }

  _loadSavedCityOrDefault() async {
    var store = await Store.getInstance();
    var cityString = await store.getString(StoreKeys.city);
    CityModel cityModel = ScopedModelHelper.getModel<CityModel>(context);
    if (cityString != null) {
      print("从本地存储加载城市: $cityString");
      var jsonData = json.decode(cityString);
      var city = file_data.GeneralType(jsonData['name'], jsonData['id']);
      cityModel.city = city; // 这会触发 CityModel 中的 notifyListeners
    } else {
      print("本地存储中未找到城市，设置默认城市。");
      if (Config.availableCitys.isNotEmpty) {
        // 创建一个默认城市
        cityModel.city = file_data.GeneralType('北京市', '北京市'); // 设置默认城市
      } else {
        print("警告: Config.availableCitys 为空，无法设置默认城市。");
        // 在这种情况下，cityModel.city 将保持 null，UI会显示 "定位中..."
      }
    }
    // ScopedModelDescendant 会监听 CityModel 的变化，所以这里通常不需要显式调用 setState 来更新 SearchBar 自身因城市文本变化的部分。
    // 但如果 cityModel.city 初始为 null (例如 Config.availableCitys 也为空)，确保UI能正确显示 "定位中..."
    if (mounted && cityModel.city == null) {
        // 如果 cityModel.city 仍然是 null (例如 availableCitys 为空),
        // cityNameOrDefault 会返回 '定位中...'，ScopedModelDescendant 会处理。
        // 但为了确保 SearchBar 自身在某些复杂情况下也能响应 cityModel 初始为 null 的状态，可以保留一个 setState。
        // 不过，更标准的做法是依赖 ScopedModel 的更新机制。
        // 为减少不必要的 setState 调用，此处暂时注释掉，依赖 CityModel 的 notifyListeners。
        // setState(() {});
        print("_loadSavedCityOrDefault 完成后, cityModel.city is null");
    } else if (mounted) {
        print("_loadSavedCityOrDefault 完成后, cityModel.city is ${cityModel.city?.name}");
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
    var currentCity = ScopedModelHelper.getModel<CityModel>(context).city; // city is now nullable
    // 如果没有已保存的城市 (currentCity is null after _loadSavedCityOrDefault)
    // 或者已保存的城市是默认城市，则尝试获取真实位置
    if (currentCity == null || (Config.availableCitys.isNotEmpty && currentCity.id == Config.availableCitys.first.id)) {
       print("当前城市为空 (${currentCity?.name}) 或为默认城市，尝试获取真实定位...");
       await _determinePositionAndSetCity();
    } else if (currentCity != null) {
       print("已加载到已保存的城市: ${currentCity.name}, 无需自动定位。");
    } else {
       print("Config.availableCitys 为空且无已保存城市，尝试获取真实定位..."); // 覆盖 availableCitys 为空的情况
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
                        // print("SearchBar build: CityModel.cityNameOrDefault is ${model.cityNameOrDefault}"); // 日志确认UI更新
                        return Text(
                          model.cityNameOrDefault,
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
                  if (widget.onSearch != null) {
                    widget.onSearch!();
                  } else if (widget.onSearchSubmit != null) {
                    // 如果是可提交的搜索框 (如在搜索结果页)，点击时聚焦
                    FocusScope.of(context).requestFocus(_focus);
                  } else {
                    // 其他情况 (如首页的搜索框，点击会导航)，则取消焦点
                    _focus.unfocus();
                  }
                },
                onSubmitted: (String value) { // 确保 onSubmitted 回调拿到值
                  if (widget.onSearchSubmit != null) {
                    widget.onSearchSubmit!(value);
                  }
                },
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
