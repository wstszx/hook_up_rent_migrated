import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../config.dart';
// import 'package:hook_up_rent/config.dart';

class DioHttp {
  late Dio _client;
  late BuildContext context;

  static DioHttp of(BuildContext context) {
    return DioHttp._internal(context);
  }

  DioHttp._internal(BuildContext context) {
    if (_client == null || context != this.context) {
      this.context = context;
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
  Future<Response<Map<String, dynamic>>> get(String path,
      [Map<String, dynamic>? params, String? token]) async {
    var options = Options(headers: {'Authorization': token});
    return await _client.get(path, queryParameters: params, options: options);
  }

//post请求
  Future<Response<Map<String, dynamic>>> post(String path,
      [Map<String, dynamic>? params, String? token]) async {
    var options = Options(headers: {'Authorization': token});
    return await _client.post(path, queryParameters: params, options: options);
  }

//post请求上传表单数据
  Future<Response<Map<String, dynamic>>> postFormData(String path,
      [Map<String, dynamic>? params, String? token]) async {
    var options = Options(
        headers: {'Authorization': token}, contentType: 'multipart/form-data');
    return await _client.get(path, queryParameters: params, options: options);
  }
}
