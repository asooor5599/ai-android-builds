import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:app/models.dart';

class ApiService {
  static Future<PrayerTimes?> fetchPrayerTimes(double lat, double lng) async {
    final url = Uri.parse('https://api.aladhan.com/v1/timings?latitude=$lat&longitude=$lng&method=2');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return PrayerTimes.fromJson(json.decode(response.body));
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}

class LocationService {
  static Future<Position?> determinePosition() async {
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