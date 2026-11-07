import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/models/quran_models.dart';

class QuranDataService {
  static const List<Surah> allSurahs = [
    Surah(id: 1, name: 'الفاتحة', englishName: 'Al-Fatiha', versesCount: 7, revelationType: 'Meccan'),
    Surah(id: 2, name: 'البقرة', englishName: 'Al-Baqara', versesCount: 286, revelationType: 'Medinan'),
    Surah(id: 3, name: 'آل عمران', englishName: 'Aal-Imran', versesCount: 200, revelationType: 'Medinan'),
    Surah(id: 4, name: 'النساء', englishName: 'An-Nisa', versesCount: 176, revelationType: 'Medinan'),
    Surah(id: 18, name: 'الكهف', englishName: 'Al-Kahf', versesCount: 110, revelationType: 'Meccan'),
    Surah(id: 36, name: 'يس', englishName: 'Ya-Sin', versesCount: 83, revelationType: 'Meccan'),
    Surah(id: 55, name: 'الرحمن', englishName: 'Ar-Rahman', versesCount: 78, revelationType: 'Medinan'),
    Surah(id: 56, name: 'الواقعة', englishName: 'Al-Waqi\'a', versesCount: 96, revelationType: 'Meccan'),
    Surah(id: 67, name: 'الملك', englishName: 'Al-Mulk', versesCount: 30, revelationType: 'Meccan'),
    Surah(id: 112, name: 'الإخلاص', englishName: 'Al-Ikhlas', versesCount: 4, revelationType: 'Meccan'),
    Surah(id: 113, name: 'الفلق', englishName: 'Al-Falaq', versesCount: 5, revelationType: 'Meccan'),
    Surah(id: 114, name: 'الناس', englishName: 'An-Nas', versesCount: 6, revelationType: 'Meccan'),
  ];

  static const List<Reciter> fallbackReciters = [
    Reciter(id: '1', name: 'مشاري العفاسي', rewaya: 'حفص عن عاصم', serverUrl: 'https://server8.mp3quran.net/afs/'),
    Reciter(id: '2', name: 'عبد الباسط عبد الصمد', rewaya: 'المصحف المرتل', serverUrl: 'https://server7.mp3quran.net/basit/'),
  ];

  static String getAudioUrl(Reciter reciter, int surahId) {
    final idStr = surahId.toString().padLeft(3, '0');
    return '${reciter.serverUrl}$idStr.mp3';
  }

  static Future<List<Reciter>> fetchAllRecitersFromApi() async {
    try {
      final response = await http.get(Uri.parse('https://mp3quran.net/api/v3/reciters?language=ar'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List recitersJson = data['reciters'];
        return recitersJson.map((e) => Reciter.fromJson(e)).toList();
      }
    } catch (_) {}
    return fallbackReciters;
  }

  static Future<List<Verse>> fetchSurahText(int surahId) async {
    try {
      final response = await http.get(Uri.parse('https://api.alquran.cloud/v1/surah/$surahId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List ayahs = data['data']['ayahs'];
        return ayahs.map((e) => Verse(number: e['number'], numberInSurah: e['numberInSurah'], text: e['text'])).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<PrayerTimesData?> fetchPrayerTimes(double lat, double lon) async {
    try {
      final response = await http.get(Uri.parse('https://api.aladhan.com/v1/timings?latitude=$lat&longitude=$lon&method=4'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = Map<String, String>.from(data['data']['timings']);
        final date = data['data']['date']['readable'];
        return PrayerTimesData(timings: timings, date: date, cityArabic: 'موقعي الحالي');
      }
    } catch (_) {}
    return null;
  }

  static Future<List<ZekrItem>> fetchAzkarFromApi() async {
    try {
      final response = await http.get(Uri.parse('https://raw.githubusercontent.com/nawafalqari/azkar-api/master/azkar.json'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        List<ZekrItem> items = [];
        data.forEach((category, list) {
          if (list is List) {
            for (var item in list) {
              items.add(ZekrItem.fromJson(item, category));
            }
          }
        });
        return items;
      }
    } catch (_) {}
    return [];
  }
}