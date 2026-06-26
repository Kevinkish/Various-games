class NearbyPlace {
  final String id;
  final String name;
  final String category;
  final double latitude;
  final double longitude;
  final double distanceMeters;
  final String address;

  NearbyPlace({
    required this.id,
    required this.name,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
    required this.address,
  });

  factory NearbyPlace.fromJson(
    Map<String, dynamic> json,
    double distanceMeters,
  ) {
    return NearbyPlace(
      id: json['id'] as String,
      name: json['tags']?['name'] as String? ?? 'Lieu inconnu',
      category:
          json['tags']?['amenity'] as String? ??
          json['tags']?['tourism'] as String? ??
          'Autre',
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['lon'] as num).toDouble(),
      distanceMeters: distanceMeters,
      address:
          json['tags']?['addr:street'] as String? ??
          json['tags']?['addr:full'] as String? ??
          '',
    );
  }
}
