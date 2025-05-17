class Room {
  final String id;
  final String title;
  final String description;
  final num price;
  final String city;
  final String district;
  final String address;
  final String rentType;
  final String roomType;
  final String floor;
  final String orientation;
  final List<String> images;
  final String publisher;
  final String status;
  final List<String> tags;
  final String createdAt;
  final String updatedAt;

  Room({
    required this.id,
    required this.title,
    this.description = '',
    required this.price,
    required this.city,
    this.district = '',
    this.address = '',
    required this.rentType,
    required this.roomType,
    this.floor = '',
    this.orientation = '',
    this.images = const [],
    required this.publisher,
    this.status = 'available',
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    List<String> parseImages(dynamic images) {
      if (images == null) return [];
      if (images is List) {
        return images.map((image) => image.toString()).toList();
      }
      return [];
    }

    List<String> parseTags(dynamic tags) {
      if (tags == null) return [];
      if (tags is List) {
        return tags.map((tag) => tag.toString()).toList();
      }
      return [];
    }

    return Room(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? 0,
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      address: json['address'] ?? '',
      rentType: json['rentType'] ?? '',
      roomType: json['roomType'] ?? '',
      floor: json['floor'] ?? '',
      orientation: json['orientation'] ?? '',
      images: parseImages(json['images']),
      publisher: json['publisher'] ?? '',
      status: json['status'] ?? 'available',
      tags: parseTags(json['tags']),
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}
