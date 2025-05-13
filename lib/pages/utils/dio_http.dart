import 'dart:convert'; // Import for jsonEncode
import 'package:flutter/foundation.dart'; // Import for kDebugMode
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../models/general_type.dart'; // Added import for GeneralType

import '../../config.dart';
// import 'package:hook_up_rent/config.dart';

class DioHttp {
  Dio? _client;
  BuildContext? _context;

  static DioHttp of(BuildContext context) {
    return DioHttp._internal(context);
  }

  DioHttp._internal(BuildContext context) {
    if (_client == null || context != _context) {
      _context = context;
      var options = BaseOptions(
          baseUrl: Config.BaseUrl,
          connectTimeout: const Duration(milliseconds: 1000 * 10),
          receiveTimeout: const Duration(milliseconds: 1000 * 3),
          extra: {'context': context});
      var client = Dio(options);
      _client = client;
    }
  }

  //get请求
  Future<Response<dynamic>> get(String path,
      [Map<String, dynamic>? params, String? token]) async {
    var options = Options(headers: {'Authorization': token});
    return await _client!.get<dynamic>(path, queryParameters: params, options: options);
  }

//post请求
  Future<Response<dynamic>> post(String path,
      [Map<String, dynamic>? params, String? token]) async {
    var options = Options(headers: {'Authorization': token});
    return await _client!.post<dynamic>(path, data: params, options: options);
  }

//post请求上传表单数据
  Future<Response<dynamic>> postFormData(String path,
      [Map<String, dynamic>? params, String? token]) async {
    var options = Options(
        headers: {'Authorization': token}, contentType: 'multipart/form-data');
    return await _client!.post<dynamic>(path, data: FormData.fromMap(params ?? {}), options: options);
  }

  // Method to fetch cities from the backend
  Future<List<GeneralType>> getCities({String? token}) async {
    if (kDebugMode) {
      print('[DioHttp][getCities] Attempting to fetch cities...');
    }
    try {
      final response = await get('/api/configurations/filter-options', null, token);
      if (kDebugMode) {
        print('[DioHttp][getCities] Response status: ${response.statusCode}');
        try {
          print('[DioHttp][getCities] Raw response data: ${jsonEncode(response.data)}');
        } catch (e) {
          print('[DioHttp][getCities] Raw response data (not JSON encodable): ${response.data.toString()}');
        }
      }

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
          if (responseData.containsKey('cities') && responseData['cities'] is List) {
            List<dynamic> cityDataList = responseData['cities'] as List<dynamic>;
            if (kDebugMode) {
              print('[DioHttp][getCities] Extracted cityDataList: ${jsonEncode(cityDataList)}');
            }

            List<GeneralType> cities = cityDataList
                .map((data) {
                  if (data is Map<String, dynamic>) {
                    final String? backendName = data['name'] as String?;
                    final String? backendId = data['id'] as String? ?? data['_id'] as String?;
                    if (kDebugMode) {
                      // print('[DioHttp][getCities] Processing city item: name=$backendName, id=$backendId');
                    }
                    if (backendName != null && backendId != null) {
                      return GeneralType.fromJson({
                        'label': backendName,
                        'value': backendId,
                      });
                    } else {
                      if (kDebugMode) {
                        print('[DioHttp][getCities] Warning: Missing "name" or "id"/"_id" in city data item: $data');
                      }
                      return null;
                    }
                  } else {
                    if (kDebugMode) {
                      print('[DioHttp][getCities] Warning: Invalid item format in city data list: $data');
                    }
                    return null;
                  }
                })
                .whereType<GeneralType>()
                .toList();
            if (kDebugMode) {
              print('[DioHttp][getCities] Parsed cities: ${cities.map((c) => "Name: ${c.name}, ID: ${c.id}").toList()}');
              print('[DioHttp][getCities] Successfully fetched and parsed ${cities.length} cities.');
            }
            return cities;
          } else {
            if (kDebugMode) {
              print('[DioHttp][getCities] Failed to load cities: "cities" key not found or not a list in response. Data: ${response.data}');
            }
            return [];
          }
        } else {
          if (kDebugMode) {
            print('[DioHttp][getCities] Failed to load cities: Response data is not a Map. Data: ${response.data}');
          }
          return [];
        }
      } else {
        if (kDebugMode) {
          print('[DioHttp][getCities] Failed to load cities: Status ${response.statusCode}, Data: ${response.data}');
        }
        return [];
      }
    } catch (e, s) {
      if (kDebugMode) {
        print('[DioHttp][getCities] Error fetching cities: $e');
        print('[DioHttp][getCities] Stack trace: $s');
      }
      return [];
    }
  }
}
