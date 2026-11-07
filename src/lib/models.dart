class PrayerTimes {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String hijriDate;
  final String gregorianDate;

  PrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.hijriDate,
    required this.gregorianDate,
  });

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    final timings = json['data']['timings'];
    final date = json['data']['date'];
    return PrayerTimes(
      fajr: timings['Fajr'],
      sunrise: timings['Sunrise'],
      dhuhr: timings['Dhuhr'],
      asr: timings['Asr'],
      maghrib: timings['Maghrib'],
      isha: timings['Isha'],
      hijriDate: "${date['hijri']['day']} ${date['hijri']['month']['ar']} ${date['hijri']['year']}",
      gregorianDate: "${date['gregorian']['day']} ${date['gregorian']['month']['en']} ${date['gregorian']['year']}",
    );
  }

  Map<String, String> toMap() {
    return {
      'الفجر': fajr,
      'الشروق': sunrise,
      'الظهر': dhuhr,
      'العصر': asr,
      'المغرب': maghrib,
      'العشاء': isha,
    };
  }
}