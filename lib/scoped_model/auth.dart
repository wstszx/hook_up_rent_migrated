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
    const url = '/user';
    var res = await DioHttp.of(context).get(url, null, _token);
    var resMap = json.decode(res.toString());
    var data = resMap['body'];
    var userInfo = UserInfo.formJson(data);
    _userInfo = _userInfo;
    notifyListeners();
  }

  void login(String token, BuildContext context) {
    _token = token;
    notifyListeners(); //通知数据改变
    _getUserInfo(context);
  }

  void logout() {
    _token = '';
    _userInfo = null;
    notifyListeners();
  }
}
