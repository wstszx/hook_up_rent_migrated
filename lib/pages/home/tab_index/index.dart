import 'package:flutter/material.dart';
import 'package:hook_up_rent/pages/home/info/index.dart';
import 'package:hook_up_rent/pages/home/tab_index/index_navigator.dart';
import 'package:hook_up_rent/pages/home/tab_index/index_recommand.dart';
import 'package:hook_up_rent/widgets/common_swiper.dart';
import 'package:hook_up_rent/widgets/search_bar/index.dart' as custom;

class TabIndex extends StatelessWidget {
  const TabIndex({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: custom.SearchBar(
          showLocation: true,
          showMap: true,
          inputValue: '',
          onSearch: () { // 点击整个搜索框区域，直接跳转到搜索页
            Navigator.of(context).pushNamed('search');
          },
          onSearchSubmit: (String value) { // 输入后点击键盘搜索按钮
            Navigator.of(context).pushNamed('search', arguments: {'searchWord': value});
          },
        ),
      ),
      body: ListView(
        children: [ // 移除 const
          CommonSwiper(),
          IndexNavigator(),
          IndexRecommand(),
          Info(showTitle: true),
        ],
      ),
    );
  }
}
