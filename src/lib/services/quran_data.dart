import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/models/quran_models.dart';

class QuranDataService {
  static const List<Reciter> reciters = [
    Reciter(id: 'afs', name: 'مشاري بن راشد العفاسي', rewaya: 'حفص عن عاصم', serverUrl: 'https://server8.mp3quran.net/afs/'),
    Reciter(id: 'basit', name: 'عبد الباسط عبد الصمد', rewaya: 'المصحف المرتل', serverUrl: 'https://server7.mp3quran.net/basit/'),
    Reciter(id: 'hussary', name: 'محمود خليل الحصري', rewaya: 'حفص عن عاصم', serverUrl: 'https://server13.mp3quran.net/hussary/'),
    Reciter(id: 'maher', name: 'ماهر المعيقلي', rewaya: 'حفص عن عاصم', serverUrl: 'https://server12.mp3quran.net/maher/'),
    Reciter(id: 's_gmd', name: 'سعد الغامدي', rewaya: 'حفص عن عاصم', serverUrl: 'https://server7.mp3quran.net/s_gmd/'),
    Reciter(id: 'minsh', name: 'محمد صديق المنشاوي', rewaya: 'المصحف المرتل', serverUrl: 'https://server10.mp3quran.net/minsh/'),
  ];

  static const List<Surah> surahs = [
    Surah(id: 1, name: 'الفاتحة', englishName: 'Al-Fatihah', versesCount: 7, revelationType: 'مكية', page: 1),
    Surah(id: 2, name: 'البقرة', englishName: 'Al-Baqarah', versesCount: 286, revelationType: 'مدنية', page: 2),
    Surah(id: 3, name: 'آل عمران', englishName: 'Ali Imran', versesCount: 200, revelationType: 'مدنية', page: 50),
    Surah(id: 4, name: 'النساء', englishName: 'An-Nisa', versesCount: 176, revelationType: 'مدنية', page: 77),
    Surah(id: 18, name: 'الكهف', englishName: 'Al-Kahf', versesCount: 110, revelationType: 'مكية', page: 293),
    Surah(id: 36, name: 'يس', englishName: 'Ya-Sin', versesCount: 83, revelationType: 'مكية', page: 440),
    Surah(id: 55, name: 'الرحمن', englishName: 'Ar-Rahman', versesCount: 78, revelationType: 'مدنية', page: 531),
    Surah(id: 67, name: 'الملك', englishName: 'Al-Mulk', versesCount: 30, revelationType: 'مكية', page: 562),
    Surah(id: 112, name: 'الإخلاص', englishName: 'Al-Ikhlas', versesCount: 4, revelationType: 'مكية', page: 604),
    Surah(id: 113, name: 'الفلق', englishName: 'Al-Falaq', versesCount: 5, revelationType: 'مكية', page: 604),
    Surah(id: 114, name: 'الناس', englishName: 'An-Nas', versesCount: 6, revelationType: 'مكية', page: 604),
  ];

  static String getAudioUrl(Reciter reciter, int surahId) {
    final formattedNumber = surahId.toString().padLeft(3, '0');
    return '${reciter.serverUrl}$formattedNumber.mp3';
  }

  static Future<List<Verse>> fetchSurahVerses(int surahId) async {
    try {
      final response = await http.get(Uri.parse('https://api.alquran.cloud/v1/surah/$surahId/quran-uthmani')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List ayahs = data['data']['ayahs'];
        return ayahs.map((e) => Verse(number: e['number'], numberInSurah: e['numberInSurah'], text: e['text'])).toList();
      }
    } catch (_) {}
    return [const Verse(number: 1, numberInSurah: 1, text: 'تعذر تحميل الآيات، يرجى التحقق من الاتصال بالإنترنت.')];
  }
}
