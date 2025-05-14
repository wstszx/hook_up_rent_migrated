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
  late RoomListItemData item;
  bool _isItemInitialized = false; // 标记 item 是否已初始化

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments != null && arguments is RoomListItemData) {
        item = arguments;
        _isItemInitialized = true; // 标记 item 已初始化
        _checkFavoriteStatus();
        if (mounted) {
          setState(() {}); // 触发重建以使用 item
        }
      } else {
        // 处理参数错误或缺失的情况
        if (mounted) {
          setState(() {
            _isItemInitialized = false; // 标记 item 未成功初始化
            _isLoadingFavoriteStatus = false; // 也停止加载收藏状态
          });
        }
        print("Error: RoomListItemData not passed as argument or argument is null.");
        // Optionally, navigate back or show an error message
      }
    });
  }

  Future<void> _checkFavoriteStatus() async {
    if (!_isItemInitialized) return; // 如果 item 未初始化，则不执行

    final auth = ScopedModelHelper.getModel<AuthModel>(context);
    // item.id can be null if RoomListItemData allows it, ensure to handle
    if (!auth.isLogin || item.id.isEmpty) { // Assuming id is String and checking for empty
      if (mounted) {
        setState(() {
          isLike = false;
          _isLoadingFavoriteStatus = false;
        });
      }
      return;
    }
    try {
      // 使用 DioHttp.of(context).get
      final String? token = auth.token; // Get token from AuthModel
      final response = await DioHttp.of(context).get(
        '${Config.BaseUrl}api/me/favorites',
        null, // params
        token, // Pass token
      );
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
    if (!_isItemInitialized) return; // 如果 item 未初始化，则不执行

    final auth = ScopedModelHelper.getModel<AuthModel>(context);
    if (!auth.isLogin) {
      Navigator.of(context).pushNamed('login');
      return;
    }

    if (item.id.isEmpty) { // Assuming id is String and checking for empty
      CommonToast.showToast('无效的房源ID');
      return;
    }

    try {
      if (isLike) { // Currently liked, so unlike
        // 使用 DioHttp.of(context).delete
        final String? token = auth.token; // Get token
        final response = await DioHttp.of(context).delete(
          '${Config.BaseUrl}api/me/favorites/${item.id}',
          null, // params
          token, // Pass token
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
        // 使用 DioHttp.of(context).post
        final String? token = auth.token; // Get token
        final response = await DioHttp.of(context).post(
          '${Config.BaseUrl}api/me/favorites',
          data: {'roomId': item.id},
          token: token, // Pass token
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
 
  Future<void> _makeAppointment() async {
    if (!_isItemInitialized) return;
 
    final auth = ScopedModelHelper.getModel<AuthModel>(context);
    if (!auth.isLogin) {
      Navigator.of(context).pushNamed('login');
      return;
    }
 
    if (item.id.isEmpty) {
      CommonToast.showToast('无效的房源ID');
      return;
    }
 
    // 可选：允许用户输入预约时间或备注
    // final DateTime? appointmentTime = await showDatePicker(...);
    // final String? notes = await showDialog(...); // 获取备注
 
    try {
      final String? token = auth.token;
      final response = await DioHttp.of(context).post(
        '${Config.BaseUrl}api/me/orders',
        data: {
          'roomId': item.id,
          // 'appointmentTime': appointmentTime?.toIso8601String(), // 如果有选择时间
          // 'notes': notes, // 如果有备注
        },
        token: token,
      );
 
      if (response.statusCode == 201) {
        CommonToast.showToast('预约成功，已添加到我的订单');
        // 可选：跳转到我的订单页面
        // Navigator.of(context).pushNamed(Routes.myOrders);
      } else {
        CommonToast.showToast('预约失败: ${response.data?['message'] ?? '请稍后再试'}');
      }
    } catch (e) {
      CommonToast.showToast('预约操作失败，请检查网络连接');
      print("Error making appointment: $e");
    }
  }
 
  @override
  Widget build(BuildContext context) {
    if (!_isItemInitialized) {
      // 如果 item 未初始化 (例如，路由参数问题或 initState 回调尚未完成)
      return Scaffold(
        appBar: AppBar(title: const Text("房源详情")),
        body: const Center(child: CircularProgressIndicator()), // 显示加载指示器
      );
    }

    final showTextTool = item.subTitle.length > 100;

    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
        actions: [
          IconButton(
            onPressed: () => Share.share('https://www.baidu.com'), // 示例分享链接
            icon: const Icon(Icons.share),
          )
        ],
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              CommonSwiper(images: [item.imageUrl]),
              CommonTitle(item.title),
              Container(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item.price.toString(),
                      style: const TextStyle(fontSize: 20, color: Colors.pink),
                    ),
                    const Text(
                      '元/月',
                      style: TextStyle(fontSize: 14, color: Colors.pink),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(left: 10, top: 6, bottom: 6),
                child: Wrap(
                  spacing: 4,
                  children: item.tags.map((tag) => CommonTag(tag)).toList(),
                ),
              ),
              const Divider(color: Colors.grey, indent: 10, endIndent: 10),
              Container(
                margin: const EdgeInsets.only(left: 10, right: 10, top: 6),
                child: Wrap(
                  runSpacing: 10,
                  children: [
                    const BaseInfoItem('面积：暂无数据'),
                    const BaseInfoItem('楼层：详见描述'),
                    const BaseInfoItem('户型：详见描述'),
                    const BaseInfoItem('装修：精装'),
                  ],
                ),
              ),
              const CommonTitle('房屋配置'),
              RoomApplicanceList(const []), // 假设没有 appliance 数据
              const CommonTitle('房屋概况'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    Text(item.subTitle, maxLines: showAllText ? null : 5),
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
                                Text(showAllText ? '收起' : '展开'),
                                Icon(showAllText
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down)
                              ],
                            ),
                          )
                        else
                          Container(),
                        TextButton(
                            onPressed: () {
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
              const SizedBox(height: 100), // 为底部按钮留出空间
            ],
          ),
          Positioned(
            width: MediaQuery.of(context).size.width,
            height: 100,
            bottom: 0,
            child: Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.all(10), // 统一内边距
              child: Row(
                children: [
                  GestureDetector(
                     onTap: _isLoadingFavoriteStatus ? null : _toggleFavorite,
                    child: Container(
                      // Removed fixed width to allow flexibility or define it if necessary
                      padding: const EdgeInsets.symmetric(horizontal: 10), // Add padding for tap area
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
                          const SizedBox(height: 4), // Spacing
                          Text(
                            isLike ? '已收藏' : '收藏',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10), // Spacing between buttons
                  Expanded(
                    child: ElevatedButton( // Using ElevatedButton for better semantics and styling
                      onPressed: () => Navigator.pushNamed(context, 'test'), // Placeholder
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
                      child: Text('联系房东', style: bottomButtonTextStyle),
                    ),
                  ),
                  const SizedBox(width: 10), // Spacing
                  Expanded(
                    child: ElevatedButton( // Using ElevatedButton
                      onPressed: _makeAppointment, // 调用新的预约方法
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: Text('预约看房', style: bottomButtonTextStyle),
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
      width: (MediaQuery.of(context).size.width - 3 * 10) / 2, // Adjust width calculation if padding changes
      child: Text(content),
    );
  }
}
