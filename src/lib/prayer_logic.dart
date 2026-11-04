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
    double d = date.difference(DateTime.utc(2000, 1, 1, 12)).inSeconds / 86400.0;
    
    double g = (357.529 + 0.98560028 * d) % 360;
    double q = (280.459 + 0.98564736 * d) % 360;
    double l = (q + 1.915 * sin(_rad(g)) + 0.020 * sin(_rad(2 * g))) % 360;
    double e = (23.439 - 0.00000036 * d) % 360;
    double ra = _deg(atan2(cos(_rad(e)) * sin(_rad(l)), cos(_rad(l)))) / 15;
    double eqt = q / 15 - ra;
    double decl = _deg(asin(sin(_rad(e)) * sin(_rad(l))));

    double noon = 12 + timezone - lng / 15 - eqt;
    
    double sunriseAngle = 0.833;
    double fajrAngle = 18.5; 
    
    DateTime dFajr = _toDate(date, noon - _hourAngle(fajrAngle, decl) / 15);
    DateTime dSunrise = _toDate(date, noon - _hourAngle(sunriseAngle, decl) / 15);
    DateTime dDhuhr = _toDate(date, noon);
    
    double asrAlt = _deg(atan(1 + tan(_rad((lat - decl).abs()))));
    DateTime dAsr = _toDate(date, noon + _hourAngle(90 - asrAlt, decl) / 15);
    
    DateTime dMaghrib = _toDate(date, noon + _hourAngle(sunriseAngle, decl) / 15);
    DateTime dIsha = dMaghrib.add(const Duration(minutes: 90));

    return [
      PrayerTime('الفجر', dFajr),
      PrayerTime('الشروق', dSunrise),
      PrayerTime('الظهر', dDhuhr),
      PrayerTime('العصر', dAsr),
      PrayerTime('المغرب', dMaghrib),
      PrayerTime('العشاء', dIsha),
    ];
  }

  static double _rad(double deg) => deg * pi / 180;
  static double _deg(double rad) => rad * 180 / pi;

  static double _hourAngle(double angle, double decl) {
    double val = (cos(_rad(90 + angle)) - sin(_rad(lat)) * sin(_rad(decl))) / (cos(_rad(lat)) * cos(_rad(decl)));
    return _deg(acos(val.clamp(-1.0, 1.0)));
  }

  static DateTime _toDate(DateTime date, double hours) {
    int h = hours.floor();
    int m = ((hours - h) * 60).floor();
    int s = (((hours - h) * 60 - m) * 60).floor();
    return DateTime(date.year, date.month, date.day, h, m, s);
  }

  static PrayerTime getNextPrayer(List<PrayerTime> times) {
    DateTime now = DateTime.now();
    for (var p in times) {
      if (p.time.isAfter(now) && p.name != 'الشروق') return p;
    }
    return PrayerTime('الفجر', times[0].time.add(const Duration(days: 1)));
  }
}