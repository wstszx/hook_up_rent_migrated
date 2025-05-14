import 'package:flutter/material.dart';

import '../../../scoped_model/auth.dart';
import '../../utils/scoped_model_helper.dart';

class FunctionButtonItem {
  final String imageUrl;
  final String title;
  final Function? onTapHandle;
  FunctionButtonItem(this.imageUrl, this.title, this.onTapHandle);
}

final List<FunctionButtonItem> list = [
  FunctionButtonItem('static/images/home_profile_record.png', "看房记录",
      (context) => Navigator.pushNamed(context, 'test')),
  FunctionButtonItem('static/images/home_profile_order.png', '我的订单', null),
  FunctionButtonItem('static/images/home_profile_favor.png', '我的收藏', (context) {
    bool isLogin = ScopedModelHelper.getModel<AuthModel>(context).isLogin;
    if (isLogin) {
      Navigator.of(context).pushNamed('room_favorite'); // 假设收藏页面的路由是 'room_favorite'
      return;
    }
    Navigator.of(context).pushNamed('login');
  }),
  FunctionButtonItem('static/images/home_profile_id.png', '身份认证', null),
  FunctionButtonItem('static/images/home_profile_message.png', '联系我们', null),
  FunctionButtonItem('static/images/home_profile_contract.png', '电子合同', null),
  FunctionButtonItem('static/images/home_profile_wallet.png', '钱包', null),
  FunctionButtonItem('static/images/home_profile_house.png', "房屋管理", (context) {
    // bool isLogin = false; // 假设先设置未登录
    bool isLogin = ScopedModelHelper.getModel<AuthModel>(context).isLogin;
    if (isLogin) {
      Navigator.of(context).pushNamed('room_manage');
      return;
    }
    Navigator.of(context).pushNamed('login');
  })
];
