import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

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
}
