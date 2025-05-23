import 'package:dio/dio.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../models/user_info.dart';
import '../pages/utils/dio_http.dart';
import '../pages/utils/store.dart';

// 登录
class AuthModel extends Model {
  String _token = '';
  UserInfo? _userInfo;
  //获取token
  String get token => _token;
  UserInfo? get userInfo => _userInfo;
  //判断是否已登录
  bool get isLogin => _token != '';

  void initApp(BuildContext context) async {
    Store store = await Store.getInstance();
    String token = await store.getString(StoreKeys.token);
    if (token.isNotEmpty) {
      login(token, context);
    }
  }

  _getUserInfo(BuildContext context) async {
    const url = '/api/auth/me'; // Corrected API endpoint for fetching user info
    try {
      var response = await DioHttp.of(context).get(url, null, _token);

      // Assuming DioHttp is configured to handle JSON and response.data is Map<String, dynamic>
      if (response.statusCode == 200 && response.data != null && response.data is Map<String, dynamic>) {
        // The backend /api/me route directly returns the user object (which might be nested if your backend wraps it)
        // Let's assume the direct user object is what UserInfo.formJson expects or it's in a 'user' field
        Map<String, dynamic> resData = response.data as Map<String, dynamic>;
        UserInfo userInfo;
        if (resData.containsKey('user') && resData['user'] is Map<String, dynamic>) {
           userInfo = UserInfo.formJson(resData['user'] as Map<String, dynamic>);
        } else {
           // If the response IS the user object directly
           userInfo = UserInfo.formJson(resData);
        }
        _userInfo = userInfo; // Corrected assignment
        notifyListeners();
      } else {
        print('Failed to get user info: ${response.statusCode} ${response.data}'); // 修改打印语句
        // Optionally logout or clear token if user info fetch fails consistently
        // logout();
      }
    } catch (e) {
      print('Error fetching user info: $e'); // 修改打印语句
      // Optionally logout or clear token on error
      // logout();
    }
  }

  void login(String token, BuildContext context) {
    _token = token;
    notifyListeners(); //通知数据改变
    _getUserInfo(context);
  }

  // Method to allow external updates to userInfo, e.g., after profile edit
  void updateUserInfo(UserInfo newInfo) {
    _userInfo = newInfo;
    notifyListeners();
  }

  Future<void> refreshUserInfo(BuildContext context) async {
    if (_token.isNotEmpty) {
      await _getUserInfo(context);
    }
  }
 
  void logout() {
    _token = '';
    _userInfo = null;
    notifyListeners();
  }
}
