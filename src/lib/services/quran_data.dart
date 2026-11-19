import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/models/quran_models.dart';

class QuranDataService {
  static const String mp3QuranApiUrl = 'https://www.mp3quran.net/api/v3/reciters?language=ar';
  static const String azkarApiUrl = 'https://raw.githubusercontent.com/nawafalqari/azkar-api/56df51279ab6eb86dc2f6202c7de26c8948331c1/azkar.json';

  static const List<Map<String, String>> randomVerses = [
    {'text': 'الَّذِينَ آمَنُوا وَتَطْمَئِنُّ قُلُوبُهُم بِذِكْرِ اللَّهِ ۗ أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ', 'surah': 'سورة الرعد: 28'},
    {'text': 'وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ ۖ أُجِيبُ دَعْوَةَ الدَّاعِ إِذَا دَانِ', 'surah': 'سورة البقرة: 186'},
    {'text': 'إِنَّ مَعَ الْعُسْرِ يُسْرًا', 'surah': 'سورة الشرح: 6'},
  ];

  static const List<HadithBook> hadithBooks = [
    HadithBook(id: 'bukhari', name: 'صحيح البخاري', author: 'الإمام البخاري', apiKey: 'ara-bukhari'),
    HadithBook(id: 'muslim', name: 'صحيح مسلم', author: 'الإمام مسلم', apiKey: 'ara-muslim'),
  ];

  static final List<Reciter> fallbackReciters = [
    const Reciter(id: '54', name: 'مشاري العفاسي', rewaya: 'حفص عن عاصم', serverUrl: 'https://server8.mp3quran.net/afs/'),
    const Reciter(id: '121', name: 'ماهر المعيقلي', rewaya: 'حفص عن عاصم', serverUrl: 'https://server12.mp3quran.net/maher/'),
  ];

  static const List<Surah> allSurahs = [
    Surah(id: 1, name: 'الفاتحة', englishName: 'Al-Fatihah', versesCount: 7, revelationType: 'مكية'),
    Surah(id: 2, name: 'البقرة', englishName: 'Al-Baqarah', versesCount: 286, revelationType: 'مدنية'),
    Surah(id: 18, name: 'الكهف', englishName: 'Al-Kahf', versesCount: 110, revelationType: 'مكية'),
    Surah(id: 36, name: 'يس', englishName: 'Ya-Sin', versesCount: 83, revelationType: 'مكية'),
    Surah(id: 67, name: 'الملك', englishName: 'Al-Mulk', versesCount: 30, revelationType: 'مكية'),
    Surah(id: 112, name: 'الإخلاص', englishName: 'Al-Ikhlas', versesCount: 4, revelationType: 'مكية'),
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
    return '${reciter.serverUrl}${surahId.toString().padLeft(3, '0')}.mp3';
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
        return PrayerTimesData(timings: Map<String, String>.from(data['data']['timings']), date: data['data']['date']['readable'], cityArabic: 'موقعي');
      }
    } catch (_) {}
    return null;
  }

  static Future<List<ZekrItem>> fetchAzkarFromApi() async {
    try {
      final response = await http.get(Uri.parse(azkarApiUrl)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        List<ZekrItem> items = [];
        if (decoded is Map) {
          decoded.forEach((key, value) {
            if (value is List) {
              for (var elem in value) {
                if (elem is Map<String, dynamic>) items.add(ZekrItem.fromJson(elem, key));
              }
            }
          });
        }
        return items;
      }
    } catch (_) {}
    return [];
  }

  static Future<List<HadithItem>> fetchHadithsByBook(HadithBook book) async {
    try {
      final url = 'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/${book.apiKey}.json';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        final List list = decoded['hadiths'] ?? [];
        return list.map((h) => HadithItem.fromJson(h, book.id, book.name)).toList();
      }
    } catch (_) {}
    return [];
  }
}
