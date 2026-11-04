import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:app/models.dart';
import 'package:app/services.dart';

class AppState extends ChangeNotifier {
  Position? currentPosition;
  PrayerTimes? prayerTimes;
  bool isLoading = false;
  double qiblaDirection = 0.0;
  String? errorMessage;

  Future<void> init() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final pos = await LocationService.determinePosition();
      if (pos != null) {
        currentPosition = pos;
        prayerTimes = await ApiService.fetchPrayerTimes(pos.latitude, pos.longitude);
        qiblaDirection = _calculateQibla(pos.latitude, pos.longitude);
        if (prayerTimes == null) errorMessage = 'Failed to fetch prayer times';
      } else {
        errorMessage = 'Location permission is required for accurate prayer times.';
      }
    } catch (e) {
      errorMessage = 'An unexpected error occurred.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  double _calculateQibla(double lat, double lng) {
    const double meccaLat = 21.4225;
    const double meccaLng = 39.8262;

    double phi1 = lat * (pi / 180.0);
    double phi2 = meccaLat * (pi / 180.0);
    double lam1 = lng * (pi / 180.0);
    double lam2 = meccaLng * (pi / 180.0);

    double qibla = atan2(
      sin(lam2 - lam1),
      cos(phi1) * tan(phi2) - sin(phi1) * cos(lam2 - lam1),
    );

    return (qibla * (180.0 / pi) + 360) % 360;
  }

  Map<String, dynamic>? getNextPrayer() {
    if (prayerTimes == null) return null;
    final now = DateTime.now();
    final list = [
      {'name': 'Fajr', 'time': prayerTimes!.fajrTime},
      {'name': 'Dhuhr', 'time': prayerTimes!.dhuhrTime},
      {'name': 'Asr', 'time': prayerTimes!.asrTime},
      {'name': 'Maghrib', 'time': prayerTimes!.maghribTime},
      {'name': 'Isha', 'time': prayerTimes!.ishaTime},
    ];

    for (var p in list) {
      if ((p['time'] as DateTime).isAfter(now)) return p;
    }
    return list.first; // Next day Fajr (simplified)
  }
}