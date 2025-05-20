import 'package:flutter/material.dart';
import '../services/region_service.dart';
import '../scoped_model/city.dart';
import '../pages/utils/scoped_model_helper.dart';
import '../pages/home/tab_search/filter_bar/data.dart' as file_data;

class CitySelectionPage extends StatefulWidget {
  const CitySelectionPage({super.key});

  @override
  State<CitySelectionPage> createState() => _CitySelectionPageState();
}

class _CitySelectionPageState extends State<CitySelectionPage> {
  late Future<List<file_data.GeneralType>> _citiesFuture;
  List<file_data.GeneralType> _allCities = [];
  List<file_data.GeneralType> _filteredCities = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _citiesFuture = _fetchCities();
    _searchController.addListener(_filterCities);
  }

  Future<List<file_data.GeneralType>> _fetchCities() async {
    // 加载region.json数据
    await RegionService.loadRegionData();
    
    // 获取城市列表
    List<file_data.GeneralType> cities = RegionService.getCityList();
    
    setState(() {
      _allCities = cities;
      _filteredCities = cities;
    });
    return cities;
  }

  void _filterCities() {
    String query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredCities = _allCities;
      });
    } else {
      setState(() {
        _filteredCities = _allCities
            .where((city) => city.name.toLowerCase().contains(query))
            .toList();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择城市'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: '搜索城市',
                hintText: '输入城市名称...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<file_data.GeneralType>>(
              future: _citiesFuture, // Use the future initialized in initState
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && _allCities.isEmpty) {
                  // Show loading indicator only if _allCities is still empty
                  // (i.e., initial fetch is in progress)
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError && _allCities.isEmpty) {
                  // Show error only if initial fetch failed and we have no data
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('加载城市失败: ${snapshot.error}'),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _citiesFuture = _fetchCities(); // Retry fetching
                            });
                          },
                          child: const Text('重试'),
                        )
                      ],
                    )
                  );
                } else if (_allCities.isEmpty && snapshot.connectionState != ConnectionState.waiting) {
                  // Data has been fetched (or attempted), but _allCities is empty
                  return const Center(child: Text('暂无城市数据'));
                }
                // If we have data in _allCities (even if future is re-triggered), display _filteredCities
                // This allows search to work even while a retry might be in background.
                if (_filteredCities.isEmpty && _searchController.text.isNotEmpty) {
                  return const Center(child: Text('未找到匹配的城市'));
                }

                return ListView.builder(
                  itemCount: _filteredCities.length,
                  itemBuilder: (context, index) {
                    file_data.GeneralType city = _filteredCities[index];
                    return ListTile(
                      title: Text(city.name),
                      onTap: () {
                        // 更新城市模型
                        ScopedModelHelper.getModel<CityModel>(context).city = city;
                        Navigator.pop(context, city); // 返回选择的城市
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}