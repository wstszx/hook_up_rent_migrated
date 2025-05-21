import 'package:flutter/material.dart';
import 'package:rent_share/pages/home/tab_index/index_recommand_data.dart';
import 'package:rent_share/pages/home/tab_index/index_recommand_item.dart';
import 'package:rent_share/pages/utils/dio_http.dart';
import 'package:rent_share/scoped_model/city.dart';
import 'package:rent_share/pages/utils/scoped_model_helper.dart';
import 'package:dio/dio.dart';
import 'package:rent_share/pages/home/tab_search/data_list.dart';

class IndexRecommand extends StatefulWidget {
  const IndexRecommand({super.key});

  @override
  State<IndexRecommand> createState() => _IndexRecommandState();
}

class _IndexRecommandState extends State<IndexRecommand> {
  List<IndexRecommendItem> _recommendations = [];
  bool _isLoading = false;
  String? _error;
  // bool _isDataFetched = false; // Flag to ensure data is fetched only once - REMOVED

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Always attempt to fetch; _fetchRecommendations will decide if it's appropriate
    _fetchRecommendations();
  }

  Future<void> _fetchRecommendations() async {
    final cityModel = ScopedModelHelper.getModel<CityModel>(context);
    final currentCity = cityModel.city;
    final cityName = currentCity?.name;
    print('[Frontend] _fetchRecommendations called. Current city: ${currentCity?.name} (ID: ${currentCity?.id})');

    if (cityName == null || cityName.isEmpty) {
      print('[Frontend] City name is null or empty. Waiting for city information.');
      if (mounted) {
        setState(() {
          _isLoading = false; // Not loading recommendations yet
          _recommendations = []; // Clear any previous recommendations
          _error = '请先选择或等待城市加载'; // User-friendly message
        });
      }
      return; // Do not proceed to fetch recommendations
    }

    // If already loading, prevent re-entry.
    // This check should ideally be more sophisticated if city can change rapidly
    // or if fetches for different cities can be queued, but for now, it prevents simple re-entry.
    if (_isLoading) {
      print('[Frontend] Already loading recommendations for $cityName. Skipping.');
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null; // Clear previous errors before a new fetch
      });
    }

    try {
      // Fetch all rooms for the current city
      Map<String, dynamic> params = {'city': cityName}; // Use city name as parameter
      print('[Frontend] Fetching rooms with params: $params');

      final response = await DioHttp.of(context).get('/api/rooms', params); // Call /api/rooms
      print('[Frontend] Received response from /api/rooms. Status: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        print('[Frontend] Response data: ${response.data}');
        // Assuming response.data['rooms'] is a list of room objects
        final List<dynamic> roomList = response.data['rooms'] as List<dynamic>;
        print('[Frontend] Parsed roomList length: ${roomList.length}');

        // Shuffle and take up to 4 random rooms
        roomList.shuffle();
        final List<dynamic> selectedRooms = roomList.take(4).toList();

        final List<IndexRecommendItem> fetchedItems = selectedRooms.map((room) {
          // Map room data to IndexRecommendItem format
          // Assuming room object has 'title', 'price', 'imageUrl', '_id'
          if (room is Map<String, dynamic> &&
              room['title'] is String &&
              room['price'] != null && // Price can be int or double
              room['images'] is List && // Check if images is a list
              room['_id'] is String) {
             String imageUrl = '';
            if ((room['images'] as List).isNotEmpty) {
              imageUrl = (room['images'] as List)[0] as String; // Use the first image
            }
            return IndexRecommendItem(
              room['title'], // Use room title
              '${room['price']}元/月', // Use room price as subtitle
              _resolveImageUrl(imageUrl), // Use room image URL
              '/room/${room['_id']}', // Navigate to room detail page using room ID
            );
          } else {
            print('Warning: Received invalid room item format: $room');
            return null;
          }
        }).whereType<IndexRecommendItem>().toList(); // Filter out any nulls

        if (mounted) { // Check if the widget is still in the tree
          setState(() {
            _recommendations = fetchedItems;
            _isLoading = false;
            _error = null;
          });
        }
      } else {
        throw Exception('Failed to load rooms: Status code ${response.statusCode}');
      }
    } catch (e, stacktrace) {
      print('Error fetching rooms: $e\n$stacktrace');
      if (mounted) { // Check if the widget is still in the tree
        setState(() {
          _isLoading = false;
          _error = '获取房源数据失败';
        });
      }
    }
  }

  // Helper to potentially resolve image URLs (adjust if needed based on backend data)
  String _resolveImageUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url; // Already absolute
    }
    // Assuming relative URLs need the base URL from DioHttp or Config
    // Adjust this logic based on how image URLs are stored/served
    // Example: return DioHttp.of(context)._client!.options.baseUrl + url;
    // For now, let's assume backend provides full URLs or relative paths handled elsewhere
    return url;
  }


  @override
  Widget build(BuildContext context) {
    // Calculate item width (same logic as before)
    final screenWidth = MediaQuery.of(context).size.width;
    final wrapAvailableWidth = screenWidth - 2 * 10;
    double itemWidth = (wrapAvailableWidth - 10) / 2;
    if (itemWidth < 0) itemWidth = 50;

    Widget content;
    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      content = Center(child: Text(_error!));
    } else if (_recommendations.isEmpty) {
      content = const Center(child: Text('暂无推荐房源'));
    } else {
      content = Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _recommendations
            .map((item) => IndexRecommandItemWidget(data: item, width: itemWidth))
            .toList(),
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(color: Color(0x08000000)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align title to the start
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  '房屋推荐',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600),
                ),
              ]),
          const SizedBox(height: 10),
          content, // Display loading, error, empty, or data
        ],
      ),
    );
  }
}

