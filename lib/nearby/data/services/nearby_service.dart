import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import '../models/nearby_place.dart';

class NearbyService {
  static const _overpassUrl = 'https://overpass-api.de/api/interpreter';

  Future<List<NearbyPlace>> fetchPlaces({
    required double latitude,
    required double longitude,
    required int radiusMeters,
    String category = 'restaurant',
  }) async {
    final query =
        '''
      [out:json][timeout:25];
      (
        node["amenity"="$category"](around:$radiusMeters,$latitude,$longitude);
        node["tourism"="$category"](around:$radiusMeters,$latitude,$longitude);
      );
      out body;
    ''';

    final response = await http.post(
      Uri.parse(_overpassUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'data': query},
    );

    if (response.statusCode != 200) {
      throw Exception('Impossible de récupérer les lieux');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final elements = decoded['elements'] as List<dynamic>? ?? [];

    return elements
        .whereType<Map<String, dynamic>>()
        .map((element) {
          final lat = element['lat'];
          final lon = element['lon'];
          if (lat == null || lon == null) return null;
          final distance = _haversineDistance(
            latitude,
            longitude,
            lat as double,
            lon as double,
          );
          return NearbyPlace.fromJson(element, distance);
        })
        .whereType<NearbyPlace>()
        .toList()
      ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
  }

  double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000.0;
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    final a =
        (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            (sin(dLon / 2) * sin(dLon / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) => degrees * (pi / 180);
}
