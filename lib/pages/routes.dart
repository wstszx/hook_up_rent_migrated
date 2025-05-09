import 'package:flutter/material.dart';
import 'package:hook_up_rent/pages/home/index.dart';
import 'package:fluro/fluro.dart';
import 'package:hook_up_rent/pages/login.dart';
import 'package:hook_up_rent/pages/home/tab_search/index.dart'; // 搜索页
import 'package:hook_up_rent/pages/room_add/index.dart'; // 房源发布页
import 'package:hook_up_rent/pages/map_page.dart'; // 地图页

class Routes {
  // 定义路由名称
  static String home = '/';
  static String login = 'login';
  static String search = '/search';
  static String map = '/map';
  static String roomAdd = '/room-add';

  static void configureRoutes(FluroRouter router) {
    router.define(home, handler: _homeHandler);
    router.define(login, handler: _loginHandler);
    router.define(search, handler: _searchHandler);
    router.define(map, handler: _mapHandler);
    router.define(roomAdd, handler: _roomAddHandler);
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

  static final Handler _searchHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    // 注意：TabSearch 可能需要参数，例如 rentType
    // 在 IndexNavigatorItem 中我们传递了 arguments: {'rentType': '整租'}
    // FluroRouter 会自动将它们放入 params 中，或者可以通过 ModalRoute.of(context)?.settings.arguments 获取
    return const TabSearch();
  });

  static final Handler _mapHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return const MapPage();
  });

  static final Handler _roomAddHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return const RoomAddPage();
  });
}
