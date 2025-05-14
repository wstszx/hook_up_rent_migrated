import 'package:flutter/material.dart';
import 'package:hook_up_rent/pages/utils/dio_http.dart';
import 'package:hook_up_rent/config.dart';
import 'package:hook_up_rent/widgets/common_image.dart';
import 'package:hook_up_rent/pages/home/tab_search/data_list.dart'; // Corrected import for RoomListItemData
import 'package:hook_up_rent/widgets/root_list_item_widget.dart'; // 使用现有的房源列表项Widget

class RoomFavoritePage extends StatefulWidget {
  const RoomFavoritePage({super.key});

  @override
  State<RoomFavoritePage> createState() => _RoomFavoritePageState();
}

class _RoomFavoritePageState extends State<RoomFavoritePage> {
  Future<List<RoomListItemData>>? _favoriteFuture;

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    setState(() {
      _favoriteFuture = _getFavorites();
    });
  }

  Future<List<RoomListItemData>> _getFavorites() async {
    try {
      final response = await DioHttp.instance.getRequest(
        '${Config.BaseUrl}api/me/favorites', // 确保Config.BaseUrl末尾有/或者这里api前没有/
        // 如果需要token，DioHttp 实例应该已经处理了
      );
      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> favoriteEntries = response.data as List<dynamic>;
        // 后端返回的是 Favorite 对象的列表，每个对象包含一个 room 字段
        // 我们需要提取 room 字段并转换为 RoomListItemData
        return favoriteEntries.map((entry) {
          // 假设 entry['room'] 包含房源的完整信息
          // 并且 RoomListItemData.fromJson 可以处理这个结构
          // 如果 RoomListItemData.fromJson 需要的是房源本身，而不是 Favorite 条目，需要调整
          // 后端返回的 room 结构: 'title price city district images rentType roomType status'
          // RoomListItemData 需要 id, title, subTitle, imageUrl, price, distance, tags, seeAddress, city
          // 需要进行适配
          var roomData = entry['room'];
          if (roomData == null) {
            // 处理 room 为 null 的情况，例如房源已被删除但收藏记录还在
            return RoomListItemData(
              id: entry['_id'] ?? 'unknown_fav_id', // 使用收藏记录的ID作为备用
              title: '无效的收藏房源',
              imageUrl: 'static/images/loading.jpg', // 默认图片
              price: 0,
              tags: [],
            );
          }
          return RoomListItemData(
            id: roomData['_id'] ?? entry['_id'], // 优先使用房源ID
            title: roomData['title'] ?? '未知标题',
            subTitle: '${roomData['district'] ?? '未知区域'} - ${roomData['roomType'] ?? '未知户型'}',
            imageUrl: (roomData['images'] != null && (roomData['images'] as List).isNotEmpty)
                ? Config.BaseUrl + (roomData['images'] as List)[0] // 假设 images 是一个字符串列表
                : 'static/images/loading.jpg', // 默认图片
            price: roomData['price'] ?? 0,
            tags: roomData['rentType'] != null ? [roomData['rentType']] : [], // 简单示例
            // distance, seeAddress, city 等字段可能需要进一步处理或来自其他地方
          );
        }).toList();
      } else {
        throw Exception('Failed to load favorites: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching favorites: $e');
      throw Exception('Failed to load favorites: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的收藏'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<RoomListItemData>>(
        future: _favoriteFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('加载失败: ${snapshot.error}'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _fetchFavorites,
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final favorites = snapshot.data!;
            return ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final favoriteRoom = favorites[index];
                // 使用 RoomListItemWidget 来展示每个收藏的房源
                // 注意：RoomListItemWidget 可能需要一个 RoomListItemData 类型的对象
                // 或者你可以创建一个新的 Widget 来专门展示收藏项
                return RoomListItemWidget(favoriteRoom);
              },
            );
          } else {
            return const Center(
              child: Text('您还没有收藏任何房源'),
            );
          }
        },
      ),
    );
  }
}