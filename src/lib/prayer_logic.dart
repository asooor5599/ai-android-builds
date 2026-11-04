import 'dart:math';

class PrayerTime {
  final String name;
  final DateTime time;
  PrayerTime(this.name, this.time);
}

class PrayerCalculator {
  static const double lat = 24.7136;
  static const double lng = 46.6753;
  static const double timezone = 3.0;

  static List<PrayerTime> getTimes(DateTime date) {
    double d = _calculateJulianDate(date.year, date.month, date.day) - 2451545.0;
    double g = (357.529 + 0.98560028 * d) % 360;
    double q = (280.459 + 0.98564736 * d) % 360;
    double l = (q + 1.915 * sin(_toRad(g)) + 0.020 * sin(_toRad(2 * g))) % 360;
    double e = 23.439 - 0.00000036 * d;
    double ra = _toDeg(atan2(cos(_toRad(e)) * sin(_toRad(l)), cos(_toRad(l)))) / 15;
    ra = (ra + 24) % 24;
    double eqt = q / 15 - ra;
    double decl = _toDeg(asin(sin(_toRad(e)) * sin(_toRad(l))));
    double dhuhr = 12 + timezone - lng / 15 - eqt;
    double fajrAngle = 18.5;
    double fajr = dhuhr - _hourAngle(fajrAngle, decl, lat) / 15;
    double sunrise = dhuhr - _hourAngle(0.833, decl, lat) / 15;
    double asrAngle = _toDeg(atan(1 + tan(_toRad((lat - decl).abs()))));
    double asr = dhuhr + _hourAngle(asrAngle, decl, lat, isAsr: true) / 15;
    double maghrib = dhuhr + _hourAngle(0.833, decl, lat) / 15;
    double isha = maghrib + 1.5;

    return [
      PrayerTime('الفجر', _toDate(date, fajr)),
      PrayerTime('الشروق', _toDate(date, sunrise)),
      PrayerTime('الظهر', _toDate(date, dhuhr)),
      PrayerTime('العصر', _toDate(date, asr)),
      PrayerTime('المغرب', _toDate(date, maghrib)),
      PrayerTime('العشاء', _toDate(date, isha)),
    ];
  }

  static double _toRad(double deg) => deg * pi / 180;
  static double _toDeg(double rad) => rad * 180 / pi;

  static double _calculateJulianDate(int y, int m, int d) {
    if (m <= 2) { y -= 1; m += 12; }
    int a = (y / 100).floor();
    int b = 2 - a + (a / 4).floor();
    return (365.25 * (y + 4716)).floor() + (30.6001 * (m + 1)).floor() + d + b - 1524.5;
  }

  static double _hourAngle(double angle, double decl, double lat, {bool isAsr = false}) {
    double rLat = _toRad(lat);
    double rDecl = _toRad(decl);
    double rAngle = _toRad(angle);
    double cosH;
    if (isAsr) {
       cosH = (sin(atan(1 / (1 + tan((rLat - rDecl).abs())))) - sin(rLat) * sin(rDecl)) / (cos(rLat) * cos(rDecl));
    } else {
       cosH = (-sin(rAngle) - sin(rLat) * sin(rDecl)) / (cos(rLat) * cos(rDecl));
    }
    if (cosH > 1) return 0;
    if (cosH < -1) return 180;
    return _toDeg(acos(cosH));
  }

  static DateTime _toDate(DateTime base, double hours) {
    int h = hours.floor();
    int m = ((hours - h) * 60).round();
    return DateTime(base.year, base.month, base.day, h, m);
  }
}