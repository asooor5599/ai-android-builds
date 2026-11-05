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
    Surah(id: 18, name: 'الكهف', englishName: 'Al-Kahf', versesCount: 110, revelationType: 'مكية'),
    Surah(id: 36, name: 'يس', englishName: 'Ya-Sin', versesCount: 83, revelationType: 'مكية'),
    Surah(id: 55, name: 'الرحمن', englishName: 'Ar-Rahman', versesCount: 78, revelationType: 'مدنية'),
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
      final response = await http.get(Uri.parse('https://api.aladhan.com/v1/timings?latitude=$lat&longitude=$lng&method=4')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = Map<String, String>.from(data['data']['timings']);
        final date = data['data']['date']['readable'];
        final timezone = data['data']['meta']['timezone'];
        return PrayerTimesData(timings: timings, date: date, timezone: timezone, city: timezone.split('/').last);
      }
    } catch (_) {}
    return null;
  }
}
