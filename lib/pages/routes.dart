import 'package:flutter/material.dart';
import 'package:hook_up_rent/pages/home/index.dart';
import 'package:fluro/fluro.dart';
import 'package:hook_up_rent/pages/login.dart';
import 'package:hook_up_rent/pages/home/tab_search/index.dart'; // 搜索页
import 'package:hook_up_rent/pages/room_add/index.dart'; // 房源发布页
import 'package:hook_up_rent/pages/map_page.dart'; // 地图页
import 'package:hook_up_rent/pages/room_detail/index.dart'; // 房源详情页

class Routes {
  // 定义路由名称
  static String home = '/';
  static String login = 'login';
  static String search = '/search'; // Fluro define path
  static String map = '/map'; // Fluro define path
  static String roomAdd = '/room-add'; // Fluro define path
  static String roomDetail = 'room_detail'; // Route name for Navigator.pushNamed and Fluro define path

  static void configureRoutes(FluroRouter router) {
    router.define(home, handler: _homeHandler);
    router.define(login, handler: _loginHandler);
    // For Fluro, if using pushNamed with simple names like 'search',
    // it's often better to define them without leading '/' unless they are top-level paths.
    // However, Navigator.pushNamed treats them as names, not paths.
    // The key is consistency between pushNamed and Fluro's define.
    // Given existing '/search', '/map', '/room-add', let's stick to that pattern for new top-level views if appropriate.
    // But 'room_detail' is likely pushed from another page, so a simple name is fine.
    router.define(search, handler: _searchHandler); // Existing uses /search
    router.define(map, handler: _mapHandler); // Existing uses /map
    router.define(roomAdd, handler: _roomAddHandler); // Existing uses /room-add
    router.define(roomDetail, handler: _roomDetailHandler, transitionType: TransitionType.native);
  }

  // 定义路由处理函数
  static final Handler _homeHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
    return const HomePage();
  });
  static final Handler _loginHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
    return const LoginPage();
  });

  static final Handler _searchHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
    return const TabSearch();
  });

  static final Handler _mapHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
    return const MapPage();
  });

  static final Handler _roomAddHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
    return const RoomAddPage();
  });

  static final Handler _roomDetailHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
    // RoomDetailPage expects arguments via ModalRoute.of(context)?.settings.arguments
    return const RoomDetailPage();
  });
}
