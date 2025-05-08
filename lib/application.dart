// ignore_for_file: use_key_in_widget_constructors

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:hook_up_rent/pages/home/index.dart';
import 'package:hook_up_rent/pages/login.dart';
import 'package:hook_up_rent/pages/register.dart';
import 'package:hook_up_rent/pages/room_add/index.dart';
import 'package:hook_up_rent/pages/room_detail/index.dart';
import 'package:hook_up_rent/pages/room_manage/index.dart';
import 'package:hook_up_rent/pages/setting.dart';
import 'package:hook_up_rent/scoped_model/auth.dart';
import 'package:hook_up_rent/scoped_model/room_filter.dart';
import 'package:hook_up_rent/widgets/page_content.dart';
import 'package:scoped_model/scoped_model.dart';

import 'pages/routes.dart';
import 'scoped_model/city.dart';

class Application extends StatelessWidget {
  const Application({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FluroRouter router = FluroRouter();
    Routes.configureRoutes(router);
    // 监听路由变化
    return ScopedModel<AuthModel>(
      model: AuthModel(),
      child: ScopedModel<CityModel>(
        model: CityModel(),
        child: ScopedModel<FilterBarModel>(
          model: FilterBarModel(),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(primarySwatch: Colors.green),
            initialRoute: '/',
            routes: {
              '/': (context) => const HomePage(),
              'login': (context) => const LoginPage(),
              'register': (context) => const RegisterPage(),
              'setting': ((context) => const SettingPage()),
              'search': (context) => const PageContent(name: '搜索'),
              'room_manage': (context) => const RoomManagePage(),
              'room_add': (context) => const RoomAddPage(),
              'room_detail': (context) => const RoomDetailPage(),
              'test': (context) => const PageContent(name: '开发中...'),
            },
          ),
        ),
      ),
    );
  }
}
