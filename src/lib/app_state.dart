import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:app/models.dart';
import 'package:app/location_service.dart';
import 'package:app/prayer_service.dart';

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
      final pos = await LocationService.getCurrentLocation();
      if (pos != null) {
        currentPosition = pos;
        prayerTimes = await PrayerService.fetchPrayerTimes(pos.latitude, pos.longitude);
        qiblaDirection = _calculateQibla(pos.latitude, pos.longitude);
      } else {
        errorMessage = 'Location permission denied';
      }
    } catch (e) {
      errorMessage = 'Failed to load data';
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

    return qibla * (180.0 / pi);
  }
}