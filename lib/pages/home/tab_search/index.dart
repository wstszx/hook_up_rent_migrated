import 'package:flutter/material.dart';
import 'package:hook_up_rent/config.dart';
import 'package:hook_up_rent/pages/home/tab_search/data_list.dart';
import 'package:hook_up_rent/pages/home/tab_search/filter_bar/filter_drawer.dart';
import 'package:hook_up_rent/pages/home/tab_search/filter_bar/index.dart';
import 'package:hook_up_rent/pages/home/tab_search/filter_bar/data.dart' as filter_data; // Added import
import 'package:hook_up_rent/pages/utils/dio_http.dart';
import 'package:hook_up_rent/widgets/root_list_item_widget.dart';
import 'package:hook_up_rent/widgets/search_bar/index.dart' as custom;

class TabSearch extends StatefulWidget {
  const TabSearch({Key? key}) : super(key: key);

  @override
  State<TabSearch> createState() => _TabSearchState();
}

class _TabSearchState extends State<TabSearch> {
  List<RoomListItemData> _roomList = [];
  bool _isLoading = true;
  filter_data.FilterBarResult? _currentFilterParams; // 用于存储当前的筛选参数

  @override
  void initState() {
    super.initState();
    // 初始加载时 _currentFilterParams 为 null，_fetchRoomsData 会处理默认参数
    _fetchRoomsData();
  }

  Future<void> _fetchRoomsData() async {
    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> apiParams = {};

    if (_currentFilterParams != null) {
      apiParams = _currentFilterParams!.toMap();
    }

    // 确保 '整租' 页面默认筛选 rentType，除非已被其他筛选覆盖
    // Room.js 定义 rentType 是必需的，所以这里确保它存在
    // 仅当 FilterBar 没有提供 rentType (例如初始加载，或 FilterBarResult.rentTypeId 为 null/empty)
    // 并且用户没有在 FilterBar 中明确选择 "不限" (rent_type_any) 时，才默认设置为 '整租'。
    // 如果用户在 FilterBar 中选择了 "不限"，则 apiParams['rentType'] 应该保持为 null，以便后端返回所有类型。
    if (!apiParams.containsKey('rentType')) { // 如果 toMap() 没有设置 rentType (即用户选了 "不限" 或 rentTypeId 为空)
      if (_currentFilterParams == null || // 初始加载
          _currentFilterParams?.rentTypeId == null || // rentTypeId 为空
          _currentFilterParams!.rentTypeId!.isEmpty) { // rentTypeId 为空字符串
        // 在这些情况下，我们才默认设置为 '整租'
        apiParams['rentType'] = '整租';
      }
      // 如果 _currentFilterParams.rentTypeId == 'rent_type_any'，
      // 那么 toMap() 不会设置 apiParams['rentType']，这里也不应该设置，从而实现 "不限" 的效果。
    }

print('[TabSearch] Final apiParams for /api/rooms: $apiParams');

    try {
      final response = await DioHttp.of(context).get(
        '/api/rooms',
        apiParams, // 使用动态构建的参数
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> responseData = response.data!;
        final List<dynamic> roomsData = responseData['rooms'] as List<dynamic>;
        
        final List<RoomListItemData> fetchedRooms = roomsData.map((item) {
          var room = item as Map<String, dynamic>;
          // 构造 subTitle
          String subTitle = "${room['roomType'] ?? ''}";
          if (room['floor'] != null && room['floor'].isNotEmpty) {
            subTitle += "/${room['floor']}";
          }
          if (room['orientation'] != null && room['orientation'].isNotEmpty) {
            subTitle += "/${room['orientation']}";
          }
          if (room['district'] != null && room['district'].isNotEmpty) {
            subTitle += "/${room['district']}";
          }
           if (room['address'] != null && room['address'].isNotEmpty) {
            subTitle += " ${room['address']}";
          }

          // 处理图片 URL
          String imageUrl = Config.DefaultImage; // 默认图片
          if (room['images'] != null && (room['images'] as List).isNotEmpty) {
            String rawImageUrl = (room['images'] as List)[0] as String;
            if (rawImageUrl.startsWith('/')) {
              imageUrl = Config.BaseUrl + rawImageUrl;
            } else {
              imageUrl = rawImageUrl; // 假定已经是完整 URL
            }
          }
          
          return RoomListItemData(
            id: room['_id']?.toString() ?? '',
            title: room['title']?.toString() ?? '未知标题',
            subTitle: subTitle.trim(),
            imageUrl: imageUrl,
            tags: List<String>.from(room['tags'] ?? []),
            price: (room['price'] as num?)?.toInt() ?? 0,
          );
        }).toList();

        setState(() {
          _roomList = fetchedRooms;
          _isLoading = false;
        });
      } else {
        // Handle error or empty response
        print('Failed to load rooms: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching rooms: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const FilterDrawer(),
      appBar: AppBar(
        actions: [Container()], // 去除 endDrawer 的默认按钮
        elevation: 0,
        title: custom.SearchBar(
          showLocation: true,
          showMap: true,
          inputValue: '',
          onSearch: () {
            Navigator.of(context).pushNamed('search');
          },
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 41, // FilterBar 的固定高度
            child: FilterBar(
              onChange: (filter_data.FilterBarResult result) {
                setState(() {
                  _currentFilterParams = result;
                });
                _fetchRoomsData(); // 当筛选条件改变时，重新获取数据
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _roomList.isEmpty
                    ? const Center(child: Text('暂无房源数据'))
                    : ListView.builder(
                        itemCount: _roomList.length,
                        itemBuilder: (context, index) {
                          return RoomListItemWidget(data: _roomList[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
