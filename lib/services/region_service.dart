import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:rent_share/pages/home/tab_search/filter_bar/data.dart' as file_data;

class RegionInfo {
  final String name;
  final double longitude;
  final double latitude;
  final String level;
  final List<RegionInfo> districts;

  RegionInfo({
    required this.name,
    required this.longitude,
    required this.latitude,
    required this.level,
    required this.districts,
  });

  factory RegionInfo.fromJson(Map<String, dynamic> json) {
    List<RegionInfo> districtsList = [];
    if (json['districts'] != null) {
      districtsList = List<RegionInfo>.from(
        (json['districts'] as List).map(
          (district) => RegionInfo.fromJson(district),
        ),
      );
    }

    return RegionInfo(
      name: json['name'],
      longitude: json['center']['longitude'],
      latitude: json['center']['latitude'],
      level: json['level'],
      districts: districtsList,
    );
  }

  // 将RegionInfo转换为GeneralType列表，用于UI显示
  List<file_data.GeneralType> toGeneralTypeList() {
    List<file_data.GeneralType> result = [file_data.GeneralType('不限', '${name}_any')];
    
    // 添加所有区域作为GeneralType
    for (var district in districts) {
      result.add(file_data.GeneralType(district.name, district.name));
    }
    
    return result;
  }
}

class RegionService {
  static RegionInfo? _rootRegion;
  static List<file_data.GeneralType>? _cityList;

