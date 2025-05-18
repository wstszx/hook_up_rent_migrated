// ignore_for_file: use_key_in_widget_constructors

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:rent_share/pages/home/index.dart';
import 'package:rent_share/pages/login.dart';
import 'package:rent_share/pages/register.dart';
import 'package:rent_share/pages/room_add/index.dart';
import 'package:rent_share/pages/room_detail/index.dart';
import 'package:rent_share/pages/room_manage/index.dart';
import 'package:rent_share/pages/setting.dart';
import 'package:rent_share/scoped_model/auth.dart';
import 'package:rent_share/scoped_model/room_filter.dart';
import 'package:rent_share/widgets/page_content.dart';
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
            // initialRoute 和 routes 由 FluroRouter 管理
            onGenerateRoute: router.generator,
            // 如果需要，可以设置一个 home widget 作为默认路由，或者确保 Fluro 定义了 '/'
            // home: const HomePage(), // 或者确保 Routes.home ('/') 指向 HomePage
          ),
        ),
      ),
    );
  }
}

