import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/models.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';

class PrayerService {
  static const String baseUrl = 'https://api.aladhan.com/v1/timings';

  Future<PrayerTimes?> fetchPrayerTimes(Position pos) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final url = '$baseUrl/$timestamp?latitude=${pos.latitude}&longitude=${pos.longitude}&method=4';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return PrayerTimes.fromJson(json.decode(response.body));
      }
    } catch (e) {
      debugPrint('Error fetching prayer times: $e');
    }
    return null;
  }

  Future<String> getCityName(Position pos) async {
    if (kIsWeb) return 'الموقع الحالي';
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty) {
        return placemarks.first.locality ?? placemarks.first.subAdministrativeArea ?? 'غير معروف';
      }
    } catch (e) {
      debugPrint('Error geocoding: $e');
    }
    return 'غير معروف';
  }

  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition();
  }
}