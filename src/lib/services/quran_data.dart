import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/models/quran_models.dart';

class QuranDataService {
  static const String mp3QuranApiUrl = 'https://www.mp3quran.net/api/v3/reciters?language=ar';

  static final List<Reciter> fallbackReciters = [
    const Reciter(id: '54', name: 'مشاري العفاسي', rewaya: 'حفص عن عاصم', serverUrl: 'https://server8.mp3quran.net/afs/'),
    const Reciter(id: '102', name: 'عبد الباسط عبد الصمد', rewaya: 'المصحف المرتل', serverUrl: 'https://server7.mp3quran.net/basit/'),
    const Reciter(id: '121', name: 'ماهر المعيقلي', rewaya: 'حفص عن عاصم', serverUrl: 'https://server12.mp3quran.net/maher/'),
  ];

  static const List<Surah> surahs = [
    Surah(id: 1, name: 'الفاتحة', englishName: 'Al-Fatihah', versesCount: 7, revelationType: 'مكية'),
    Surah(id: 2, name: 'البقرة', englishName: 'Al-Baqarah', versesCount: 286, revelationType: 'مدنية'),
    Surah(id: 3, name: 'آل عمران', englishName: 'Al-Imran', versesCount: 200, revelationType: 'مدنية'),
    Surah(id: 4, name: 'النساء', englishName: 'An-Nisa', versesCount: 176, revelationType: 'مدنية'),
    Surah(id: 5, name: 'المائدة', englishName: 'Al-Ma\'idah', versesCount: 120, revelationType: 'مدنية'),
    Surah(id: 18, name: 'الكهف', englishName: 'Al-Kahf', versesCount: 110, revelationType: 'مكية'),
    Surah(id: 36, name: 'يس', englishName: 'Ya-Sin', versesCount: 83, revelationType: 'مكية'),
    Surah(id: 55, name: 'الرحمن', englishName: 'Ar-Rahman', versesCount: 78, revelationType: 'مدنية'),
    Surah(id: 56, name: 'الواقعة', englishName: 'Al-Waqi\'a', versesCount: 96, revelationType: 'مكية'),
    Surah(id: 67, name: 'الملك', englishName: 'Al-Mulk', versesCount: 30, revelationType: 'مكية'),
    Surah(id: 112, name: 'الإخلاص', englishName: 'Al-Ikhlas', versesCount: 4, revelationType: 'مكية'),
    Surah(id: 113, name: 'الفلق', englishName: 'Al-Falaq', versesCount: 5, revelationType: 'مكية'),
    Surah(id: 114, name: 'الناس', englishName: 'An-Nas', versesCount: 6, revelationType: 'مكية'),
  ];

  static Future<List<Reciter>> fetchAllRecitersFromApi() async {
    try {
      final response = await http.get(Uri.parse(mp3QuranApiUrl)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final List recitersJson = data['reciters'] ?? [];
        return recitersJson.map((r) => Reciter.fromJson(r)).where((r) => r.serverUrl.isNotEmpty).toList();
      }
    } catch (_) {}
    return fallbackReciters;
  }

  static String getAudioUrl(Reciter reciter, int surahId) {
    final formattedNumber = surahId.toString().padLeft(3, '0');
    return '${reciter.serverUrl}$formattedNumber.mp3';
  }

  static Future<List<Verse>> fetchSurahVerses(int surahId) async {
    try {
      final response = await http.get(Uri.parse('https://api.alquran.cloud/v1/surah/$surahId/quran-uthmani')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final List ayahs = data['data']['ayahs'];
        return ayahs.map((e) => Verse(number: e['number'], numberInSurah: e['numberInSurah'], text: e['text'])).toList();
      }
    } catch (_) {}
    return [const Verse(number: 1, numberInSurah: 1, text: 'تعذر تحميل الآيات.')];
  }

  static Future<PrayerTimesData?> fetchPrayerTimes(double lat, double lng) async {
    try {
      String cityArabic = 'غير معروف';
      try {
        final geoUrl = 'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&accept-language=ar';
        final geoResponse = await http.get(Uri.parse(geoUrl), headers: {'User-Agent': 'QuranApp/1.0'});
        if (geoResponse.statusCode == 200) {
          final geoData = json.decode(geoResponse.body);
          final address = geoData['address'];
          cityArabic = address['city'] ?? address['town'] ?? address['village'] ?? address['state'] ?? 'غير معروف';
        }
      } catch (_) {}

      final response = await http.get(Uri.parse('https://api.aladhan.com/v1/timings?latitude=$lat&longitude=$lng&method=4')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = Map<String, String>.from(data['data']['timings']);
        final date = data['data']['date']['readable'];
        return PrayerTimesData(timings: timings, date: date, cityArabic: cityArabic);
      }
    } catch (_) {}
    return null;
  }
}
