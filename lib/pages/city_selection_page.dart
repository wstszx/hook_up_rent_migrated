import 'package:flutter/material.dart';
import '../models/general_type.dart';
import './utils/dio_http.dart'; // Assuming dio_http.dart is in lib/pages/utils/
import '../scoped_model/city.dart'; // For CityModel if needed for other purposes, or remove
import '../pages/utils/scoped_model_helper.dart'; // For ScopedModelHelper if needed

class CitySelectionPage extends StatefulWidget {
  const CitySelectionPage({super.key});

  @override
  State<CitySelectionPage> createState() => _CitySelectionPageState();
}

class _CitySelectionPageState extends State<CitySelectionPage> {
  late Future<List<GeneralType>> _citiesFuture;
  List<GeneralType> _allCities = [];
  List<GeneralType> _filteredCities = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // It's generally better to initialize context-dependent futures
    // in didChangeDependencies or pass context if absolutely needed by of(context) at initState.
    // However, if DioHttp.of(context) can be called here safely or is refactored
    // to not strictly need context for this call, this is fine.
    // For simplicity, assuming it's okay for now.
    // A common pattern is to pass the DioHttp instance or make getCities static if context isn't needed for the call itself.
    _citiesFuture = _fetchCities();
    _searchController.addListener(_filterCities);
  }

  Future<List<GeneralType>> _fetchCities() async {
    // Ensure context is available if DioHttp.of(context) truly needs it here.
    // If DioHttp instance is managed elsewhere (e.g., via Provider or a singleton),
    // it would be cleaner.
    // For now, we'll call it directly, assuming it works or will be refactored.
    List<GeneralType> cities = await DioHttp.of(context).getCities();
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
            child: FutureBuilder<List<GeneralType>>(
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
                    GeneralType city = _filteredCities[index];
                    return ListTile(
                      title: Text(city.name),
                      onTap: () {
                        // Optionally, update CityModel here if needed immediately
                        // ScopedModelHelper.getModel<CityModel>(context).city = city;
                        Navigator.pop(context, city); // Return the selected city
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