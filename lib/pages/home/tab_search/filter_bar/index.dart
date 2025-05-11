import 'dart:async';

import 'package:flutter/material.dart';
// Add alias for data import to avoid naming conflicts with class members
import 'package:hook_up_rent/pages/home/tab_search/filter_bar/data.dart' as file_data;
import 'package:hook_up_rent/pages/home/tab_search/filter_bar/item.dart';
import 'package:hook_up_rent/pages/utils/common_picker/index.dart';
import 'package:hook_up_rent/pages/utils/scoped_model_helper.dart';
import 'package:hook_up_rent/scoped_model/city.dart'; // 导入 CityModel
import 'package:hook_up_rent/scoped_model/room_filter.dart';

class FilterBar extends StatefulWidget {
  final ValueChanged<file_data.FilterBarResult>? onChange;

  const FilterBar({super.key, this.onChange});

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  List<file_data.GeneralType> areaList = [file_data.GeneralType('不限', 'area_any')]; // 初始的 areaList，主要用于 initState
  List<file_data.GeneralType> priceList = [];
  List<file_data.GeneralType> rentTypeList = [];
  List<file_data.GeneralType> roomTypeList = [];
  List<file_data.GeneralType> orientedList = [];
  List<file_data.GeneralType> floorList = [];

  // 用于 CommonPicker 的动态区域选项列表
  List<file_data.GeneralType> _dynamicAreaOptionsForPicker = [file_data.GeneralType('不限', 'area_any')];


  bool isAreaActive = false;
  bool isRentTypeActive = false;
  bool isPriceActive = false;
  bool isFilterActive = false;

  String areaId = 'area_any';
  String rentTypeId = 'rent_type_any';
  String priceId = 'price_any';
  List<String> moreIds = [];

  String _areaTitle = '区域';
  String _rentTypeTitle = '方式';
  String _priceTitle = '租金';
  // "筛选" 标题通常是固定的

  // 辅助函数：移除城市名称末尾的 "市" 字
  String _normalizeCityName(String cityName) {
    if (cityName.endsWith('市')) {
      return cityName.substring(0, cityName.length - 1);
    }
    return cityName;
  }

  _onAreaChange(context) {
    final cityModel = ScopedModelHelper.getModel<CityModel>(context);
    String? currentCityNameFromModel = cityModel.city?.name;

    // List<file_data.GeneralType> dynamicAreaOptions; // 用于 CommonPicker 的选项
    // 使用 _dynamicAreaOptionsForPicker 成员变量

    if (currentCityNameFromModel != null && currentCityNameFromModel != '定位中...') {
      String normalizedCurrentCity = _normalizeCityName(currentCityNameFromModel);
      try {
        var cityInfo = file_data.cityAreaListData.firstWhere(
          (cityData) => _normalizeCityName(cityData.cityName) == normalizedCurrentCity,
        );
        if (cityInfo.districts.isNotEmpty) {
          _dynamicAreaOptionsForPicker = List<file_data.GeneralType>.from(cityInfo.districts);
        } else {
          _dynamicAreaOptionsForPicker = [file_data.GeneralType('不限', '${normalizedCurrentCity}_area_any')];
        }
      } catch (e) {
        print('City not found in cityAreaListData: $currentCityNameFromModel (normalized: $normalizedCurrentCity). Error: $e');
        _dynamicAreaOptionsForPicker = [file_data.GeneralType('不限', 'area_any')];
      }
    } else {
      _dynamicAreaOptionsForPicker = [file_data.GeneralType('不限', 'area_any')];
    }
    
    if (_dynamicAreaOptionsForPicker.isEmpty) {
        _dynamicAreaOptionsForPicker = [file_data.GeneralType('不限', 'area_any')];
    }

    // 找到当前 areaId 在 _dynamicAreaOptionsForPicker 中的索引
    int initialIndex = _dynamicAreaOptionsForPicker.indexWhere((item) => item.id == areaId);
    if (initialIndex == -1) initialIndex = 0; // 如果找不到，默认第一个


    setState(() {
      isAreaActive = true;
    });

    var result = CommonPicker.showPicker(
      value: initialIndex, // 使用计算出的初始索引
      context: context,
      options: _dynamicAreaOptionsForPicker.map((item) => item.name).toList(),
    );

    if (result == null) {
       if (mounted) { setState(() { isAreaActive = false; }); }
       return;
    }

    result.then((index) {
      if (index == null) {
        if (mounted) { setState(() { isAreaActive = false; }); }
        return;
      }
      if (mounted) {
        setState(() {
          areaId = _dynamicAreaOptionsForPicker[index].id;
          _updateTitles(); // 更新标题
        });
      }
      _onChange();
    }).whenComplete(() {
      if (mounted) {
        setState(() {
          isAreaActive = false;
        });
      }
    });
  }

  _onRentTypeChange(context) {
    setState(() {
      isRentTypeActive = true;
    });

    // 找到当前 rentTypeId 在 rentTypeList 中的索引
    int initialIndex = rentTypeList.indexWhere((item) => item.id == rentTypeId);
    if (initialIndex == -1) initialIndex = 0;

    var result = CommonPicker.showPicker(
      value: initialIndex,
      context: context,
      options: rentTypeList.map((item) => item.name).toList(),
    );

     if (result == null) {
       if (mounted) { setState(() { isRentTypeActive = false; }); }
       return;
    }

    result.then((index) {
      if (index == null) {
         if (mounted) { setState(() { isRentTypeActive = false; }); }
        return;
      }
      if (mounted) {
        setState(() {
          rentTypeId = rentTypeList[index].id;
          _updateTitles(); // 更新标题
        });
      }
      _onChange();
    }).whenComplete(() {
      if (mounted) {
        setState(() {
          isRentTypeActive = false;
        });
      }
    });
  }

