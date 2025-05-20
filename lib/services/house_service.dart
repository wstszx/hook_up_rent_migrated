import '../models/house.dart';
import 'dart:math';
import 'region_service.dart';
import 'dart:async';

class HouseService {
  static final Random _random = Random();
  static List<House>? _mockHouses;

  // 生成微小随机偏移
  static double _randomOffset() {
    // 约±0.01度，约1km内
    return (_random.nextDouble() - 0.5) * 0.02;
  }

  // 递归遍历所有城市和行政区，生成房源
  static void _traverseAndGenerate(RegionInfo region, List<House> result, [int countPerRegion = 3]) {
    if (region.level == 'city' || region.level == 'district') {
      for (int i = 0; i < countPerRegion; i++) {
        result.add(House(
          id: '${region.name}_${i}_${_random.nextInt(100000)}',
          title: '${region.name}优质房源${i+1}',
          price: '${2000 + _random.nextInt(8000)}元/月',
          area: '${50 + _random.nextInt(100)}平米',
          community: '${region.name}小区${String.fromCharCode(65 + i)}',
          latitude: region.latitude + _randomOffset(),
          longitude: region.longitude + _randomOffset(),
          imageUrl: 'static/images/home_index_recommend_${1 + _random.nextInt(4)}.png',
        ));
      }
    }
    for (var child in region.districts) {
      _traverseAndGenerate(child, result, countPerRegion);
    }
  }

  static Future<void> ensureMockHousesReady() async {
    if (_mockHouses != null) return;
    await RegionService.loadRegionData();
    final root = RegionService.getRootRegion();
    List<House> result = [];
    if (root != null) {
      for (var province in root.districts) {
        _traverseAndGenerate(province, result);
      }
    }
    _mockHouses = result;
  }

  Future<List<House>> getMockHouses() async {
    await ensureMockHousesReady();
    return _mockHouses ?? [];
  }

  Future<List<House>> searchHouses(String keyword) async {
    await ensureMockHousesReady();
    if (keyword.isEmpty) {
      return _mockHouses ?? [];
    }
    return _mockHouses!.where((house) =>
        house.title.contains(keyword) || house.community.contains(keyword)).toList();
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 - cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Future<List<House>> filterByDistance(double centerLat, double centerLon, double radiusKm) async {
    await ensureMockHousesReady();
    return _mockHouses!.where((house) {
      final distance = _calculateDistance(centerLat, centerLon, house.latitude, house.longitude);
      return distance <= radiusKm;
    }).toList();
  }
}