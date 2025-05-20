import '../models/house.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import '../config.dart';
import 'dart:math';

class HouseService {
  final Dio _dio = Dio(BaseOptions(baseUrl: Config.BaseUrl));

  Future<List<House>> getHouses() async {
    try {
      final response = await _dio.get('/api/rooms');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['rooms'];
        return data.map((json) => House(
          id: json['_id'],
          title: json['title'],
          price: '${json['price']}元/月',
          area: json['area'] ?? '暂无数据',
          community: json['address'] ?? json['district'] ?? '',
          latitude: json['location']?['coordinates']?[1] ?? 0.0,
          longitude: json['location']?['coordinates']?[0] ?? 0.0,
          imageUrl: json['images']?.isNotEmpty == true ? json['images'][0] : 'static/images/home_index_recommend_1.png',
        )).toList();
      }
      return [];
    } catch (e) {
      print('获取房源列表失败: $e');
      return [];
    }
  }

  Future<List<House>> searchHouses(String keyword) async {
    try {
      final response = await _dio.get('/api/rooms', queryParameters: {
        'keyword': keyword,
      });
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['rooms'];
        return data.map((json) => House(
          id: json['_id'],
          title: json['title'],
          price: '${json['price']}元/月',
          area: json['area'] ?? '暂无数据',
          community: json['address'] ?? json['district'] ?? '',
          latitude: json['location']?['coordinates']?[1] ?? 0.0,
          longitude: json['location']?['coordinates']?[0] ?? 0.0,
          imageUrl: json['images']?.isNotEmpty == true ? json['images'][0] : 'static/images/home_index_recommend_1.png',
        )).toList();
      }
      return [];
    } catch (e) {
      print('搜索房源失败: $e');
      return [];
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 - cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)).toDouble();
  }

  Future<List<House>> filterByDistanceAndCity(double centerLat, double centerLon, double radiusKm, String cityName) async {
    try {
      final response = await _dio.get('/api/rooms', queryParameters: {
        'city': cityName,
        'latitude': centerLat,
        'longitude': centerLon,
        'radius': radiusKm
      });
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['rooms'];
        return data.map((json) => House(
          id: json['_id'],
          title: json['title'],
          price: '${json['price']}元/月',
          area: json['area'] ?? '暂无数据',
          community: json['address'] ?? json['district'] ?? '',
          latitude: json['location']?['coordinates']?[1] ?? 0.0,
          longitude: json['location']?['coordinates']?[0] ?? 0.0,
          imageUrl: json['images']?.isNotEmpty == true ? json['images'][0] : 'static/images/home_index_recommend_1.png',
        )).toList();
      }
      return [];
    } catch (e) {
      print('按城市和距离获取房源失败: $e');
      return [];
    }
  }
}