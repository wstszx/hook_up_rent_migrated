import 'package:rent_share/pages/home/tab_search/filter_bar/data.dart';
import 'package:scoped_model/scoped_model.dart';

class FilterBarModel extends Model {
  List<GeneralType>? _roomTypeList;
  List<GeneralType>? _orientedList;
  List<GeneralType>? _floorList;
  List<GeneralType>? _rentTypeList; // 新增：租赁类型
  List<GeneralType>? _priceList; // 新增：价格范围
  List<GeneralType>? _tagList; // 新增：标签

  // 城市和区域可能需要特殊处理，因为它们通常是级联选择
  // 这里暂时用 GeneralType，后续可能需要调整
  List<GeneralType>? _cityList;
  List<GeneralType>? _districtList;


  String? _selectedCityId; // 新增：选中的城市ID
  String? _selectedDistrictId; // 新增：选中的区域ID
  String? _selectedRentTypeId; // 新增：选中的租赁类型ID
  String? _selectedPriceId; // 新增：选中的价格范围ID

  final Set<String> _selectedTagList = <String>{}; // 用于多选的标签
  final Set<String> _selectedRoomTypeList = <String>{}; // 用于多选的户型
  final Set<String> _selectedOrientedList = <String>{}; // 用于多选的朝向
  final Set<String> _selectedFloorList = <String>{}; // 用于多选的楼层


  Map<String, List<GeneralType>> get dataList {
    var result = <String, List<GeneralType>>{};
    if (_roomTypeList != null) {
      result['roomTypeList'] = _roomTypeList!;
    }
    if (_orientedList != null) {
      result['orientedList'] = _orientedList!;
    }
    if (_floorList != null) {
      result['floorList'] = _floorList!;
    }
    if (_rentTypeList != null) {
      result['rentTypeList'] = _rentTypeList!;
    }
    if (_priceList != null) {
      result['priceList'] = _priceList!;
    }
    if (_tagList != null) {
      result['tagList'] = _tagList!;
    }
    if (_cityList != null) {
      result['cityList'] = _cityList!;
    }
    if (_districtList != null) {
      result['districtList'] = _districtList!;
    }
    return result;
  }

  set dataList(Map<String, List<GeneralType>> data) {
    _roomTypeList = data['roomTypeList'];
    _orientedList = data['orientedList'];
    _floorList = data['floorList'];
    _rentTypeList = data['rentTypeList'];
    _priceList = data['priceList'];
    _tagList = data['tagList'];
    _cityList = data['cityList'];
    _districtList = data['districtList'];
    notifyListeners();
  }

  // Getter and Setter for selected City
  String? get selectedCityId => _selectedCityId;
  set selectedCityId(String? cityId) {
    _selectedCityId = cityId;
    _selectedDistrictId = null; // 城市改变时，清空区域选择
    // TODO: 可能需要根据城市ID加载对应的区域列表 _districtList
    notifyListeners();
  }

  // Getter and Setter for selected District
  String? get selectedDistrictId => _selectedDistrictId;
  set selectedDistrictId(String? districtId) {
    _selectedDistrictId = districtId;
    notifyListeners();
  }

  // Getter and Setter for selected RentType
  String? get selectedRentTypeId => _selectedRentTypeId;
  set selectedRentTypeId(String? rentTypeId) {
    _selectedRentTypeId = rentTypeId;
    notifyListeners();
  }

  // Getter and Setter for selected Price
  String? get selectedPriceId => _selectedPriceId;
  set selectedPriceId(String? priceId) {
    _selectedPriceId = priceId;
    notifyListeners();
  }

  // Methods for multi-select lists (tags, roomType, oriented, floor)
  Set<String> get selectedTagList => _selectedTagList;
  void toggleSelectedTagItem(String tagId) {
    if (_selectedTagList.contains(tagId)) {
      _selectedTagList.remove(tagId);
    } else {
      _selectedTagList.add(tagId);
    }
    notifyListeners();
  }

  Set<String> get selectedRoomTypeList => _selectedRoomTypeList;
  void toggleSelectedRoomTypeItem(String roomTypeId) {
    if (_selectedRoomTypeList.contains(roomTypeId)) {
      _selectedRoomTypeList.remove(roomTypeId);
    } else {
      _selectedRoomTypeList.add(roomTypeId);
    }
    notifyListeners();
  }

  Set<String> get selectedOrientedList => _selectedOrientedList;
  void toggleSelectedOrientedItem(String orientedId) {
    if (_selectedOrientedList.contains(orientedId)) {
      _selectedOrientedList.remove(orientedId);
    } else {
      _selectedOrientedList.add(orientedId);
    }
    notifyListeners();
  }