  _onPriceChange(context) {
    setState(() {
      isPriceActive = true;
    });

    // 找到当前 priceId 在 priceList 中的索引
    int initialIndex = priceList.indexWhere((item) => item.id == priceId);
    if (initialIndex == -1) initialIndex = 0;


    var result = CommonPicker.showPicker(
        value: initialIndex,
        context: context,
        options: priceList.map((item) => item.name).toList());

    if (result == null) {
       if (mounted) { setState(() { isPriceActive = false; }); }
       return;
    }

    result.then((index) {
      if (index == null) {
        if (mounted) { setState(() { isPriceActive = false; }); }
        return;
      }
      if (mounted) {
        setState(() {
          priceId = priceList[index].id;
          _updateTitles(); // 更新标题
        });
      }
      _onChange();
    }).whenComplete(() {
      if (mounted) {
        setState(() {
          isPriceActive = false;
        });
      }
    });
  }

  _onFilterChange(context) {
    Scaffold.of(context).openEndDrawer();
  }

  _onChange() {
    var selectedList =
        ScopedModelHelper.getModel<FilterBarModel>(context).selectedList;
    if (widget.onChange != null) {
      widget.onChange!(
        file_data.FilterBarResult(
          areaId: areaId,
          rentTypeId: rentTypeId,
          priceId: priceId,
          moreIds: selectedList.toList(),
        ),
      );
    }
  }

  _getData() {
    Map<String, List<file_data.GeneralType>> dataList = <String, List<file_data.GeneralType>>{};
    dataList['roomTypeList'] = roomTypeList;
    dataList['orientedList'] = orientedList;
    dataList['floorList'] = floorList;

    ScopedModelHelper.getModel<FilterBarModel>(context).dataList = dataList;
  }

  void _updateTitles() {
    // 更新区域标题
    // 注意: _dynamicAreaOptionsForPicker 可能在 _onAreaChange 之前未完全根据当前城市初始化。
    // 但 initState 中会调用 _updateTitles，此时 _dynamicAreaOptionsForPicker 还是初始值。
    // _onAreaChange 内部会更新 _dynamicAreaOptionsForPicker 并再次调用 _updateTitles。
    var area = _dynamicAreaOptionsForPicker.firstWhere((item) => item.id == areaId, orElse: () => _dynamicAreaOptionsForPicker.isNotEmpty ? _dynamicAreaOptionsForPicker[0] : file_data.GeneralType('区域', 'area_any'));
    _areaTitle = (areaId == 'area_any' || area.name == '不限') ? '区域' : area.name;


    var rentType = rentTypeList.firstWhere((item) => item.id == rentTypeId, orElse: () => rentTypeList.isNotEmpty ? rentTypeList[0] : file_data.GeneralType('方式', 'rent_type_any'));
    _rentTypeTitle = (rentTypeId == 'rent_type_any' || rentType.name == '不限') ? '方式' : rentType.name;

    var price = priceList.firstWhere((item) => item.id == priceId, orElse: () => priceList.isNotEmpty ? priceList[0] : file_data.GeneralType('租金', 'price_any'));
    _priceTitle = (priceId == 'price_any' || price.name == '不限') ? '租金' : price.name;
  }

  @override
  void initState() {
    super.initState();
    
    priceList = file_data.priceList;
    rentTypeList = file_data.rentTypeList;
    roomTypeList = file_data.roomTypeList;
    orientedList = file_data.orientedList;
    floorList = file_data.floorList;
    
    // 初始化 _dynamicAreaOptionsForPicker 为通用不限，_onAreaChange 会根据城市更新它
    _dynamicAreaOptionsForPicker = [file_data.GeneralType('不限', 'area_any')];


    // areaId 的初始值依赖 areaList，areaList 的初始值是 [GeneralType('不限', 'area_any')]
    // 这是合理的，因为在用户首次与区域筛选交互前，它应该代表“不限区域”
    areaId = _dynamicAreaOptionsForPicker.isNotEmpty ? _dynamicAreaOptionsForPicker[0].id : 'area_any';
    rentTypeId = rentTypeList.isNotEmpty ? rentTypeList[0].id : 'rent_type_any';
    priceId = priceList.isNotEmpty ? priceList[0].id : 'price_any';
    
    _updateTitles(); // 初始化标题
    Timer.run(_getData);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 51,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Item(
            title: _areaTitle, // 使用动态标题
            isActive: isAreaActive,
            onTap: _onAreaChange,
          ),
          Item(
            title: _rentTypeTitle, // 使用动态标题
            isActive: isRentTypeActive,
            onTap: _onRentTypeChange,
          ),
          Item(
            title: _priceTitle, // 使用动态标题
            isActive: isPriceActive,
            onTap: _onPriceChange,
          ),
          Item(
            title: '筛选', // 筛选标题通常固定
            isActive: isFilterActive,
            onTap: _onFilterChange,
          ),
        ],
      ),
    );
  }
}
