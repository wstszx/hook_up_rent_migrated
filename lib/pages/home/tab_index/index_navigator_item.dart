import 'package:flutter/material.dart';
import 'package:hook_up_rent/pages/utils/scoped_model_helper.dart'; // 引入ScopedModelHelper
import 'package:hook_up_rent/scoped_model/auth.dart'; // 引入AuthModel

// 点击导航区域传递的数据结构：包含 导航名称、图片、点击事件
class IndexNavigatorItem {
  final String title;
  final String imageUrl;
  final Function(BuildContext contenxt) onTap;
  IndexNavigatorItem(this.title, this.imageUrl, this.onTap);
}

List<IndexNavigatorItem> indexNavigatorItemList = [
  IndexNavigatorItem('整租', 'static/images/home_index_navigator_total.png',
      (BuildContext context) {
    // 导航到搜索页，并传递 '整租' 作为参数
    // 假设 '/search' 路由可以处理 rentType 参数
    Navigator.of(context).pushNamed('/search', arguments: {'rentType': '整租'});
  }),
  IndexNavigatorItem('合租', 'static/images/home_index_navigator_share.png',
      (BuildContext context) {
    // 导航到搜索页，并传递 '合租' 作为参数
    Navigator.of(context).pushNamed('/search', arguments: {'rentType': '合租'});
  }),
  IndexNavigatorItem('地图找房', 'static/images/home_index_navigator_map.png',
      (BuildContext context) {
    // 假设地图页的路由是 '/map'
    Navigator.of(context).pushNamed('/map');
  }),
  IndexNavigatorItem('去出租', 'static/images/home_index_navigator_rent.png',
      (BuildContext context) {
    var isLogin = ScopedModelHelper.getModel<AuthModel>(context).isLogin;
    if (isLogin) {
      // 假设房源发布页的路由是 '/room-add'
      Navigator.of(context).pushNamed('/room-add');
    } else {
      Navigator.of(context).pushNamed('login');
    }
  }),
];
