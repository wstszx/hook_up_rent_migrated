import 'dart:async';

import 'package:flutter/material.dart';
// Add alias for data import to avoid naming conflicts with class members
import 'package:hook_up_rent/pages/home/tab_search/filter_bar/data.dart' as file_data;
import 'package:hook_up_rent/pages/home/tab_search/filter_bar/item.dart';
import 'package:hook_up_rent/pages/utils/common_picker/index.dart';
import 'package:hook_up_rent/pages/utils/scoped_model_helper.dart';
import 'package:hook_up_rent/scoped_model/room_filter.dart';

class FilterBar extends StatefulWidget {
  final ValueChanged<file_data.FilterBarResult>? onChange;

  const FilterBar({super.key, this.onChange});

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  List<file_data.GeneralType> areaList = [];
  List<file_data.GeneralType> priceList = [];
  List<file_data.GeneralType> rentTypeList = [];
  List<file_data.GeneralType> roomTypeList = [];
  List<file_data.GeneralType> orientedList = [];
  List<file_data.GeneralType> floorList = [];
  // 搜索是否激活
  bool isAreaActive = false;
  bool isRentTypeActive = false;
  bool isPriceActive = false;
  bool isFilterActive = false;

  // 搜索内容
  String areaId = '';
  String rentTypeId = '';
  String priceId = '';
  List<String> moreIds = [];

  _onAreaChange(context) {
    setState(() {
      // 设置区域选中效果
      isAreaActive = true;
    });

    var result = CommonPicker.showPicker(
      value: 0,
      context: context,
      options: areaList.map((item) => item.name).toList(),
    );

    if (result == null) return;

    result.then((index) {
      if (index == null) return;
      setState(() {
        areaId = areaList[index].id;
      });
    }).whenComplete(() {
      setState(() {
        // 取消区域选中效果
        isAreaActive = false;
      });
    });
    _onChange();
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

    if (result == null) return;

    result.then((index) {
      if (index == null) return;
      setState(() {
        rentTypeId = rentTypeList[index].id;
      });
    }).whenComplete(() {
      setState(() {
        isRentTypeActive = false;
      });
    });
    _onChange();
  }

  _onPriceChange(context) {
    setState(() {
      isPriceActive = !isPriceActive;
    });
    var result = CommonPicker.showPicker(
        value: 0,
        context: context,
        options: priceList.map((item) => item.name).toList());

    if (result == null) return;

    result.then((index) {
      if (index == null) return;
      setState(() {
        areaId = priceList[index].id;
      });
    });
    result.whenComplete(() {
      setState(() {
        isPriceActive = false;
      });
    });
    _onChange();
  }

  _onFilterChange(context) {
    Scaffold.of(context).openEndDrawer();
  }

  // 响应给父组件
  _onChange() {
    var selectedList =
        ScopedModelHelper.getModel<FilterBarModel>(context).selectedList;
    if (widget.onChange != null) {
      widget.onChange!(
        file_data.FilterBarResult(
          areaId: areaId,
          rentTypeId: rentTypeId,
          priceId: priceId,
          moreId: moreIds,
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
    super.initState(); // It's a good practice to call super.initState() first.

    // Initialize state lists from the global lists in data.dart
    // Now the local state lists will have the correct data from the file.
    areaList = file_data.areaList;
    priceList = file_data.priceList;
    rentTypeList = file_data.rentTypeList;
    roomTypeList = file_data.roomTypeList;
    orientedList = file_data.orientedList;
    floorList = file_data.floorList;

    Timer.run(_getData); // _getData will now use the initialized lists to populate ScopedModel
  }

  @override
  void didChangeDependencies() {
    _onChange();
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
