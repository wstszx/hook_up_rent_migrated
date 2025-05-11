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
    if (apiParams['rentType'] == null || (apiParams['rentType'] as String).isEmpty) {
       // 如果 FilterBarResult 中没有 rentType，或者为空，则默认为 '整租'
       // 如果 FilterBarResult 中有 rentType 且不为空，则使用 FilterBarResult 中的值
       // 这里的逻辑是，如果用户通过筛选明确选择了其他 rentType，则使用用户的选择
       // 如果用户没有通过筛选选择 rentType（例如清除了筛选），则默认为 '整租'
       // 或者，如果 _currentFilterParams 本身就是 null (初始加载)，也默认为 '整租'
      if (_currentFilterParams == null || _currentFilterParams?.rentTypeId == null || _currentFilterParams!.rentTypeId!.isEmpty || _currentFilterParams!.rentTypeId == 'rent_type_any') {
        apiParams['rentType'] = '整租';
      }
      // 如果 _currentFilterParams.rentTypeId 有具体值 (不是 'rent_type_any' 且不为空),
      // 那么 toMap() 已经将其加入 apiParams，这里不需要再覆盖。
    }


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
