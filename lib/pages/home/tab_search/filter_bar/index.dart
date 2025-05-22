import 'dart:async';

import 'package:flutter/material.dart';
// Add alias for data import to avoid naming conflicts with class members
import 'package:rent_share/pages/home/tab_search/filter_bar/data.dart' as file_data;
import 'package:rent_share/pages/home/tab_search/filter_bar/item.dart';
import 'package:rent_share/pages/utils/common_picker/index.dart';
import 'package:rent_share/pages/utils/scoped_model_helper.dart';
import 'package:rent_share/scoped_model/city.dart'; // 导入 CityModel
import 'package:rent_share/scoped_model/room_filter.dart';
import 'package:rent_share/pages/utils/dio_http.dart'; // <--- 引入 DioHttp
import 'package:rent_share/services/region_service.dart'; // 引入 RegionService

class FilterBar extends StatefulWidget {
  final ValueChanged<file_data.FilterBarResult>? onChange;
  final String? initialRentType; // 新增参数
  final VoidCallback? onInitialized; // 新增参数

  const FilterBar({super.key, this.onChange, this.initialRentType, this.onInitialized}); // 添加到构造函数

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  bool _isInitialized = false; // 新增标志
  FilterBarModel? _filterBarModel; // 添加 FilterBarModel 成员变量
  // 本地数据列表，部分将由API数据替代或补充
  List<file_data.GeneralType> _priceListLocal = [];
  List<file_data.GeneralType> _rentTypeListLocal = [];
  // 户型和朝向将使用本地静态数据
  // List<file_data.GeneralType> _roomTypeListFromApi = []; // No longer needed
  // List<file_data.GeneralType> _orientedListFromApi = []; // No longer needed
  List<file_data.GeneralType> _tagListLocal = [];
  // 城市和区域列表通常更动态，这里仅为示例，实际应从 CityModel 或 API 获取
  List<file_data.GeneralType> _cityListLocal = []; // 城市列表通常由API或特定模型管理
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

  // 从API加载筛选数据的方法
  Future<void> _fetchFilterOptions() async {
    try {
      var res = await DioHttp.of(context).get('/api/configurations/filter-options');
      if (res.statusCode == 200 && res.data != null) {
        Map<String, dynamic> data = res.data!;
        
        // 户型和朝向数据将从本地 data.dart 获取，不再通过 API
        // // 处理户型
        // if (data['roomTypes'] is List) {
        //   _roomTypeListFromApi = (data['roomTypes'] as List)
        //       .map((item) => file_data.GeneralType(item.toString(), item.toString()))
        //       .toList();
        // }
        // // 处理朝向
        // if (data['orientations'] is List) {
        //   _orientedListFromApi = (data['orientations'] as List)
        //       .map((item) => file_data.GeneralType(item.toString(), item.toString()))
        //       .toList();
        // }

        // 处理方式 (rentTypes)
        if (data['rentTypes'] is List) {
             _rentTypeListLocal = (data['rentTypes'] as List)
              .map((item) => file_data.GeneralType(item.toString(), item.toString()))
              .toList();
        } else {
           _rentTypeListLocal = file_data.rentTypeList;
        }

        // 处理价格 (priceRanges)
        if (data['priceRanges'] is List) {
            _priceListLocal = (data['priceRanges'] as List).map((item) {
                if (item is Map && item.containsKey('label') && item.containsKey('value')) {
                    return file_data.GeneralType(item['label'].toString(), item['value'].toString());
                }
                return file_data.GeneralType('', '');
            }).where((item) => item.name.isNotEmpty).toList();
        } else {
            _priceListLocal = file_data.priceList;
        }

        if (mounted) {
          setState(() {});
          _loadDataToModel();
          _updateTitles();
        }
      }
    } catch (e) {
      print('Error fetching filter options: $e');
      // _roomTypeListFromApi = file_data.roomTypeList; // No longer needed
      // _orientedListFromApi = file_data.orientedList; // No longer needed
      // _floorListFromApi = file_data.floorList; // No longer needed, using static data
      _rentTypeListLocal = file_data.rentTypeList;
      _priceListLocal = file_data.priceList;
      if (mounted) {
        _loadDataToModel();
        _updateTitles();
      }
    }
  }

