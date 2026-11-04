class PrayerTimes {
  final String fajr;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String date;
  final DateTime fajrTime;
  final DateTime dhuhrTime;
  final DateTime asrTime;
  final DateTime maghribTime;
  final DateTime ishaTime;

  PrayerTimes({
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.date,
    required this.fajrTime,
    required this.dhuhrTime,
    required this.asrTime,
    required this.maghribTime,
    required this.ishaTime,
  });

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    final timings = json['data']['timings'];
    final dateStr = json['data']['date']['readable'];
    final dateIso = json['data']['date']['gregorian']['date']; // DD-MM-YYYY
    
    DateTime _parse(String time) {
      final parts = dateIso.split('-');
      final tParts = time.split(':');
      return DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
        int.parse(tParts[0]),
        int.parse(tParts[1]),
      );
    }

    return PrayerTimes(
      fajr: timings['Fajr'],
      dhuhr: timings['Dhuhr'],
      asr: timings['Asr'],
      maghrib: timings['Maghrib'],
      isha: timings['Isha'],
      date: dateStr,
      fajrTime: _parse(timings['Fajr']),
      dhuhrTime: _parse(timings['Dhuhr']),
      asrTime: _parse(timings['Asr']),
      maghribTime: _parse(timings['Maghrib']),
      ishaTime: _parse(timings['Isha']),
    );
  }
}