import 'package:flutter/material.dart';
import 'package:rent_share/pages/home/info/index.dart';
import 'package:rent_share/pages/home/tab_search/data_list.dart';
import 'package:rent_share/widgets/common_swiper.dart';
import 'package:rent_share/widgets/common_tag.dart';
import 'package:rent_share/widgets/common_title.dart';
import 'package:rent_share/widgets/room_appliance.dart';
import 'package:share_plus/share_plus.dart';
import 'package:rent_share/pages/utils/dio_http.dart';
import 'package:rent_share/config.dart';
import 'package:rent_share/scoped_model/auth.dart';
import 'package:rent_share/pages/utils/scoped_model_helper.dart';
import 'package:rent_share/pages/utils/common_toast.dart';

class RoomDetailPage extends StatefulWidget {
  final String? houseId;
  const RoomDetailPage({Key? key, this.houseId}) : super(key: key);

  @override
  State<RoomDetailPage> createState() => _RoomDetailPageState();
}

var bottomButtonTextStyle = const TextStyle(color: Colors.white, fontSize: 18);

class _RoomDetailPageState extends State<RoomDetailPage> {
  bool isLike = false;
  bool _isLoadingFavoriteStatus = true;
  bool showAllText = false;
  late RoomListItemData item;
  bool _isItemInitialized = false;

  Future<void> _loadHouseData(String houseId) async {
    try {
      final response = await DioHttp.of(context).get(
        '${Config.BaseUrl}api/rooms/$houseId',
        null,
        null,
      );
      if (response.statusCode == 200 && response.data != null) {
        final roomData = response.data;
        setState(() {
          item = RoomListItemData(
            id: roomData['_id'] ?? '',
            title: roomData['title'] ?? '',
            subTitle: '${roomData['district'] ?? ''} ${roomData['roomType'] ?? ''}',
            imageUrl: roomData['images']?.isNotEmpty == true ? roomData['images'][0] : '',
            price: (roomData['price'] as num?)?.toInt() ?? 0,
            tags: roomData['tags']?.cast<String>() ?? [],
          );
          _isItemInitialized = true;
          _checkFavoriteStatus();
        });
      }
    } catch (e) {
      print('加载房源数据失败: $e');
      if (mounted) {
        setState(() {
          _isItemInitialized = false;
          _isLoadingFavoriteStatus = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.houseId != null) {
      _loadHouseData(widget.houseId!);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final arguments = ModalRoute.of(context)?.settings.arguments;
        if (arguments != null && arguments is RoomListItemData) {
          setState(() {
            item = arguments;
            _isItemInitialized = true;
            _checkFavoriteStatus();
          });
        } else {
          setState(() {
            _isItemInitialized = false;
            _isLoadingFavoriteStatus = false;
          });
          print("Error: RoomListItemData not passed as argument or argument is null.");
        }
      });
    }
  }

  Future<void> _checkFavoriteStatus() async {
    if (!_isItemInitialized) return;

    final auth = ScopedModelHelper.getModel<AuthModel>(context);
    if (!auth.isLogin || item.id.isEmpty) {
      if (mounted) {
        setState(() {
          isLike = false;
          _isLoadingFavoriteStatus = false;
        });
      }
      return;
    }

    try {
      final String? token = auth.token;
      final response = await DioHttp.of(context).get(
        '${Config.BaseUrl}api/me/favorites',
        null,
        token,
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

    try {
      final String? token = auth.token;
      if (isLike) {
        final response = await DioHttp.of(context).delete(
          '${Config.BaseUrl}api/me/favorites/${item.id}',
          null,
          token,
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
      } else {
        final response = await DioHttp.of(context).post(
          '${Config.BaseUrl}api/me/favorites',
          data: {'roomId': item.id},
          token: token,
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

    try {
      final String? token = auth.token;
      final response = await DioHttp.of(context).post(
        '${Config.BaseUrl}api/me/orders',
        data: {
          'roomId': item.id,
        },
        token: token,
      );

      if (response.statusCode == 201) {
        CommonToast.showToast('预约成功，已添加到我的预约');
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
      return Scaffold(
        appBar: AppBar(title: const Text("房源详情")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final showTextTool = item.subTitle.length > 100;

    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
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
                child: const Wrap(
                  runSpacing: 10,
                  children: [
                    BaseInfoItem('面积：暂无数据'),
                    BaseInfoItem('楼层：详见描述'),
                    BaseInfoItem('户型：详见描述'),
                    BaseInfoItem('装修：精装'),
                  ],
                ),
              ),
              const CommonTitle('房屋配置'),
              RoomApplicanceList(const []),
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
                          child: const Text('举报'),
                        ),
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
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _isLoadingFavoriteStatus ? null : _toggleFavorite,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
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
                          const SizedBox(height: 4),
                          Text(
                            isLike ? '已收藏' : '收藏',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, 'test'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
                      child: Text('联系房东', style: bottomButtonTextStyle),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _makeAppointment,
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
      width: (MediaQuery.of(context).size.width - 3 * 10) / 2,
      child: Text(content),
    );
  }
}

