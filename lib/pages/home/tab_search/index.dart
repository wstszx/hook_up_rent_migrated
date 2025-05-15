import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:hook_up_rent/scoped_model/city.dart';
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
  String _currentSearchWord = ''; // 用于存储当前搜索词

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // didChangeDependencies 会处理初始的 searchWord
        // _fetchRoomsData(); // 移除这里的直接调用，让 didChangeDependencies 控制首次加载
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 获取路由参数
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String? initialSearchWord = arguments?['searchWord'] as String?;

    if (initialSearchWord != null && initialSearchWord.isNotEmpty) {
      setState(() {
        _currentSearchWord = initialSearchWord;
      });
    }
    // 无论是否有初始搜索词，都获取一次数据
    // 如果有搜索词，_fetchRoomsData 会使用它
    // 如果没有，_fetchRoomsData 会按现有逻辑（筛选条件、默认城市）获取
    _fetchRoomsData(searchWord: _currentSearchWord);
  }

  Future<void> _fetchRoomsData({String? searchWord}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> apiParams = {};

    if (_currentFilterParams != null) {
      apiParams = _currentFilterParams!.toMap();
    }

    // 添加搜索词到 API 参数
    if (searchWord != null && searchWord.isNotEmpty) {
      apiParams['q'] = searchWord; // 假设后端用 'q' 作为搜索查询参数
    }

    final cityFromFilter = apiParams['city'] as String?;
    if (cityFromFilter == null || cityFromFilter.isEmpty || cityFromFilter.toLowerCase() == '不限') {
      final cityModel = ScopedModel.of<CityModel>(context, rebuildOnChange: false);
      if (cityModel.city != null && cityModel.city!.id.isNotEmpty) {
        apiParams['city'] = cityModel.city!.id;
      }
    }

    
    print('[TabSearch] Final apiParams for /api/rooms: $apiParams');

    try {
      final response = await DioHttp.of(context).get(
        '/api/rooms',
        apiParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        print('[TabSearch] Received response data: ${response.data}');
        final Map<String, dynamic> responseData = response.data!;
        final List<dynamic> roomsData = responseData['rooms'] as List<dynamic>;
        
        final List<RoomListItemData> fetchedRooms = roomsData.map((item) {
          var room = item as Map<String, dynamic>;
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

          String imageUrl = Config.DefaultImage;
          if (room['images'] != null && (room['images'] as List).isNotEmpty) {
            String rawImageUrl = (room['images'] as List)[0] as String;
            if (rawImageUrl.startsWith('/')) {
              imageUrl = Config.BaseUrl + rawImageUrl;
            } else {
              imageUrl = rawImageUrl;
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

        if (mounted) {
          setState(() {
            _roomList = fetchedRooms;
            _isLoading = false;
          });
        }
      } else {
        print('Failed to load rooms: ${response.statusCode}');
        if (mounted) {
          setState(() {
            _isLoading = false;
            _roomList = []; // 清空列表以防显示旧数据
          });
        }
      }
    } catch (e) {
      print('Error fetching rooms: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _roomList = []; // 清空列表
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const FilterDrawer(),
      appBar: AppBar(
        actions: [Container()],
        elevation: 0,
        title: custom.SearchBar(
          showLocation: true,
          showMap: true,
          inputValue: _currentSearchWord, // 绑定到当前搜索词
          // onSearch: null, // 在搜索页，点击搜索框不应再导航
          onSearchSubmit: (String value) {
            setState(() {
              _currentSearchWord = value;
            });
            _fetchRoomsData(searchWord: value); // 使用新搜索词获取数据
          },
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 41,
            child: FilterBar(
              onChange: (filter_data.FilterBarResult result) {
                setState(() {
                  _currentFilterParams = result;
                });
                // 当筛选条件改变时，也带上当前的搜索词
                _fetchRoomsData(searchWord: _currentSearchWord);
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
