import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/house.dart';
import '../services/house_service.dart';

class MapHousePage extends StatefulWidget {
  const MapHousePage({Key? key}) : super(key: key);

  @override
  _MapHousePageState createState() => _MapHousePageState();
}

class _MapHousePageState extends State<MapHousePage> {
  late final WebViewController _controller;
  final HouseService _houseService = HouseService();
  List<House> _houses = [];
  bool _isLoading = true;
  String _currentSearchKeyword = '';
  double _currentCenterLat = 31.2304; // Default to Shanghai
  double _currentCenterLon = 121.4737; // Default to Shanghai

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _requestLocationPermission();
  }

  Future<void> _initializeWebView() async {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading status
            if (progress == 100) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) async {
            // Page finished loading, load initial data
            await _loadHouses();
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
              Page resource error:
                code: ${error.errorCode}
                description: ${error.description}
                errorType: ${error.errorType}
                isForMainFrame: ${error.isForMainFrame}
            ''');
          },
        ),
      )
      ..addJavaScriptChannel(
        'flutter',
        onMessageReceived: (message) {
          _handleWebViewMessage(message.message);
        },
      )
      ..loadFlutterAsset('assets/web/map.html');
  }

  Future<void> _requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
      _getCurrentLocation();
    } else {
      // Handle permission denied
      debugPrint('Location permission denied');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _currentCenterLat = position.latitude;
      _currentCenterLon = position.longitude;
      _setMapCenter(_currentCenterLon, _currentCenterLat);
    } catch (e) {
      debugPrint('Error getting current location: $e');
    }
  }

  Future<void> _loadHouses() async {
    // In a real app, you would fetch data from an API based on the current map view
    // For this example, we'll use mock data and filter by distance from the current center
    _houses = _houseService.filterByDistance(_currentCenterLat, _currentCenterLon, 10); // Filter within 10km
    _updateMapMarkers(_houses);
  }

  void _updateMapMarkers(List<House> houses) {
    final List<Map<String, dynamic>> houseData =
        houses.map((house) => house.toJson()).toList();
    _controller.runJavaScript('updateMarkers(${jsonEncode(houseData)})');
  }

  void _setMapCenter(double lng, double lat) {
    _controller.runJavaScript('setCenter($lng, $lat)');
  }

  Future<void> _handleWebViewMessage(String message) async {
    final Map<String, dynamic> messageData = jsonDecode(message);
    final String type = messageData['type'];
    final dynamic data = messageData['data'];

    switch (type) {
      case 'mapMoveEnd':
        _currentCenterLat = data['latitude'];
        _currentCenterLon = data['longitude'];
        // Reload houses based on the new center
        _loadHouses();
        break;
      case 'markerClick':
        final String houseId = data['houseId'];
        // Navigate to house detail page or show info window
        debugPrint('Marker clicked for house ID: $houseId');
        // Example: Navigate to detail page (assuming a route exists)
        // Navigator.pushNamed(context, '/room/${houseId}');
        break;
      default:
        debugPrint('Unknown message type: $type');
    }
  }

  void _searchHouses(String keyword) {
    _currentSearchKeyword = keyword;
    _houses = _houseService.searchHouses(keyword);
    _updateMapMarkers(_houses);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('地图找房'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality (e.g., show a search bar)
              // For simplicity, we'll just trigger a search with a fixed keyword here
              _searchHouses('小区');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}