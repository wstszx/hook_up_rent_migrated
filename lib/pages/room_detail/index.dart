import 'package:flutter/material.dart';
import 'package:hook_up_rent/pages/home/info/index.dart';
import 'package:hook_up_rent/pages/home/tab_search/data_list.dart';
import 'package:hook_up_rent/widgets/common_swiper.dart';
import 'package:hook_up_rent/widgets/common_tag.dart';
import 'package:hook_up_rent/widgets/common_title.dart';
import 'package:hook_up_rent/widgets/room_appliance.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hook_up_rent/pages/utils/dio_http.dart';
import 'package:hook_up_rent/config.dart';
import 'package:hook_up_rent/scoped_model/auth.dart';
import 'package:hook_up_rent/pages/utils/scoped_model_helper.dart';
import 'package:hook_up_rent/pages/utils/common_toast.dart';
 
class RoomDetailPage extends StatefulWidget {
  const RoomDetailPage({Key? key}) : super(key: key);

  @override
  State<RoomDetailPage> createState() => _RoomDetailPageState();
}

var bottomButtonTextStyle = const TextStyle(color: Colors.white, fontSize: 18);

class _RoomDetailPageState extends State<RoomDetailPage> {
  bool isLike = false; // 是否收藏
  bool _isLoadingFavoriteStatus = true; // 加载收藏状态
  bool showAllText = false; // 是否展开
  late RoomListItemData item; // 在 initState 中初始化
 
  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback ensures that ModalRoute.of(context) is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ModalRoute.of(context)!.settings.arguments != null) {
        item = ModalRoute.of(context)!.settings.arguments as RoomListItemData;
        _checkFavoriteStatus();
        if (mounted) { // Ensure the widget is still in the tree
          setState(() {}); // Trigger a rebuild if item is now available
        }
      }
    });
  }
 
  Future<void> _checkFavoriteStatus() async {
    final auth = ScopedModelHelper.getModel<AuthModel>(context);
    if (!auth.isLogin || item.id == null) {
      setState(() {
        isLike = false;
        _isLoadingFavoriteStatus = false;
      });
      return;
    }
    try {
      final response = await DioHttp.instance.getRequest('${Config.BaseUrl}api/me/favorites');
      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> favorites = response.data as List<dynamic>;
        if (mounted) {
          setState(() {
            isLike = favorites.any((fav) => fav['room'] != null && fav['room']['_id'] == item.id);
            _isLoadingFavoriteStatus = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingFavoriteStatus = false;
          });
        }
      }
    } catch (e) {
      print("Error checking favorite status: $e");
      if (mounted) {
        setState(() {
          _isLoadingFavoriteStatus = false;
        });
      }
    }
  }
 
  Future<void> _toggleFavorite() async {
    final auth = ScopedModelHelper.getModel<AuthModel>(context);
    if (!auth.isLogin) {
      Navigator.of(context).pushNamed('login');
      return;
    }
 
    if (item.id == null) {
      CommonToast.showToast('无效的房源ID');
      return;
    }
 
    try {
      if (isLike) { // Currently liked, so unlike
        final response = await DioHttp.instance.deleteRequest(
          '${Config.BaseUrl}api/me/favorites/${item.id}',
        );
        if (response.statusCode == 200) {
          if (mounted) {
            setState(() {
              isLike = false;
            });
          }
          CommonToast.showToast('已取消收藏');
        } else {
          CommonToast.showToast('取消收藏失败: ${response.data?['message'] ?? '请稍后再试'}');
        }
      } else { // Currently not liked, so like
        final response = await DioHttp.instance.postRequest(
          '${Config.BaseUrl}api/me/favorites',
          data: {'roomId': item.id},
        );
        if (response.statusCode == 201) {
          if (mounted) {
            setState(() {
              isLike = true;
            });
          }
          CommonToast.showToast('收藏成功');
        } else {
          CommonToast.showToast('收藏失败: ${response.data?['message'] ?? '请稍后再试'}');
        }
      }
    } catch (e) {
      CommonToast.showToast('操作失败，请检查网络连接');
      print("Error toggling favorite: $e");
    }
  }
 
  @override
  Widget build(BuildContext context) {
    // Ensure item is initialized before building UI that depends on it.
    // This check is important if initState's postFrameCallback hasn't run yet or item wasn't passed.
    if (ModalRoute.of(context)?.settings.arguments == null && !this::item.isInitialized) {
        // If arguments are null and item is not initialized, show loading or error.
        // This scenario should ideally be handled by a loading screen or an error message
        // if item is critical for the page. For now, returning an empty container.
        return Scaffold(appBar: AppBar(title: const Text("房源详情")), body: const Center(child: Text("加载中或房源信息错误...")));
    }
    // If item is not initialized yet but arguments are present, it means initState is about to set it.
    // A temporary loading state can be shown.
     if (!this::item.isInitialized) {
        item = ModalRoute.of(context)!.settings.arguments as RoomListItemData;
     }


    final showTextTool = item.subTitle.length > 100;
 
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
                        onTap: _isLoadingFavoriteStatus ? null : _toggleFavorite, // Disable while loading status
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _isLoadingFavoriteStatus
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Icon(
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
