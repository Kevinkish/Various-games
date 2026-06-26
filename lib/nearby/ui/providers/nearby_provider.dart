import 'package:flutter/material.dart';
import '../../data/models/nearby_place.dart';
import '../../data/services/location_service.dart';
import '../../data/services/nearby_service.dart';

class NearbyProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  final NearbyService _nearbyService = NearbyService();

  bool isLoading = false;
  bool hasPermission = false;
  String? errorMessage;
  double? userLatitude;
  double? userLongitude;
  String selectedCategory = 'restaurant';
  List<NearbyPlace> places = [];

  final categories = <String>['restaurant', 'cafe', 'museum', 'park', 'events'];

  void changeCategory(String category) {
    selectedCategory = category;
    notifyListeners();
    loadPlaces();
  }

  Future<void> loadPlaces() async {
    isLoading = true;
    errorMessage = null;
    places = [];
    notifyListeners();

    try {
      hasPermission = await _locationService.requestPermission();
      if (!hasPermission) {
        throw Exception('Permission d’accès GPS refusée');
      }

      final position = await _locationService.getCurrentPosition();
      userLatitude = position.latitude;
      userLongitude = position.longitude;

      final rawCategory = selectedCategory == 'events'
          ? 'tourism'
          : selectedCategory;
      places = await _nearbyService.fetchPlaces(
        latitude: position.latitude,
        longitude: position.longitude,
        radiusMeters: 5000,
        category: rawCategory,
      );
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
