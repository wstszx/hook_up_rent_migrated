import 'package:flutter/material.dart';
import 'package:hook_up_rent/pages/utils/dio_http.dart';
import 'package:hook_up_rent/config.dart';
// import 'package:hook_up_rent/widgets/common_image.dart'; // CommonImage is used within RoomListItemWidget
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
    // Ensure context is available and mounted before calling DioHttp.of(context)
    if (!mounted) return;
    setState(() {
      _favoriteFuture = _getFavorites();
    });
  }

  Future<List<RoomListItemData>> _getFavorites() async {
    if (!mounted) return []; // Return empty list if not mounted

    try {
      // Corrected DioHttp call
      final response = await DioHttp.of(context).get(
        '${Config.BaseUrl}api/me/favorites',
      );
      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> favoriteEntries = response.data as List<dynamic>;
        
        List<RoomListItemData> mappedFavorites = favoriteEntries.map<RoomListItemData>((entry) {
          var roomData = entry['room'];
          if (roomData == null) {
            return RoomListItemData(
              id: entry['_id']?.toString() ?? 'unknown_fav_id_${DateTime.now().millisecondsSinceEpoch}',
              title: '无效的收藏房源',
              subTitle: '该房源信息已失效', // Added subTitle for null roomData case
              imageUrl: 'static/images/loading.jpg',
              price: 0,
              tags: [],
              // Ensure all required fields for RoomListItemData are provided
              // Add default values for other fields if necessary, e.g., city, distance
              city: '', // Default city
              distance: 0, // Default distance
              seeAddress: '', // Default seeAddress
            );
          }
          // Ensure imageUrl is correctly formed
          String imageUrl = 'static/images/loading.jpg'; // Default image
          if (roomData['images'] != null && (roomData['images'] as List).isNotEmpty) {
            String rawImageUrl = (roomData['images'] as List)[0] as String;
            if (rawImageUrl.startsWith('http')) {
              imageUrl = rawImageUrl;
            } else {
              // Ensure Config.BaseUrl ends with a slash if rawImageUrl doesn't start with one
              String baseUrl = Config.BaseUrl.endsWith('/') ? Config.BaseUrl : '${Config.BaseUrl}/';
              String imagePath = rawImageUrl.startsWith('/') ? rawImageUrl.substring(1) : rawImageUrl;
              imageUrl = baseUrl + imagePath;
            }
          }

          return RoomListItemData(
            id: roomData['_id']?.toString() ?? entry['_id']?.toString() ?? 'unknown_room_id_${DateTime.now().millisecondsSinceEpoch}',
            title: roomData['title'] ?? '未知标题',
            subTitle: '${roomData['district'] ?? '未知区域'} - ${roomData['roomType'] ?? '未知户型'}',
            imageUrl: imageUrl,
            price: (roomData['price'] as num?)?.toInt() ?? 0, // Ensure price is int
            tags: roomData['rentType'] != null ? [roomData['rentType'] as String] : [],
            // Provide defaults for other potentially missing fields if RoomListItemData requires them
            city: roomData['city'] ?? '',
            distance: (roomData['distance'] as num?)?.toDouble() ?? 0.0, // Example, adjust as needed
            seeAddress: roomData['address'] ?? '', // Example, adjust as needed
          );
        }).toList();
        return mappedFavorites;
      } else {
        throw Exception('Failed to load favorites: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching favorites: $e');
      // It's better to let FutureBuilder handle the error state
      // by rethrowing or returning a future that completes with an error.
      rethrow; // Rethrow the exception to be caught by FutureBuilder
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
                    onPressed: _fetchFavorites, // Retry fetching
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
                // Corrected RoomListItemWidget call
                return RoomListItemWidget(data: favoriteRoom);
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