import 'package:flutter/material.dart';
import 'package:rent_share/pages/home/tab_search/data_list.dart';
import 'package:rent_share/widgets/common_image.dart';
import 'package:rent_share/widgets/common_tag.dart';

class RoomListItemWidget extends StatelessWidget {
  final RoomListItemData data;

  const RoomListItemWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        // 导航到房源详情页，并传递房源ID
        Navigator.pushNamed(
          context,
          '/room/${data.id}', // 使用正确的路由名称和参数格式
        );
      },
      child: Container(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: Row(
          children: [
            CommonImage(data.imageUrl, width: 132.5, height: 90),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(data.subTitle,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  Wrap(children: data.tags.map((e) => CommonTag(e)).toList()),
                  Text(
                    '${data.price} 元/每月',
                    style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

