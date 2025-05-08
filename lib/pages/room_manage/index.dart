import 'package:flutter/material.dart';
import 'package:hook_up_rent/pages/home/tab_search/data_list.dart';
import 'package:hook_up_rent/widgets/common_floating_button.dart';
import 'package:hook_up_rent/widgets/root_list_item_widget.dart';

class RoomManagePage extends StatelessWidget {
  const RoomManagePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: CommonFloatingActionButton(
          '发布房源',
          () => Navigator.pushNamed(context, 'room_add'),
        ),
        appBar: AppBar(
          title: const Text('房屋管理'),
          bottom: const TabBar(tabs: [
            Tab(text: '已租'),
            Tab(text: '空置'),
          ]),
        ),
        body: TabBarView(children: [
          ListView(
            children:
                dataList.map((item) => RoomListItemWidget(data: item)).toList(),
          ),
          ListView(
            children:
                dataList.map((item) => RoomListItemWidget(data: item)).toList(),
          )
        ]),
      ),
    );
  }
}
