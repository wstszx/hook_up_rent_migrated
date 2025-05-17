import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../config.dart';

class DioHttp {
  static final DioHttp _instance = DioHttp._internal();
  Dio? _client;

  factory DioHttp.of() {
    return _instance;
  }

  DioHttp._internal() {
    if (_client == null) {
      var options = BaseOptions(
        baseUrl: Config.BaseUrl,
        connectTimeout: const Duration(milliseconds: 1000 * 10),
        receiveTimeout: const Duration(milliseconds: 1000 * 3),
      );
      var client = Dio(options);
      _client = client;
    }
  }

  // GET请求
  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? options,
  }) async {
    var headers = <String, dynamic>{};
    if (options != null && options['token'] != null) {
      headers['Authorization'] = 'Bearer ${options['token']}';
    }
    var requestOptions = Options(headers: headers);
    
    if (kDebugMode) {
      print('[DioHttp][GET] Request Path: $path');
      print('[DioHttp][GET] Request Headers: ${requestOptions.headers}');
      print('[DioHttp][GET] Request Params: $queryParameters');
    }
    
    try {
      final response = await _client!.get<dynamic>(
        path, 
        queryParameters: queryParameters, 
        options: requestOptions
      );
      
      if (kDebugMode) {
        print('[DioHttp][GET] Response Status: ${response.statusCode}');
        print('[DioHttp][GET] Response Headers: ${response.headers}');
        // Be cautious about printing response data if it's large
        // print('[DioHttp][GET] Response Data: ${response.data}');
      }
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('[DioHttp][GET] Error: $e');
      }
      rethrow;
    }
  }

  // POST请求
  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? options,
  }) async {
    var headers = <String, dynamic>{};
    if (options != null && options['token'] != null) {
      headers['Authorization'] = 'Bearer ${options['token']}';
    }
    var requestOptions = Options(headers: headers);
    
    if (kDebugMode) {
      print('[DioHttp][POST] Request Path: $path');
      print('[DioHttp][POST] Request Headers: ${requestOptions.headers}');
      // Be cautious about printing data if it's large or sensitive
      // print('[DioHttp][POST] Request Data: $data');
    }
    
    try {
      final response = await _client!.post<dynamic>(
        path, 
        data: data, 
        options: requestOptions
      );
      
      if (kDebugMode) {
        print('[DioHttp][POST] Response Status: ${response.statusCode}');
        print('[DioHttp][POST] Response Headers: ${response.headers}');
        // Be cautious about printing response data if it's large
        // print('[DioHttp][POST] Response Data: ${response.data}');
      }
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('[DioHttp][POST] Error: $e');
      }
      rethrow;
    }
  }

  // PUT请求
  Future<Response<dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? options,
  }) async {
    var headers = <String, dynamic>{};
    if (options != null && options['token'] != null) {
      headers['Authorization'] = 'Bearer ${options['token']}';
    }
    var requestOptions = Options(headers: headers);
    
    if (kDebugMode) {
      print('[DioHttp][PUT] Request Path: $path');
      print('[DioHttp][PUT] Request Headers: ${requestOptions.headers}');
      // Be cautious about printing data if it's large or sensitive
      // print('[DioHttp][PUT] Request Data: $data');
    }
    
    try {
      final response = await _client!.put<dynamic>(
        path, 
        data: data, 
        options: requestOptions
      );
      
      if (kDebugMode) {
        print('[DioHttp][PUT] Response Status: ${response.statusCode}');
        print('[DioHttp][PUT] Response Headers: ${response.headers}');
        // Be cautious about printing response data if it's large
        // print('[DioHttp][PUT] Response Data: ${response.data}');
      }
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('[DioHttp][PUT] Error: $e');
      }
      rethrow;
    }
  }

  // DELETE请求
  Future<Response<dynamic>> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? options,
  }) async {
    var headers = <String, dynamic>{};
    if (options != null && options['token'] != null) {
      headers['Authorization'] = 'Bearer ${options['token']}';
    }
    var requestOptions = Options(headers: headers);
    
    if (kDebugMode) {
      print('[DioHttp][DELETE] Request Path: $path');
      print('[DioHttp][DELETE] Request Headers: ${requestOptions.headers}');
      print('[DioHttp][DELETE] Request Params: $queryParameters');
    }
    
    try {
      final response = await _client!.delete<dynamic>(
        path, 
        queryParameters: queryParameters, 
        options: requestOptions
      );
      
      if (kDebugMode) {
        print('[DioHttp][DELETE] Response Status: ${response.statusCode}');
        print('[DioHttp][DELETE] Response Headers: ${response.headers}');
        // Be cautious about printing response data if it's large
        // print('[DioHttp][DELETE] Response Data: ${response.data}');
      }
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('[DioHttp][DELETE] Error: $e');
      }
      rethrow;
    }
  }
}
