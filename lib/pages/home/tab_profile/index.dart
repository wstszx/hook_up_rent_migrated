import 'package:flutter/material.dart';
import 'package:rent_share/pages/home/info/index.dart';
import 'package:rent_share/pages/home/tab_profile/advertisement.dart';
import 'package:rent_share/pages/home/tab_profile/function_button.dart';
import 'package:rent_share/pages/home/tab_profile/header.dart';

class TabProfile extends StatelessWidget {
  const TabProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () => Navigator.pushNamed(context, 'setting'),
              icon: const Icon(Icons.settings))
        ],
      ),
      body: ListView(
        children: [ // 移除 const
          Header(),
          FunctionButton(),
          Advertisement(),
          Info(showTitle: true),
        ],
      ),
    );
  }
}

