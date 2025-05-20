import 'package:flutter/material.dart';
import 'package:rent_share/pages/home/info/index.dart';
import 'package:rent_share/widgets/search_bar/index.dart' as custom;

class TabInfo extends StatefulWidget {
  const TabInfo({Key? key}) : super(key: key);

  @override
  State<TabInfo> createState() => _TabInfoState();
}

class _TabInfoState extends State<TabInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: custom.SearchBar(
          inputValue: '',
          onSearch: () {
            Navigator.of(context).pushNamed('search');
          },
        ),
      ),
      body: ListView(children: [
        SizedBox(height: 15),
        Info(), // 只保留一个 Info() widget
      ]),
    );
  }
}