  // 加载region.json文件
  static Future<void> loadRegionData() async {
    if (_rootRegion != null) return;

    try {
      // 从assets加载
      final String jsonString = await rootBundle.loadString('region.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      _rootRegion = RegionInfo.fromJson(jsonData);
      _generateCityList();
    } catch (e) {
      // 如果assets加载失败，尝试从文件系统加载
      try {
        final File file = File('region.json');
        final String jsonString = await file.readAsString();
        final Map<String, dynamic> jsonData = json.decode(jsonString);
        _rootRegion = RegionInfo.fromJson(jsonData);
        _generateCityList();
      } catch (e) {
        print('Error loading region.json: $e');
        // 加载失败时设置为null
        _rootRegion = null;
        _cityList = null;
      }
    }
  }

  // 生成城市列表
  static void _generateCityList() {
    if (_rootRegion == null) return;
    
    _cityList = [];
    
    // 添加省级行政区作为城市
    for (var province in _rootRegion!.districts) {
      if (province.level == 'province') {
        // 对于直辖市，直接添加
        if (province.name.endsWith('市') || 
            province.name == '北京' || 
            province.name == '上海' || 
            province.name == '天津' || 
            province.name == '重庆') {
          _cityList!.add(file_data.GeneralType(province.name, province.name));
        } 
        // 对于省份，添加其下的城市
        else {
          for (var city in province.districts) {
            if (city.level == 'city') {
              _cityList!.add(file_data.GeneralType(city.name, city.name));
            }
          }
        }
      }
    }
  }

  // 获取城市列表
  static List<file_data.GeneralType> getCityList() {
    if (_cityList == null) {
      return [];
    }
    return _cityList!;
  }

  // 根据城市名称获取区域列表
  static List<file_data.GeneralType> getDistrictsByCityName(String cityName) {
    if (_rootRegion == null) return [file_data.GeneralType('不限', 'area_any')];
    
    // 去除城市名称中的“市”字
    String normalizedCityName = cityName;
    if (cityName.endsWith('市')) {
      normalizedCityName = cityName.substring(0, cityName.length - 1);
    }
    
    // 初始化结果列表，添加“不限”选项
    List<file_data.GeneralType> result = [file_data.GeneralType('不限', 'area_any')];
    bool found = false;
    
    // 直辖市特殊处理
    if (cityName == '北京市' || cityName == '北京' ||
        cityName == '上海市' || cityName == '上海' ||
        cityName == '天津市' || cityName == '天津' ||
        cityName == '重庆市' || cityName == '重庆') {
      
      // 查找对应的省级区域
      for (var province in _rootRegion!.districts) {
        if (province.name.contains('北京') && (cityName == '北京市' || cityName == '北京') ||
            province.name.contains('上海') && (cityName == '上海市' || cityName == '上海') ||
            province.name.contains('天津') && (cityName == '天津市' || cityName == '天津') ||
            province.name.contains('重庆') && (cityName == '重庆市' || cityName == '重庆')) {
          
          // 直辖市下有城区和郊县的分类
          for (var cityArea in province.districts) {
            // 遍历城区或郊县下的所有区县
            for (var district in cityArea.districts) {
              // 将区县添加到结果中
              result.add(file_data.GeneralType(district.name, district.name));
            }
          }
          found = true;
          break;
        }
      }
    } else {
      // 处理普通省份下的城市
      for (var province in _rootRegion!.districts) {
        // 跳过直辖市
        if (province.name == '北京市' || province.name == '上海市' ||
            province.name == '天津市' || province.name == '重庆市') {
          continue;
        }
        
        // 遍历省份下的所有城市
        for (var city in province.districts) {
          if (city.name == cityName || city.name == normalizedCityName) {
            // 如果找到目标城市，遍历其下的所有区域
            for (var district in city.districts) {
              // 将区县添加到结果中
              result.add(file_data.GeneralType(district.name, district.name));
            }
            found = true;
            break;
          }
        }
        if (found) break;
      }
    }
    
    // 如果没有找到任何区域，尝试直接在省级区域中查找
    if (result.length <= 1) {
      // 处理特殊情况，如澳门特别行政区等
      for (var province in _rootRegion!.districts) {
        if (province.name == cityName || province.name == normalizedCityName) {
          // 如果省级区域名称与目标城市相同，直接使用其下的区域
          for (var district in province.districts) {
            result.add(file_data.GeneralType(district.name, district.name));
          }
          found = true;
          break;
        }
      }
    }
    
    // 如果仍然没有找到任何区域，返回默认的“不限”
    return result;
  }

  // 根据城市名称获取经纬度
  static Map<String, double>? getCoordinatesByCityName(String cityNameFromModel) {
    if (_rootRegion == null) {
      print("RegionService: _rootRegion is null. Call loadRegionData() first.");
      return null;
    }

    // Iterate through provinces/municipalities in _rootRegion.districts
    for (var provinceLevelRegion in _rootRegion!.districts) {
      // Case 1: The provinceLevelRegion itself is the city we are looking for (this applies to municipalities)
      // Example: cityNameFromModel is "北京市", provinceLevelRegion.name is "北京市"
      if (provinceLevelRegion.name == cityNameFromModel) {
        // Ensure it's a municipality or a city-level entity that has coordinates
        // Municipalities like Beijing, Shanghai are 'province' level in region.json structure
        // but act as cities.
        if (provinceLevelRegion.level == 'province' && 
            (provinceLevelRegion.name.endsWith('市') || 
             ['北京', '上海', '天津', '重庆'].any((m) => provinceLevelRegion.name.startsWith(m)))) {
          return {'latitude': provinceLevelRegion.latitude, 'longitude': provinceLevelRegion.longitude};
        }
      }

      // Case 2: The city is within a province
      // Example: cityNameFromModel is "杭州市", provinceLevelRegion.name is "浙江省"
      // We need to iterate through provinceLevelRegion.districts (which are cities)
      if (provinceLevelRegion.districts.isNotEmpty) {
        for (var cityLevelRegion in provinceLevelRegion.districts) {
          if (cityLevelRegion.name == cityNameFromModel && cityLevelRegion.level == 'city') {
            return {'latitude': cityLevelRegion.latitude, 'longitude': cityLevelRegion.longitude};
          }
        }
      }
    }

    print("RegionService: Coordinates not found for city '$cityNameFromModel'");
    return null; // City not found
  }

  static RegionInfo? getRootRegion() {
    return _rootRegion;
  }
}

