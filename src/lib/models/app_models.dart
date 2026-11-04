import 'dart:math';

class CityLocation {
  final String name;
  final String country;
  final double latitude;
  final double longitude;

  const CityLocation({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  static const List<CityLocation> presets = [
    CityLocation(name: 'مكة المكرمة', country: 'السعودية', latitude: 21.3891, longitude: 39.8579),
    CityLocation(name: 'المدينة المنورة', country: 'السعودية', latitude: 24.5247, longitude: 39.5692),
    CityLocation(name: 'الرياض', country: 'السعودية', latitude: 24.7136, longitude: 46.6753),
    CityLocation(name: 'القاهرة', country: 'مصر', latitude: 30.0444, longitude: 31.2357),
    CityLocation(name: 'دبي', country: 'الإمارات', latitude: 25.2048, longitude: 55.2708),
    CityLocation(name: 'عَمّان', country: 'الأردن', latitude: 31.9454, longitude: 35.9284),
    CityLocation(name: 'القدس', country: 'فلسطين', latitude: 31.7683, longitude: 35.2137),
    CityLocation(name: 'بغداد', country: 'العراق', latitude: 33.3152, longitude: 44.3661),
    CityLocation(name: 'الكويت', country: 'الكويت', latitude: 29.3759, longitude: 47.9774),
    CityLocation(name: 'الدوحة', country: 'قطر', latitude: 25.2854, longitude: 51.5310),
    CityLocation(name: 'مسقط', country: 'عُمان', latitude: 23.5880, longitude: 58.3829),
    CityLocation(name: 'تونس', country: 'تونس', latitude: 36.8065, longitude: 10.1815),
    CityLocation(name: 'الرباط', country: 'المغرب', latitude: 34.0209, longitude: -6.8416),
    CityLocation(name: 'الجزائر', country: 'الجزائر', latitude: 36.7538, longitude: 3.0588),
    CityLocation(name: 'إسطنبول', country: 'تركيا', latitude: 41.0082, longitude: 28.9784),
  ];
}

class PrayerTiming {
  final String name;
  final String arabicName;
  final DateTime time;
  final bool isCompleted;

  PrayerTiming({
    required this.name,
    required this.arabicName,
    required this.time,
    this.isCompleted = false,
  });

  PrayerTiming copyWith({bool? isCompleted}) {
    return PrayerTiming(
      name: name,
      arabicName: arabicName,
      time: time,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class PrayerData {
  final Map<String, String> rawTimings;
  final String hijriDate;
  final String gregorianDate;

  PrayerData({
    required this.rawTimings,
    required this.hijriDate,
    required this.gregorianDate,
  });
}

class DhikrItem {
  final String text;
  final String count;
  final String reference;
  int currentCount;

  DhikrItem({
    required this.text,
    required this.count,
    required this.reference,
    this.currentCount = 0,
  });

  int get maxCount => int.tryParse(count) ?? 1;
  bool get isFinished => currentCount >= maxCount;
}

class CalculationUtils {
  static double calculateQiblaDegree(double lat, double lng) {
    const double kaabaLat = 21.422487;
    const double kaabaLng = 39.826206;

    double phi1 = lat * pi / 180.0;
    double phi2 = kaabaLat * pi / 180.0;
    double lambda1 = lng * pi / 180.0;
    double lambda2 = kaabaLng * pi / 180.0;

    double dLambda = lambda2 - lambda1;
    double y = sin(dLambda);
    double x = cos(phi1) * tan(phi2) - sin(phi1) * cos(dLambda);

    double qibla = atan2(y, x) * 180.0 / pi;
    return (qibla + 360) % 360;
  }
}