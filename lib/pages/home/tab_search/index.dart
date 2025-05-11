import 'package:flutter/material.dart';
import 'package:hook_up_rent/config.dart';
import 'package:hook_up_rent/pages/home/tab_search/data_list.dart';
import 'package:hook_up_rent/pages/home/tab_search/filter_bar/filter_drawer.dart';
import 'package:hook_up_rent/pages/home/tab_search/filter_bar/index.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchRoomsData();
  }

  Future<void> _fetchRoomsData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await DioHttp.of(context).get(
        '/api/rooms',
        {'rentType': '整租'},
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
          const SizedBox(
            height: 41,
            child: FilterBar(),
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
