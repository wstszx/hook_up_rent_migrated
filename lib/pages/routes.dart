import 'package:flutter/material.dart';
import 'package:rent_share/pages/home/index.dart';
import 'package:fluro/fluro.dart';
import 'package:rent_share/pages/login.dart';
import 'package:rent_share/pages/home/tab_search/index.dart'; // 搜索页
import 'package:rent_share/pages/room_add/index.dart'; // 房源发布页
import 'package:rent_share/pages/map_house_page.dart'; // 地图页
import 'package:rent_share/pages/room_detail/index.dart'; // 房源详情页
import 'package:rent_share/pages/room_favorite/index.dart'; // 我的收藏页
import 'package:rent_share/pages/my_orders/index.dart'; // 我的预约页
import 'package:rent_share/pages/profile_edit.dart'; // 个人资料编辑页
import 'package:rent_share/pages/setting.dart'; // 设置页
import 'package:rent_share/pages/home/info/news_detail_page.dart'; // 资讯详情页
import 'package:rent_share/pages/home/info/info_data.dart'; // 导入 InfoItem 类型
import 'package:rent_share/pages/register.dart'; // 注册页
import 'package:rent_share/pages/room_manage/index.dart'; // 房屋管理页
import 'package:rent_share/pages/city_selection_page.dart'; // 城市选择页

class Routes {
  // 定义路由名称
  static String home = '/';
  static String login = 'login';
  static String search = '/search'; // Fluro define path
  static String map = '/map'; // Fluro define path
  static String roomAdd = '/room-add'; // Fluro define path
  static String roomDetail = '/room/:id'; // 修改为动态路由格式，用于处理房源ID参数
  static String roomFavorite = 'room_favorite'; // 我的收藏页
  static String myOrders = 'my_orders'; // 我的预约页
  static String profileEdit = 'profile_edit'; // 个人资料编辑页
  static String setting = 'setting'; // 设置页
  static String newsDetail = 'news_detail'; // 资讯详情页
  static String register = 'register'; // 注册页
  static String roomManage = 'room_manage'; // 房屋管理页
  static String roomEdit = 'room_edit'; // 房屋编辑页
  static String citySelection = 'city_selection'; // 城市选择页
 
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
    router.define(roomDetail, handler: _roomDetailHandler, transitionType: TransitionType.native); // 定义带参数的房源详情路由
    router.define(roomFavorite, handler: _roomFavoriteHandler, transitionType: TransitionType.native);
    router.define(myOrders, handler: _myOrdersHandler, transitionType: TransitionType.native);
    router.define(profileEdit, handler: _profileEditHandler, transitionType: TransitionType.native);
    router.define(setting, handler: _settingHandler, transitionType: TransitionType.native);
    router.define(newsDetail, handler: _newsDetailHandler, transitionType: TransitionType.native);
    router.define(register, handler: _registerHandler, transitionType: TransitionType.native);
    router.define(roomManage, handler: _roomManageHandler, transitionType: TransitionType.native);
    // Define room_edit/:id route to handle room editing with ID parameter
    router.define('$roomEdit/:id', handler: _roomEditHandler, transitionType: TransitionType.native);
    router.define(citySelection, handler: _citySelectionHandler, transitionType: TransitionType.native);
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
    return const MapHousePage();
  });

  static final Handler _roomAddHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
    return const RoomAddPage();
  });

  static final Handler _roomDetailHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
    // 从路由参数中获取房源ID
    final String? houseId = params['id']?.first;
    if (houseId == null) return const RoomDetailPage();
    // 将房源ID作为参数传递给RoomDetailPage
    return RoomDetailPage(houseId: houseId);
  });
 
  static final Handler _roomFavoriteHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
    return const RoomFavoritePage();
  });
 
  static final Handler _myOrdersHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
    return const MyOrdersPage();
  });

  static final Handler _profileEditHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
    return const ProfileEditPage();
  });

  static final Handler _settingHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
    return const SettingPage();
  });
  static final Handler _newsDetailHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, List<String>> parameters) {
    final Map<String, dynamic>? arguments = context?.settings?.arguments as Map<String, dynamic>?;
    if (arguments != null && arguments['data'] is InfoItem) {
      return NewsDetailPage(data: arguments['data'] as InfoItem);
    }
    return null;
  });

  // Fix: Correct handler for register route
  static final Handler _registerHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
    return const RegisterPage();
  });
  
  static final Handler _roomManageHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
    return const RoomManagePage();
  });
  
  static final Handler _roomEditHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
    // RoomEditPage will be created to handle room editing
    // It will reuse RoomAddPage with an id parameter
    return const RoomAddPage(isEdit: true);
  });
  
  static final Handler _citySelectionHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
    return const CitySelectionPage();
  });
}