  _onAreaChange(context) {
    final cityModel = ScopedModelHelper.getModel<CityModel>(context);
    final filterModel = ScopedModelHelper.getModel<FilterBarModel>(context);
    String? currentCityNameFromModel = cityModel.city?.name;

    if (currentCityNameFromModel != null && currentCityNameFromModel != '定位中...') {
      // 使用RegionService获取区域数据
      _dynamicAreaOptionsForPicker = RegionService.getDistrictsByCityName(currentCityNameFromModel);
      filterModel.dataList = {...filterModel.dataList, 'districtList': _dynamicAreaOptionsForPicker};
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
    )?.then((index) {
      if (index == null) return;
      if (mounted) {
        String newDistrictId = _dynamicAreaOptionsForPicker[index].id;
        filterModel.selectedDistrictId = newDistrictId;
        _selectedDistrictIdLocal = newDistrictId;
        _updateTitles();
        _onChange();
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

  _onFilterChange(context) {
    setState(() { isFilterActive = true; });
    Scaffold.of(context).openEndDrawer();
    // FilterBarModel的监听器 (_onFilterModelChange) 会在抽屉关闭且模型更新后处理后续逻辑
  }

  _onChange() {
    // 只有在初始化完成后才触发 onChange 回调
    if (!_isInitialized || widget.onChange == null) return;
 
    final filterModel = ScopedModelHelper.getModel<FilterBarModel>(context);
    final params = filterModel.getApiFilterParams;
    final cityModel = ScopedModelHelper.getModel<CityModel>(context);
    String? currentCityId = filterModel.selectedCityId;
 
    widget.onChange!(
      file_data.FilterBarResult(
        cityId: currentCityId,
        districtId: params['district'] as String?,
        rentTypeId: params['rentType'] as String?,
        priceId: params['price'] as String?,
        roomTypeIds: (params['roomType'] as String?)?.split(','),
        orientationIds: (params['orientation'] as String?)?.split(','),
        floorIds: (params['floor'] as String?)?.split(','),
        tagIds: (params['tags'] as String?)?.split(','),
      ),
    );
     // 当筛选条件变化后，也更新一下顶栏标题
    _updateTitles();
  }

  _loadDataToModel() {
    // 使用成员变量 _filterBarModel
    if (_filterBarModel == null) return; // Add null check
    final filterModel = _filterBarModel!;
    
    Map<String, List<file_data.GeneralType>> dataForModel = {
      // 使用本地静态数据
      'roomTypeList': file_data.roomTypeList, // Directly use static roomTypeList
      'orientedList': file_data.orientedList, // Directly use static orientedList
      'floorList': file_data.floorList, // Directly use static floorList
      'rentTypeList': _rentTypeListLocal, // 这些仍然使用本地或API更新后的本地变量
      'priceList': _priceListLocal,
      'tagList': _tagListLocal,
    };
    
    if (_dynamicAreaOptionsForPicker.isNotEmpty && _dynamicAreaOptionsForPicker.first.id != 'area_any') {
       dataForModel['districtList'] = _dynamicAreaOptionsForPicker;
    } else if (_districtListLocal.isNotEmpty) {
       dataForModel['districtList'] = _districtListLocal;
    }

    filterModel.dataList = dataForModel;

    filterModel.selectedDistrictId = _selectedDistrictIdLocal;
    filterModel.selectedRentTypeId = _selectedRentTypeIdLocal;
    filterModel.selectedPriceId = _selectedPriceIdLocal;
  }

  // 更新顶部筛选按钮的标题
  void _updateTitles() {
    // 使用成员变量 _filterBarModel
    if (_filterBarModel == null) return; // Add null check
    final filterModel = _filterBarModel!;
 
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
    
    // 确保region.json数据已加载
    RegionService.loadRegionData();
    
    // 初始化本地列表（作为备用）
    _priceListLocal = file_data.priceList;
    _rentTypeListLocal = file_data.rentTypeList;
    _tagListLocal = file_data.tagList;

    _selectedDistrictIdLocal = _dynamicAreaOptionsForPicker.isNotEmpty ? _dynamicAreaOptionsForPicker[0].id : 'area_any';
    _selectedRentTypeIdLocal = _rentTypeListLocal.isNotEmpty ? _rentTypeListLocal[0].id : 'rent_type_any';
    _selectedPriceIdLocal = _priceListLocal.isNotEmpty ? _priceListLocal[0].id : 'price_any';
    
    Timer.run(() async {
      if (!mounted) return; // Add mounted check at the beginning of the async block
      await _fetchFilterOptions();
      if (!mounted) return; // Add mounted check after async operation

      final cityModel = ScopedModelHelper.getModel<CityModel>(context);
      _filterBarModel = ScopedModelHelper.getModel<FilterBarModel>(context); // 确保在 initState 中获取
      cityModel.addListener(_cityChangedListener);
      // 根据 initialRentType 设置默认选中项
      if (widget.initialRentType != null && widget.initialRentType!.isNotEmpty) {
        final rentTypeList = _filterBarModel!.dataList['rentTypeList'] ?? _rentTypeListLocal;
        final selectedItem = rentTypeList.firstWhere(
          (item) => item.name == widget.initialRentType,
          orElse: () => file_data.GeneralType('', ''),
        );
        if (selectedItem.id.isNotEmpty) {
          _filterBarModel!.selectedRentTypeId = selectedItem.id;
          _selectedRentTypeIdLocal = selectedItem.id;
        }
      }
      
      _handleCityChange(cityModel); // 确保在获取筛选选项后，根据当前城市调整区域

      _filterBarModel!.addListener(_onFilterModelChange); // 使用成员变量并添加监听
      _updateTitles(); // 初始化时更新标题

      // 设置初始化完成标志
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        // 在初始化完成后触发回调
        widget.onInitialized?.call();
      }
    });
  }

  // 新增：当 FilterBarModel 变化时（例如抽屉关闭后），调用此方法
  void _onFilterModelChange() {
    // 延迟执行，确保在下一个帧绘制时检查 mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateTitles();
        _onChange();
        if (!Scaffold.of(context).isEndDrawerOpen) {
           setState(() {
             isFilterActive = false;
           });
        }
      }
    });
  }

