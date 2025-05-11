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
  List<file_data.GeneralType> areaList = [file_data.GeneralType('不限', 'area_any')];
  List<file_data.GeneralType> priceList = [];
  List<file_data.GeneralType> rentTypeList = [];
  List<file_data.GeneralType> roomTypeList = [];
  List<file_data.GeneralType> orientedList = [];
  List<file_data.GeneralType> floorList = [];

  bool isAreaActive = false;
  bool isRentTypeActive = false;
  bool isPriceActive = false;
  bool isFilterActive = false;

  String areaId = 'area_any';
  String rentTypeId = 'rent_type_any';
  String priceId = 'price_any';
  List<String> moreIds = [];

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

    List<file_data.GeneralType> dynamicAreaList = [
      file_data.GeneralType('不限', 'area_any')
    ];

    if (currentCityNameFromModel != null && currentCityNameFromModel != '定位中...') {
      String normalizedCurrentCity = _normalizeCityName(currentCityNameFromModel);
      try {
        var cityInfo = file_data.cityAreaListData.firstWhere(
          (cityData) => _normalizeCityName(cityData.cityName) == normalizedCurrentCity,
        );
        if (cityInfo.districts.isNotEmpty) {
          dynamicAreaList.addAll(cityInfo.districts);
        }
      } catch (e) {
        print('City not found or no districts for: $currentCityNameFromModel (normalized: $normalizedCurrentCity). Error: $e');
      }
    }
    
    setState(() {
      isAreaActive = true;
    });

    var result = CommonPicker.showPicker(
      value: 0,
      context: context,
      options: dynamicAreaList.map((item) => item.name).toList(),
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
          areaId = dynamicAreaList[index].id;
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

    var result = CommonPicker.showPicker(
      value: 0,
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
    var result = CommonPicker.showPicker(
        value: 0,
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

  @override
  void initState() {
    super.initState(); 
    
    priceList = file_data.priceList;
    rentTypeList = file_data.rentTypeList;
    roomTypeList = file_data.roomTypeList;
    orientedList = file_data.orientedList;
    floorList = file_data.floorList;

    areaId = areaList.isNotEmpty ? areaList[0].id : 'area_any';
    rentTypeId = rentTypeList.isNotEmpty ? rentTypeList[0].id : 'rent_type_any';
    priceId = priceList.isNotEmpty ? priceList[0].id : 'price_any';

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
            title: '区域',
            isActive: isAreaActive,
            onTap: _onAreaChange,
          ),
          Item(
            title: '方式',
            isActive: isRentTypeActive,
            onTap: _onRentTypeChange,
          ),
          Item(
            title: '租金',
            isActive: isPriceActive,
            onTap: _onPriceChange,
          ),
          Item(
            title: '筛选',
            isActive: isFilterActive,
            onTap: _onFilterChange,
          ),
        ],
      ),
    );
  }
}
