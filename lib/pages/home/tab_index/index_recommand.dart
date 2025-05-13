import 'package:flutter/material.dart';
import 'package:hook_up_rent/pages/home/tab_index/index_recommand_data.dart';
import 'package:hook_up_rent/pages/home/tab_index/index_recommand_item.dart';
import 'package:hook_up_rent/pages/utils/dio_http.dart';
import 'package:hook_up_rent/scoped_model/city.dart';
import 'package:hook_up_rent/pages/utils/scoped_model_helper.dart';
import 'package:dio/dio.dart'; // Import Dio for Response type if needed

class IndexRecommand extends StatefulWidget {
  const IndexRecommand({super.key});

  @override
  State<IndexRecommand> createState() => _IndexRecommandState();
}

class _IndexRecommandState extends State<IndexRecommand> {
  List<IndexRecommendItem> _recommendations = [];
  bool _isLoading = true;
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
      Map<String, dynamic> params = {'city': cityName};
      print('[Frontend] Fetching recommendations with params: $params');

      final response = await DioHttp.of(context).get('/api/recommendations', params);
      print('[Frontend] Received response from /api/recommendations. Status: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        print('[Frontend] Response data: ${response.data}');
        // Assuming response.data is List<dynamic> where each element is Map<String, dynamic>
        final List<dynamic> dataList = response.data as List<dynamic>;
        print('[Frontend] Parsed dataList length: ${dataList.length}');
        final List<IndexRecommendItem> fetchedItems = dataList.map((item) {
          // Basic type checking before creating the item
          if (item is Map<String, dynamic> &&
              item['title'] is String &&
              item['subTitle'] is String &&
              item['imageUrl'] is String &&
              item['navigateUrl'] is String) {
            return IndexRecommendItem(
              item['title'],
              item['subTitle'],
              // Prepend base URL if imageUrl is relative, otherwise use as is
              // Assuming imageUrl from backend might be relative or absolute
              _resolveImageUrl(item['imageUrl']),
              item['navigateUrl'],
            );
          } else {
            print('Warning: Received invalid recommendation item format: $item');
            // Return a placeholder or skip? Let's skip for now by returning null
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
        throw Exception('Failed to load recommendations: Status code ${response.statusCode}');
      }
    } catch (e, stacktrace) {
      print('Error fetching recommendations: $e\n$stacktrace');
      if (mounted) { // Check if the widget is still in the tree
        setState(() {
          _isLoading = false;
          _error = '获取推荐数据失败';
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
                Text(
                  '更多',
                  style: TextStyle(color: Colors.black54),
                )
              ]),
          const SizedBox(height: 10),
          content, // Display loading, error, empty, or data
        ],
      ),
    );
  }
}
