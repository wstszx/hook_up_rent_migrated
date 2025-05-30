import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rent_share/config.dart';
import 'package:rent_share/widgets/common_check_button.dart';

class RoomApplianceItem {
  final String title;
  final int iconPoint;
  final bool isChecked;

  const RoomApplianceItem(this.title, this.iconPoint, this.isChecked);
}

const List<RoomApplianceItem> _dataList = [
  RoomApplianceItem('衣柜', 0xe918, false),
  RoomApplianceItem('洗衣机', 0xe917, false),
  RoomApplianceItem('空调', 0xe90d, false),
  RoomApplianceItem('天然气', 0xe90f, false),
  RoomApplianceItem('冰箱', 0xe907, false),
  RoomApplianceItem('暖气', 0xe910, false),
  RoomApplianceItem('电视', 0xe908, false),
  RoomApplianceItem('热水器', 0xe912, false),
  RoomApplianceItem('宽带', 0xe90e, false),
  RoomApplianceItem('沙发', 0xe913, false),
];

class RoomAppliance extends StatefulWidget {
  final ValueChanged<List<RoomApplianceItem>>? onChange;

  const RoomAppliance(this.onChange, {super.key});

  @override
  State<RoomAppliance> createState() => _RoomApplianceState();
}

class _RoomApplianceState extends State<RoomAppliance> {
  List<RoomApplianceItem> list = _dataList;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 20,
      children: list
          .map((item) => GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  setState(() {
                    list = list
                        .map((inItem) => (inItem == item)
                            ? RoomApplianceItem(
                                item.title,
                                item.iconPoint,
                                !item.isChecked,
                              )
                            : inItem)
                        .toList();
                  });
                  if (widget.onChange != null) {
                    widget.onChange!(list);
                  }
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 5,
                  child: Column(
                    children: [
                      Icon(
                        IconData(item.iconPoint, fontFamily: Config.CommonIcon),
                        size: 40,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(item.title),
                      ),
                      CommonCheckButton(item.isChecked),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class RoomApplicanceList extends StatelessWidget {
  final List<String> list;

  const RoomApplicanceList(this.list, {super.key});

  @override
  Widget build(BuildContext context) {
    final showList =
        _dataList.where((item) => list.contains(item.title)).toList();
    // showList = Random().nextInt(5) % 2 == 0 ? [] : showList; // Removed random behavior
    if (showList.isEmpty) {
      return Container(
        padding: const EdgeInsets.only(left: 10),
        child: const Text('暂无房屋配置信息'),
      );
    }

    return Wrap(
      runSpacing: 20,
      children: showList
          .map((item) => SizedBox(
                width: MediaQuery.of(context).size.width / 5,
                child: Column(
                  children: [
                    Icon(
                      IconData(item.iconPoint, fontFamily: Config.CommonIcon),
                      size: 40,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(item.title),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

