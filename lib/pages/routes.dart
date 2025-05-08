import 'package:flutter/material.dart';
import 'package:hook_up_rent/pages/home/index.dart';
import 'package:fluro/fluro.dart';
import 'package:hook_up_rent/pages/login.dart';

class Routes {
  // 定义路由名称
  static String home = '/';
  static String login = 'login';

  static void configureRoutes(FluroRouter router) {
    router.define(home, handler: _homeHandler);
    router.define(login, handler: _loginHandler);
  }

  // 定义路由处理函数
  static final Handler _homeHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return const HomePage();
  });
  static final Handler _loginHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return const LoginPage();
  });
}