 @override
  void dispose() {
    final cityModel = ScopedModelHelper.getModel<CityModel>(context);
    cityModel.removeListener(_cityChangedListener);
    // 移除对成员变量的监听
    _filterBarModel?.removeListener(_onFilterModelChange);
    super.dispose();
  }

  void _cityChangedListener() {
    final cityModel = ScopedModelHelper.getModel<CityModel>(context);
    _handleCityChange(cityModel);
  }

  void _handleCityChange(CityModel cityModel) {
    // 使用成员变量 _filterBarModel
    if (_filterBarModel == null) return; // Add null check
    final filterModel = _filterBarModel!;
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
        var currentDataList = Map<String, List<file_data.GeneralType>>.from(filterModel.dataList); // 创建可修改的副本
        currentDataList['districtList'] = _dynamicAreaOptionsForPicker;
        filterModel.selectedCityId = cityInfo.cityName;
        filterModel.dataList = currentDataList;

      } catch (e) {
        _dynamicAreaOptionsForPicker = [file_data.GeneralType('不限', 'area_any')];
        filterModel.selectedCityId = null;
      }
    } else {
      _dynamicAreaOptionsForPicker = [file_data.GeneralType('不限', 'area_any')];
    }
    filterModel.selectedDistrictId = _dynamicAreaOptionsForPicker.isNotEmpty ? _dynamicAreaOptionsForPicker[0].id : 'area_any';
    _selectedDistrictIdLocal = filterModel.selectedDistrictId!;
    _updateTitles();
    // _onChange(); // 移除此处的直接调用，避免城市变化时立即触发两次数据请求
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 在这里获取 ScopedModel 的引用
    _filterBarModel = ScopedModelHelper.getModel<FilterBarModel>(context);
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

