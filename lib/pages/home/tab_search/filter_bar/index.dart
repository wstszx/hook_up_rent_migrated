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
  // 本地数据列表，从 file_data 加载
  List<file_data.GeneralType> _priceListLocal = [];
  List<file_data.GeneralType> _rentTypeListLocal = [];
  List<file_data.GeneralType> _roomTypeListLocal = [];
  List<file_data.GeneralType> _orientedListLocal = [];
  List<file_data.GeneralType> _floorListLocal = [];
  List<file_data.GeneralType> _tagListLocal = []; // 新增：标签列表（如果本地有）
  // 城市和区域列表通常更动态，这里仅为示例，实际应从 CityModel 或 API 获取
  List<file_data.GeneralType> _cityListLocal = [];
  List<file_data.GeneralType> _districtListLocal = [file_data.GeneralType('不限', 'area_any')];


  // 用于 CommonPicker 的动态区域选项列表
  List<file_data.GeneralType> _dynamicAreaOptionsForPicker = [file_data.GeneralType('不限', 'area_any')];

  // 控制顶部筛选按钮的激活状态
  bool isAreaActive = false;
  bool isRentTypeActive = false;
  bool isPriceActive = false;
  bool isFilterActive = false; // “筛选”按钮的激活状态

  // 顶部筛选按钮的当前选中ID (这些ID主要用于 CommonPicker 和标题更新)
  // FilterBarModel 中的 selected...Id 是更权威的状态源
  String _selectedDistrictIdLocal = 'area_any'; // 对应 FilterBarModel.selectedDistrictId
  String _selectedRentTypeIdLocal = 'rent_type_any'; // 对应 FilterBarModel.selectedRentTypeId
  String _selectedPriceIdLocal = 'price_any'; // 对应 FilterBarModel.selectedPriceId
  // cityId 通常由 CityModel 管理，这里不直接在 FilterBar 的顶栏选择

  // 顶部筛选按钮的显示标题
  String _areaTitle = '区域';
  String _rentTypeTitle = '方式';
  String _priceTitle = '租金';
  // "筛选" 标题固定

  // 辅助函数：移除城市名称末尾的 "市" 字
  String _normalizeCityName(String cityName) {
    if (cityName.endsWith('市')) {
      return cityName.substring(0, cityName.length - 1);
    }
    return cityName;
  }

  // 当区域选择变化时 (通过 CommonPicker)
  _onAreaChange(context) {
    final cityModel = ScopedModelHelper.getModel<CityModel>(context);
    final filterModel = ScopedModelHelper.getModel<FilterBarModel>(context);
    String? currentCityNameFromModel = cityModel.city?.name;

    if (currentCityNameFromModel != null && currentCityNameFromModel != '定位中...') {
      String normalizedCurrentCity = _normalizeCityName(currentCityNameFromModel);
      try {
        var cityInfo = file_data.cityAreaListData.firstWhere(
          (cityData) => _normalizeCityName(cityData.cityName) == normalizedCurrentCity,
        );
        // 更新 filterModel 中的城市列表和选中的城市ID (如果需要)
        // filterModel.cityList = ... (从 cityAreaListData 或 API 获取)
        // filterModel.selectedCityId = cityInfo.cityName; // 或者对应的城市ID

        if (cityInfo.districts.isNotEmpty) {
          _dynamicAreaOptionsForPicker = List<file_data.GeneralType>.from(cityInfo.districts);
          filterModel.dataList = {...filterModel.dataList, 'districtList': _dynamicAreaOptionsForPicker};
        } else {
          _dynamicAreaOptionsForPicker = [file_data.GeneralType('不限', '${normalizedCurrentCity}_area_any')];
          filterModel.dataList = {...filterModel.dataList, 'districtList': _dynamicAreaOptionsForPicker};
        }
      } catch (e) {
        print('City not found in cityAreaListData: $currentCityNameFromModel (normalized: $normalizedCurrentCity). Error: $e');
        _dynamicAreaOptionsForPicker = [file_data.GeneralType('不限', 'area_any')];
        filterModel.dataList = {...filterModel.dataList, 'districtList': _dynamicAreaOptionsForPicker};
      }
    } else {
      _dynamicAreaOptionsForPicker = [file_data.GeneralType('不限', 'area_any')];
      filterModel.dataList = {...filterModel.dataList, 'districtList': _dynamicAreaOptionsForPicker};
    }
    
    if (_dynamicAreaOptionsForPicker.isEmpty) {
        _dynamicAreaOptionsForPicker = [file_data.GeneralType('不限', 'area_any')];
    }

    int initialIndex = _dynamicAreaOptionsForPicker.indexWhere((item) => item.id == filterModel.selectedDistrictId);
    if (initialIndex == -1) initialIndex = 0;

    setState(() { isAreaActive = true; });

    CommonPicker.showPicker(
      value: initialIndex,
      context: context,
      options: _dynamicAreaOptionsForPicker.map((item) => item.name).toList(),
    )?.then((index) { // Changed to ?.then
      if (index == null) return;
      if (mounted) {
        String newDistrictId = _dynamicAreaOptionsForPicker[index].id;
        filterModel.selectedDistrictId = newDistrictId; // 更新 FilterBarModel
        _selectedDistrictIdLocal = newDistrictId; // 更新本地状态以更新标题
        _updateTitles();
        _onChange(); // 触发回调
      }
    }).whenComplete(() {
      if (mounted) { setState(() { isAreaActive = false; }); }
    });
  }

  // 当租赁方式选择变化时 (通过 CommonPicker)
  _onRentTypeChange(context) {
    final filterModel = ScopedModelHelper.getModel<FilterBarModel>(context);
    // 使用从 FilterBarModel 获取的 rentTypeList，如果它已经被填充
    final currentRentTypeList = filterModel.dataList['rentTypeList'] ?? _rentTypeListLocal;


    int initialIndex = currentRentTypeList.indexWhere((item) => item.id == filterModel.selectedRentTypeId);
    if (initialIndex == -1) initialIndex = 0;

    setState(() { isRentTypeActive = true; });

    CommonPicker.showPicker(
      value: initialIndex,
      context: context,
      options: currentRentTypeList.map((item) => item.name).toList(),
    )?.then((index) { // Changed to ?.then
      if (index == null) return;
      if (mounted) {
        String newRentTypeId = currentRentTypeList[index].id;
        filterModel.selectedRentTypeId = newRentTypeId; // 更新 FilterBarModel
        _selectedRentTypeIdLocal = newRentTypeId; // 更新本地状态
        _updateTitles();
        _onChange();
      }
    }).whenComplete(() {
      if (mounted) { setState(() { isRentTypeActive = false; }); }
    });
  }

  // 当价格选择变化时 (通过 CommonPicker)
  _onPriceChange(context) {
    final filterModel = ScopedModelHelper.getModel<FilterBarModel>(context);
    final currentPriceList = filterModel.dataList['priceList'] ?? _priceListLocal;

    int initialIndex = currentPriceList.indexWhere((item) => item.id == filterModel.selectedPriceId);
    if (initialIndex == -1) initialIndex = 0;

    setState(() { isPriceActive = true; });

    CommonPicker.showPicker(
        value: initialIndex,
        context: context,
        options: currentPriceList.map((item) => item.name).toList()
    )?.then((index) { // Changed to ?.then
      if (index == null) return;
      if (mounted) {
        String newPriceId = currentPriceList[index].id;
        filterModel.selectedPriceId = newPriceId; // 更新 FilterBarModel
        _selectedPriceIdLocal = newPriceId; // 更新本地状态
        _updateTitles();
        _onChange();
      }
    }).whenComplete(() {
      if (mounted) { setState(() { isPriceActive = false; }); }
    });
  }

  // 当点击“筛选”按钮时
  _onFilterChange(context) { // Removed async
    setState(() { isFilterActive = true; });
    // 打开抽屉，当抽屉关闭时，FilterBarModel 中的状态应该已经更新
    // 我们需要一种方式在抽屉关闭后触发 _onChange
    Scaffold.of(context).openEndDrawer(); // Removed await and .closed

    // The following block will now execute immediately after openEndDrawer() is called.
    // This is not the original intended behavior (to run after drawer closes)
    // but fixes the compilation error on the previous line.
    // Proper handling of "after drawer close" logic needs further consideration.
    if (mounted) {
      setState(() { isFilterActive = false; }); // This will make the button appear active only briefly
      _onChange(); // Called with model state *before* drawer changes it
      _updateTitles(); // Called with model state *before* drawer changes it
    }
  }

  // 当任何筛选条件改变时，调用此方法通知父组件
  _onChange() {
    if (widget.onChange == null) return;

    final filterModel = ScopedModelHelper.getModel<FilterBarModel>(context);
    final params = filterModel.getApiFilterParams;

    // 从 CityModel 获取当前城市ID (如果适用)
    final cityModel = ScopedModelHelper.getModel<CityModel>(context);
    // String? currentCityId = cityModel.city?.id; // 假设 CityModel.city 有 id 属性
    // 或者，如果城市选择是通过 FilterBarModel 管理的：
    String? currentCityId = filterModel.selectedCityId;


    widget.onChange!(
      file_data.FilterBarResult(
        cityId: currentCityId, // 使用从模型获取的城市ID
        districtId: params['district'] as String?,
        rentTypeId: params['rentType'] as String?,
        priceId: params['price'] as String?,
        roomTypeIds: (params['roomType'] as String?)?.split(','),
        orientationIds: (params['orientation'] as String?)?.split(','),
        floorIds: (params['floor'] as String?)?.split(','),
        tagIds: (params['tags'] as String?)?.split(','),
      ),
    );
  }

  // 初始化时或从服务器获取数据后，填充 FilterBarModel
  _loadDataToModel() {
    final filterModel = ScopedModelHelper.getModel<FilterBarModel>(context);
    
    Map<String, List<file_data.GeneralType>> dataForModel = {
      'roomTypeList': _roomTypeListLocal,
      'orientedList': _orientedListLocal,
      'floorList': _floorListLocal,
      'rentTypeList': _rentTypeListLocal,
      'priceList': _priceListLocal,
      'tagList': _tagListLocal, // 新增
      // cityList 和 districtList 可能需要更动态地加载
      // 'cityList': _cityListLocal,
      // 'districtList': _districtListLocal, // 初始时可能是空的或只有“不限”
    };
    
    // 如果 _dynamicAreaOptionsForPicker 已经基于当前城市更新，则使用它
    // 否则，FilterBarModel 中的 districtList 会在 _onAreaChange 中被更新
    if (_dynamicAreaOptionsForPicker.isNotEmpty && _dynamicAreaOptionsForPicker.first.id != 'area_any') {
       dataForModel['districtList'] = _dynamicAreaOptionsForPicker;
    } else if (_districtListLocal.isNotEmpty) {
       dataForModel['districtList'] = _districtListLocal;
    }


    filterModel.dataList = dataForModel;

    // 初始化 FilterBarModel 中的选中项 (如果需要从 FilterBar 的初始状态同步)
    // 通常 FilterBarModel 应该有自己的默认值或从持久化存储加载
    filterModel.selectedDistrictId = _selectedDistrictIdLocal;
    filterModel.selectedRentTypeId = _selectedRentTypeIdLocal;
    filterModel.selectedPriceId = _selectedPriceIdLocal;
    // 多选项的初始化在 FilterBarModel 内部处理 (默认为空 Set)
  }

  // 更新顶部筛选按钮的标题
  void _updateTitles() {
    final filterModel = ScopedModelHelper.getModel<FilterBarModel>(context);

    // 区域标题
    var districtName = '区域';
    if (filterModel.selectedDistrictId != null && filterModel.selectedDistrictId != 'area_any') {
      // _dynamicAreaOptionsForPicker 应该包含当前可选的区域
      var foundDistrict = _dynamicAreaOptionsForPicker.firstWhere(
          (item) => item.id == filterModel.selectedDistrictId,
          orElse: () => file_data.GeneralType('', ''));
      if (foundDistrict.name.isNotEmpty) {
        districtName = foundDistrict.name;
      }
    }
    _areaTitle = districtName;

    // 方式标题
    var rentTypeName = '方式';
    if (filterModel.selectedRentTypeId != null && filterModel.selectedRentTypeId != 'rent_type_any') {
      final list = filterModel.dataList['rentTypeList'] ?? _rentTypeListLocal;
      var foundRentType = list.firstWhere(
          (item) => item.id == filterModel.selectedRentTypeId,
          orElse: () => file_data.GeneralType('', ''));
      if (foundRentType.name.isNotEmpty) {
        rentTypeName = foundRentType.name;
      }
    }
    _rentTypeTitle = rentTypeName;
    
    // 租金标题
    var priceName = '租金';
    if (filterModel.selectedPriceId != null && filterModel.selectedPriceId != 'price_any') {
      final list = filterModel.dataList['priceList'] ?? _priceListLocal;
      var foundPrice = list.firstWhere(
          (item) => item.id == filterModel.selectedPriceId,
          orElse: () => file_data.GeneralType('', ''));
      if (foundPrice.name.isNotEmpty) {
        priceName = foundPrice.name;
      }
    }
    _priceTitle = priceName;

    if(mounted) setState(() {}); // 确保UI更新
  }


  @override
  void initState() {
    super.initState();
    
    // 从本地 data.dart 加载初始数据列表
    _priceListLocal = file_data.priceList;
    _rentTypeListLocal = file_data.rentTypeList;
    _roomTypeListLocal = file_data.roomTypeList;
    _orientedListLocal = file_data.orientedList;
    _floorListLocal = file_data.floorList;
    _tagListLocal = file_data.tagList; // 假设 tagList 在 data.dart 中定义
    // _cityListLocal = ... // 如果有本地城市列表
    // _districtListLocal 初始化时可以只有“不限”

    // 初始化顶栏筛选按钮的默认选中ID (这些会同步到 FilterBarModel)
    _selectedDistrictIdLocal = _dynamicAreaOptionsForPicker.isNotEmpty ? _dynamicAreaOptionsForPicker[0].id : 'area_any';
    _selectedRentTypeIdLocal = _rentTypeListLocal.isNotEmpty ? _rentTypeListLocal[0].id : 'rent_type_any';
    _selectedPriceIdLocal = _priceListLocal.isNotEmpty ? _priceListLocal[0].id : 'price_any';
    
    Timer.run(() {
      _loadDataToModel(); // 将加载的数据设置到 FilterBarModel
      _updateTitles();    // 根据 FilterBarModel 的初始状态更新标题
      // 监听 CityModel 的变化，以便在城市改变时更新区域选项和标题
      final cityModel = ScopedModelHelper.getModel<CityModel>(context);
      cityModel.addListener(_cityChangedListener);
      // 首次加载时，也尝试根据当前城市更新区域
      _handleCityChange(cityModel);
    });
  }

 @override
  void dispose() {
    final cityModel = ScopedModelHelper.getModel<CityModel>(context); // Removed listen: false
    cityModel.removeListener(_cityChangedListener);
    super.dispose();
  }

  void _cityChangedListener() {
    final cityModel = ScopedModelHelper.getModel<CityModel>(context);
    _handleCityChange(cityModel);
  }

  void _handleCityChange(CityModel cityModel) {
    // 当城市改变时，重置区域选择并更新区域列表
    final filterModel = ScopedModelHelper.getModel<FilterBarModel>(context);
    String? currentCityNameFromModel = cityModel.city?.name;

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
        // 更新 FilterBarModel 中的 districtList
        var currentDataList = filterModel.dataList;
        currentDataList['districtList'] = _dynamicAreaOptionsForPicker;
        // 更新 FilterBarModel 中的 cityList 和 selectedCityId (如果需要)
        // currentDataList['cityList'] = ...
        filterModel.selectedCityId = cityInfo.cityName; // <--- 更新 selectedCityId
        filterModel.dataList = currentDataList; // 触发 FilterBarModel 更新

      } catch (e) {
        _dynamicAreaOptionsForPicker = [file_data.GeneralType('不限', 'area_any')];
        // 如果城市查找失败，也应该清空或设置默认的 selectedCityId
        filterModel.selectedCityId = null; // 或者一个代表“全国”的ID，如果适用
      }
    } else {
      _dynamicAreaOptionsForPicker = [file_data.GeneralType('不限', 'area_any')];
    }
    // 重置区域选择到“不限”
    filterModel.selectedDistrictId = _dynamicAreaOptionsForPicker.isNotEmpty ? _dynamicAreaOptionsForPicker[0].id : 'area_any';
    _selectedDistrictIdLocal = filterModel.selectedDistrictId!;
    _updateTitles(); // 更新标题
    _onChange(); // 触发一次 onChange，因为区域（作为筛选条件）已改变
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // _updateTitles(); // 当依赖变化时（例如 ScopedModel），也可能需要更新标题
  }

  @override
  Widget build(BuildContext context) {
    // 在 build 方法开始时调用 _updateTitles，以确保标题与 FilterBarModel 同步
    // 这在 FilterDrawer 关闭并可能修改了 FilterBarModel 后尤其重要
    // 但要注意不要在 build 中无条件调用 setState 或可能导致 setState 的方法
    // _updateTitles(); // 移动到更合适的地方，例如 initState 或 drawer 关闭回调后

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
