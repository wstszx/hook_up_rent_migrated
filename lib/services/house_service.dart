import '../models/house.dart';
import 'dart:math';

class HouseService {
  final List<House> _mockHouses = [
    House(
      id: '1',
      title: '现代简约两居室',
      price: '3000/月',
      area: '80平米',
      community: '小区A',
      latitude: 31.2304,
      longitude: 121.4737,
      imageUrl: 'static/images/home_index_recommend_1.png',
    ),
    House(
      id: '2',
      title: '市中心豪华公寓',
      price: '8000/月',
      area: '120平米',
      community: '小区B',
      latitude: 31.2354,
      longitude: 121.4837,
      imageUrl: 'static/images/home_index_recommend_2.png',
    ),
    House(
      id: '3',
      title: '近地铁温馨一居室',
      price: '2500/月',
      area: '50平米',
      community: '小区C',
      latitude: 31.2284,
      longitude: 121.4687,
      imageUrl: 'static/images/home_index_recommend_3.png',
    ),
     House(
      id: '4',
      title: '郊区独栋别墅',
      price: '15000/月',
      area: '200平米',
      community: '小区D',
      latitude: 31.3000,
      longitude: 121.5000,
      imageUrl: 'static/images/home_index_recommend_4.png',
    ),
  ];

  List<House> getMockHouses() {
    return _mockHouses;
  }

  List<House> searchHouses(String keyword) {
    if (keyword.isEmpty) {
      return _mockHouses;
    }
    return _mockHouses.where((house) =>
        house.title.contains(keyword) || house.community.contains(keyword)).toList();
  }

  // Simple distance calculation (Haversine formula is more accurate but this is sufficient for mock)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295; // Math.PI / 180
    var a = 0.5 - cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  List<House> filterByDistance(double centerLat, double centerLon, double radiusKm) {
    return _mockHouses.where((house) {
      final distance = _calculateDistance(centerLat, centerLon, house.latitude, house.longitude);
      return distance <= radiusKm;
    }).toList();
  }
}