import 'package:flutter/material.dart';
import 'package:rent_share/widgets/search_bar/index.dart' as custom;
import 'package:rent_share/pages/utils/dio_http.dart';
import 'package:rent_share/pages/home/info/info_data.dart'; // 导入资讯数据模型
import 'package:rent_share/pages/home/info/item_widget.dart'; // 导入资讯列表项组件

class InfoSearchPage extends StatefulWidget {
  const InfoSearchPage({Key? key}) : super(key: key);

  @override
  _InfoSearchPageState createState() => _InfoSearchPageState();
}

class _InfoSearchPageState extends State<InfoSearchPage> {
  String _currentSearchWord = ''; // 用于存储当前搜索词
  List<InfoItem> _newsList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 可以在这里获取从资讯列表页传递过来的初始搜索词（如果需要）
    // final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    // final String? initialSearchWord = arguments?['searchWord'] as String?;
    // if (initialSearchWord != null && initialSearchWord.isNotEmpty) {
    //   _currentSearchWord = initialSearchWord;
    //   _fetchNewsData(initialSearchWord);
    // }
  }

  // 不需要 dispose _searchController 了

  Future<void> _fetchNewsData(String keyword) async {
    if (keyword.trim().isEmpty) {
      setState(() {
        _newsList = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 调用后端 /api/news 接口，并传递搜索参数 q
      final response = await DioHttp.of(context).get(
        '/api/news',
        {'q': keyword},
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> responseData = response.data!;
        final List<InfoItem> fetchedNews = responseData.map((item) {
          // 手动解析 JSON 数据为 InfoItem 对象
          return InfoItem(
            item['title'] ?? '',
            item['imageUrl'] ?? '',
            item['source'] ?? '',
            item['time'] ?? '',
            item['navigateUrl'] ?? '',
          );
        }).toList();

        if (mounted) {
          setState(() {
            _newsList = fetchedNews;
            _isLoading = false;
          });
        }
      } else {
        print('Failed to load news: ${response.statusCode}');
        if (mounted) {
          setState(() {
            _isLoading = false;
            _newsList = [];
          });
        }
      }
    } catch (e) {
      print('Error fetching news: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _newsList = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: custom.SearchBar(
          inputValue: _currentSearchWord, // 绑定当前搜索词
          onSearchSubmit: (String value) {
            setState(() {
              _currentSearchWord = value; // 更新搜索词状态
            });
            _fetchNewsData(value); // 提交搜索时调用搜索方法
          },
          onSearch: () {
            // 在搜索页点击搜索框不需要再次跳转
          },
          showLocation: false, // 资讯搜索不需要显示位置
          showMap: false, // 资讯搜索不需要显示地图
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _newsList.isEmpty
              ? const Center(child: Text('暂无匹配的资讯'))
              : ListView.builder(
                  itemCount: _newsList.length,
                  itemBuilder: (context, index) {
                    // 使用 InfoItemWidget 显示资讯列表项
                    return InfoItemWidget(data: _newsList[index]);
                  },
                ),
    );
  }
}