import 'package:flutter/material.dart';
import 'package:hook_up_rent/pages/home/info/index.dart';
import 'package:hook_up_rent/pages/home/tab_search/data_list.dart';
import 'package:hook_up_rent/widgets/common_swiper.dart';
import 'package:hook_up_rent/widgets/common_tag.dart';
import 'package:hook_up_rent/widgets/common_title.dart';
import 'package:hook_up_rent/widgets/room_appliance.dart';
import 'package:share_plus/share_plus.dart';

class RoomDetailPage extends StatefulWidget {
  const RoomDetailPage({Key? key}) : super(key: key);

  @override
  State<RoomDetailPage> createState() => _RoomDetailPageState();
}

var bottomButtonTextStyle = const TextStyle(color: Colors.white, fontSize: 18);

class _RoomDetailPageState extends State<RoomDetailPage> {
  bool isLike = false; // 是否收藏
  bool showAllText = false; // 是否展开

  @override
  Widget build(BuildContext context) {
    // 获取通过路由传递过来参数
    final item = ModalRoute.of(context)!.settings.arguments as RoomListItemData;
    final showTextTool = item.subTitle.length > 100; // 使用 item.subTitle

    return Scaffold(
      appBar: AppBar(
        title: Text(item.title), // 使用 item.title 作为 AppBar 标题，或者保持 item.id
        actions: [
          IconButton(
            onPressed: () => Share.share('https://www.baidu.com'),
            icon: const Icon(Icons.share),
          )
        ],
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              CommonSwiper(images: [item.imageUrl]), // 使用 item.imageUrl
              CommonTitle(item.title), // 使用 item.title
              Container(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item.price.toString(), // 使用 item.price
                      style: const TextStyle(fontSize: 20, color: Colors.pink),
                    ),
                    const Text(
                      '元/月', // 简化租金描述，因为 RoomListItemData 没有押付信息
                      style: TextStyle(fontSize: 14, color: Colors.pink),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(left: 10, top: 6, bottom: 6),
                child: Wrap(
                  spacing: 4,
                  children: item.tags.map((tag) => CommonTag(tag)).toList(), // 使用 item.tags
                ),
              ),
              const Divider(color: Colors.grey, indent: 10, endIndent: 10),
              Container(
                margin: const EdgeInsets.only(left: 10, right: 10, top: 6),
                child: Wrap(
                  runSpacing: 10,
                  children: [
                    const BaseInfoItem('面积：暂无数据'), // RoomListItemData 没有 size
                    const BaseInfoItem('楼层：详见描述'), // RoomListItemData 没有独立的 floor
                    const BaseInfoItem('户型：详见描述'), // RoomListItemData 没有独立的 roomType
                    const BaseInfoItem('装修：精装'), // 假设默认精装，或可考虑移除/设为暂无
                  ],
                ),
              ),
              const CommonTitle('房屋配置'),
              RoomApplicanceList(const []), // RoomListItemData 没有 applicances
              const CommonTitle('房屋概况'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    Text(item.subTitle, maxLines: showAllText ? null : 5), // 使用 item.subTitle, 调整 maxLines 逻辑
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (showTextTool)
                          GestureDetector(
                            onTap: () => setState(() {
                              showAllText = !showAllText;
                            }),
                            child: Row(
                              children: [
                                Text(showAllText ? '收起' : '展开'), // 调整展开/收起文本
                                Icon(showAllText
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down) // 调整图标
                              ],
                            ),
                          )
                        else
                          Container(), // 保留占位，避免布局跳动
                        TextButton( // 使用 TextButton 增加点击区域和视觉反馈
                            onPressed: () {
                              // TODO: 实现举报功能或导航到举报页面
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('举报功能暂未实现')),
                              );
                            },
                            child: const Text('举报')),
                      ],
                    )
                  ],
                ),
              ),
              const CommonTitle('猜你喜欢'),
              Info(),
              const SizedBox(height: 100),
            ],
          ),
          Positioned(
            width: MediaQuery.of(context).size.width,
            height: 100,
            bottom: 0,
            child: Container(
              color: Colors.grey[200],
              child: Row(
                children: [
                  GestureDetector(
                    child: Container(
                      height: 50,
                      width: 60,
                      margin: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () => setState(() {
                          isLike = !isLike;
                        }),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isLike ? Icons.star : Icons.star_border,
                              color: isLike ? Colors.green : Colors.black,
                              size: 24,
                            ),
                            Text(
                              isLike ? '已收藏' : '收藏',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: (() => Navigator.pushNamed(context, 'test')),
                      child: Container(
                        height: 50,
                        margin: const EdgeInsets.only(right: 5),
                        decoration: BoxDecoration(
                          color: Colors.cyan,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text('联系房东', style: bottomButtonTextStyle),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: (() => Navigator.pushNamed(context, 'test')),
                      child: Container(
                        height: 50,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text('预约看房', style: bottomButtonTextStyle),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class BaseInfoItem extends StatelessWidget {
  final String content;

  const BaseInfoItem(this.content, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 3 * 10) / 2,
      child: Text(content),
    );
  }
}