  Set<String> get selectedFloorList => _selectedFloorList;
  void toggleSelectedFloorItem(String floorId) {
    if (_selectedFloorList.contains(floorId)) {
      _selectedFloorList.remove(floorId);
    } else {
      _selectedFloorList.add(floorId);
    }
    notifyListeners();
  }

  // 原始的 selectedList 和 toggle 方法，如果不再使用可以移除或标记为废弃
  // 为了兼容旧代码，暂时保留，但建议迁移到新的 specific toggle 方法
  final Set<String> _selectedList = <String>{};
  Set<String> get selectedList {
    // print("Warning: selectedList getter is deprecated. Use specific getters like selectedTagList, selectedRoomTypeList etc.");
    return _selectedList;
  }

  selectedListToggleItem(String data) {
    // print("Warning: selectedListToggleItem is deprecated. Use specific toggle methods.");
    if (_selectedList.contains(data)) {
      _selectedList.remove(data);
    } else {
      _selectedList.add(data);
    }
    notifyListeners();
  }

  // Method to clear all selections
  void clearSelections() {
    _selectedCityId = null;
    _selectedDistrictId = null;
    _selectedRentTypeId = null;
    _selectedPriceId = null;
    _selectedTagList.clear();
    _selectedRoomTypeList.clear();
    _selectedOrientedList.clear();
    _selectedFloorList.clear();
    _selectedList.clear(); // 清除旧的选中列表
    notifyListeners();
  }

  // Method to get all active filter parameters for API query
  Map<String, dynamic> get getApiFilterParams {
    Map<String, dynamic> params = {};

    // 单选条件：仅当选择的不是 "不限" 选项时才添加参数
    // 注意: "不限" 的 ID 可能需要根据实际 data.dart 中的定义调整
    if (_selectedCityId != null && _selectedCityId!.isNotEmpty && !_selectedCityId!.endsWith('_city_any') && _selectedCityId != 'city_any') {
      params['city'] = _selectedCityId;
    }
    // 对于区域，不限的 ID 通常是 'xxx_area_any' 或 'area_any'
    if (_selectedDistrictId != null && _selectedDistrictId!.isNotEmpty && !_selectedDistrictId!.endsWith('_area_any') && _selectedDistrictId != 'area_any') {
      params['district'] = _selectedDistrictId;
    }
    if (_selectedRentTypeId != null && _selectedRentTypeId!.isNotEmpty && _selectedRentTypeId != 'rent_type_any') {
      params['rentType'] = _selectedRentTypeId;
    }
    if (_selectedPriceId != null && _selectedPriceId!.isNotEmpty && _selectedPriceId != 'price_any') {
      params['price'] = _selectedPriceId; // 后端需要解析价格ID对应的范围
    }

    // 多选条件：如果集合不为空，则加入参数
    if (_selectedRoomTypeList.isNotEmpty) {
      // 如果多选列表也包含 "不限" 选项 (例如 'room_type_any')，并且它是唯一选中的，则不应发送参数
      // 或者，如果 "不限" 被选中，则忽略其他选项。这里假设 "不限" 不会与其他选项同时存在于选中集合中。
      // 如果业务逻辑允许 "不限" 和其他选项共存，则需要更复杂的处理。
      // 为简单起见，如果多选列表只有一个元素且该元素是 "不限" ID，则不发送。
      if (!(_selectedRoomTypeList.length == 1 && (_selectedRoomTypeList.first.endsWith('_any') || _selectedRoomTypeList.first == 'room_type_any'))) {
         params['roomType'] = _selectedRoomTypeList.join(',');
      }
    }
    if (_selectedOrientedList.isNotEmpty) {
      if (!(_selectedOrientedList.length == 1 && (_selectedOrientedList.first.endsWith('_any') || _selectedOrientedList.first == 'orientation_any'))) {
        params['orientation'] = _selectedOrientedList.join(',');
      }
    }
    if (_selectedFloorList.isNotEmpty) {
       if (!(_selectedFloorList.length == 1 && (_selectedFloorList.first.endsWith('_any') || _selectedFloorList.first == 'floor_any'))) {
        params['floor'] = _selectedFloorList.join(',');
      }
    }
    if (_selectedTagList.isNotEmpty) {
      if (!(_selectedTagList.length == 1 && (_selectedTagList.first.endsWith('_any') || _selectedTagList.first == 'tag_any'))) {
        params['tags'] = _selectedTagList.join(',');
      }
    }
    return params;
  }
}

