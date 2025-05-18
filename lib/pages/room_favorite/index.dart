import 'package:flutter/material.dart';
import 'package:rent_share/pages/utils/dio_http.dart';
import 'package:rent_share/config.dart';
// import 'package:rent_share/widgets/common_image.dart'; // CommonImage is used within RoomListItemWidget
import 'package:rent_share/pages/home/tab_search/data_list.dart'; // Corrected import for RoomListItemData
import 'package:rent_share/widgets/root_list_item_widget.dart'; // 使用现有的房源列表项Widget
import 'package:rent_share/scoped_model/auth.dart';
import 'package:rent_share/pages/utils/scoped_model_helper.dart';
 
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
    // Defer _fetchFavorites until after the first frame to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) { // Check if the widget is still in the tree
        _fetchFavorites();
      }
    });
  }
 
  Future<void> _fetchFavorites() async {
    if (!mounted) return;
    // Get AuthModel here as context should be ready
    final auth = ScopedModelHelper.getModel<AuthModel>(context);
    print('[RoomFavoritePage] Fetching favorites. IsLogin: ${auth.isLogin}, Token: ${auth.token}');
    
    if (!auth.isLogin) {
      // If not logged in, set future to complete with an empty list or an error
      // For now, let's complete with empty list and show "not logged in" message
      // Or, navigate to login: Navigator.of(context).pushNamed('login');
      // However, this page is typically accessed when logged in.
      // If direct access is possible without login, handle appropriately.
       setState(() {
        _favoriteFuture = Future.value([]); // Or throw an error to show in FutureBuilder
      });
      print('[RoomFavoritePage] User not logged in. Not fetching favorites.');
      return;
    }

    setState(() {
      _favoriteFuture = _getFavorites(auth.token); // Pass token to _getFavorites
    });
  }
 
  Future<List<RoomListItemData>> _getFavorites(String? token) async { // Accept token as parameter
    if (!mounted) return [];

    // Log the token being used for the API call
    print('[RoomFavoritePage] _getFavorites called with token: $token');

    if (token == null || token.isEmpty) {
      print('[RoomFavoritePage] Token is null or empty. Cannot fetch favorites.');
      // Optionally throw an exception to be caught by FutureBuilder
      // throw Exception('User not authenticated.');
      return []; // Return empty list if no token
    }
 
    try {
      final response = await DioHttp.of(context).get(
        '${Config.BaseUrl}api/me/favorites',
        null,
        token,
      );
      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> favoriteEntries = response.data as List<dynamic>;
        
        List<RoomListItemData> mappedFavorites = favoriteEntries.map<RoomListItemData>((entry) {
          var roomData = entry['room'];
          if (roomData == null) {
            return RoomListItemData(
              id: entry['_id']?.toString() ?? 'unknown_fav_id_${DateTime.now().millisecondsSinceEpoch}',
              title: '无效的收藏房源',
              subTitle: '该房源信息已失效',
              imageUrl: 'static/images/loading.jpg',
              price: 0,
              tags: [],
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
            subTitle: '${roomData['district'] ?? '未知区域'} - ${roomData['roomType'] ?? '未知户型'} ${roomData['city'] != null ? '('+roomData['city']+')' : ''}', // City info can be part of subtitle
            imageUrl: imageUrl,
            price: (roomData['price'] as num?)?.toInt() ?? 0, // Ensure price is int
            tags: roomData['rentType'] != null ? [roomData['rentType'] as String] : [],
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
