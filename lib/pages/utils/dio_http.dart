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
    try {
      // Corrected API endpoint to fetch filter options which include cities
      final response = await get('/api/configurations/filter-options', null, token);

      if (response.statusCode == 200 && response.data != null) {
        // The response.data is an object like: { cities: [], rentTypes: [], ... }
        // We need to extract the 'cities' list from this object.
        if (response.data is Map<String, dynamic>) {
          Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
          if (responseData.containsKey('cities') && responseData['cities'] is List) {
            List<dynamic> cityDataList = responseData['cities'] as List<dynamic>;
            return cityDataList
                .map((data) {
                  if (data is Map<String, dynamic>) {
                    // Manually map backend fields to what GeneralType.fromJson expects.
                    // GeneralType expects 'label' for name and 'value' for id.
                    // Backend's CityOption provides 'name' and 'id' (which is a string of '_id').
                    final String? backendName = data['name'] as String?;
                    final String? backendId = data['id'] as String? ?? data['_id'] as String?; // Use 'id' if present, else '_id'

                    if (backendName != null && backendId != null) {
                      return GeneralType.fromJson({
                        'label': backendName, // Map backend 'name' to 'label'
                        'value': backendId,   // Map backend 'id' (or '_id') to 'value'
                      });
                    } else {
                      print('Warning: Missing "name" or "id"/"_id" in city data item: $data');
                      return null;
                    }
                  } else {
                    print('Warning: Invalid item format in city data list: $data');
                    return null;
                  }
                })
                .whereType<GeneralType>()
                .toList();
          } else {
            print('Failed to load cities: "cities" key not found or not a list in response. Data: ${response.data}');
            return [];
          }
        } else {
          print('Failed to load cities: Response data is not a Map. Data: ${response.data}');
          return [];
        }
      } else {
        print('Failed to load cities: Status ${response.statusCode}, Data: ${response.data}');
        return []; // Or throw an exception
      }
    } catch (e, s) {
      print('Error fetching cities: $e');
      print('Stack trace: $s');
      return []; // Or throw an exception
    }
  }
}
