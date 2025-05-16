class House {
  final String id;
  final String title;
  final String price;
  final String area;
  final String community;
  final double latitude;
  final double longitude;
  final String imageUrl;

  House({
    required this.id,
    required this.title,
    required this.price,
    required this.area,
    required this.community,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
  });

  factory House.fromJson(Map<String, dynamic> json) {
    return House(
      id: json['id'],
      title: json['title'],
      price: json['price'],
      area: json['area'],
      community: json['community'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'area': area,
      'community': community,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
    };
  }
}