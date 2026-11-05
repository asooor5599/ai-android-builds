import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/models/quran_models.dart';

class QuranDataService {
  static const List<Reciter> reciters = [
    Reciter(
      id: 'afs',
      name: 'مشاري بن راشد العفاسي',
      rewaya: 'حفص عن عاصم',
      serverUrl: 'https://server8.mp3quran.net/afs/',
    ),
    Reciter(
      id: 'basit',
      name: 'عبد الباسط عبد الصمد',
      rewaya: 'المصحف المرتل',
      serverUrl: 'https://server7.mp3quran.net/basit/',
    ),
    Reciter(
      id: 'hussary',
      name: 'محمود خليل الحصري',
      rewaya: 'حفص عن عاصم',
      serverUrl: 'https://server13.mp3quran.net/hussary/',
    ),
    Reciter(
      id: 'maher',
      name: 'ماهر المعيقلي',
      rewaya: 'حفص عن عاصم',
      serverUrl: 'https://server12.mp3quran.net/maher/',
    ),
    Reciter(
      id: 's_gmd',
      name: 'سعد الغامدي',
      rewaya: 'حفص عن عاصم',
      serverUrl: 'https://server7.mp3quran.net/s_gmd/',
    ),
    Reciter(
      id: 'minsh',
      name: 'محمد صديق المنشاوي',
      rewaya: 'المصحف المرتل',
      serverUrl: 'https://server10.mp3quran.net/minsh/',
    ),
    Reciter(
      id: 'shatri',
      name: 'أبو بكر الشاطري',
      rewaya: 'حفص عن عاصم',
      serverUrl: 'https://server11.mp3quran.net/shatri/',
    ),
    Reciter(
      id: 'yasser',
      name: 'ياسر الدوسري',
      rewaya: 'حفص عن عاصم',
      serverUrl: 'https://server11.mp3quran.net/yasser/',
    ),
  ];

  static const List<Surah> surahs = [
    Surah(id: 1, name: 'الفاتحة', englishName: 'Al-Fatihah', versesCount: 7, revelationType: 'مكية', page: 1),
    Surah(id: 2, name: 'البقرة', englishName: 'Al-Baqarah', versesCount: 286, revelationType: 'مدنية', page: 2),
    Surah(id: 3, name: 'آل عمران', englishName: 'Ali Imran', versesCount: 200, revelationType: 'مدنية', page: 50),
    Surah(id: 4, name: 'النساء', englishName: 'An-Nisa', versesCount: 176, revelationType: 'مدنية', page: 77),
    Surah(id: 5, name: 'المائدة', englishName: 'Al-Ma' 'idah', versesCount: 120, revelationType: 'مدنية', page: 106),
    Surah(id: 6, name: 'الأنعام', englishName: 'Al-An' 'am', versesCount: 165, revelationType: 'مكية', page: 128),
    Surah(id: 7, name: 'الأعراف', englishName: 'Al-A' 'raf', versesCount: 206, revelationType: 'مكية', page: 151),
    Surah(id: 8, name: 'الأنفال', englishName: 'Al-Anfal', versesCount: 75, revelationType: 'مدنية', page: 177),
    Surah(id: 9, name: 'التوبة', englishName: 'At-Tawbah', versesCount: 129, revelationType: 'مدنية', page: 187),
    Surah(id: 10, name: 'يونس', englishName: 'Yunus', versesCount: 109, revelationType: 'مكية', page: 208),
    Surah(id: 11, name: 'هود', englishName: 'Hud', versesCount: 123, revelationType: 'مكية', page: 221),
    Surah(id: 12, name: 'يوسف', englishName: 'Yusuf', versesCount: 111, revelationType: 'مكية', page: 235),
    Surah(id: 13, name: 'الرعد', englishName: 'Ar-Ra' 'd', versesCount: 43, revelationType: 'مدنية', page: 249),
    Surah(id: 14, name: 'إبراهيم', englishName: 'Ibrahim', versesCount: 52, revelationType: 'مكية', page: 255),
    Surah(id: 15, name: 'الحجر', englishName: 'Al-Hijr', versesCount: 99, revelationType: 'مكية', page: 262),
    Surah(id: 16, name: 'النحل', englishName: 'An-Nahl', versesCount: 128, revelationType: 'مكية', page: 267),
    Surah(id: 17, name: 'الإسراء', englishName: 'Al-Isra', versesCount: 111, revelationType: 'مكية', page: 282),
    Surah(id: 18, name: 'الكهف', englishName: 'Al-Kahf', versesCount: 110, revelationType: 'مكية', page: 293),
    Surah(id: 19, name: 'مريم', englishName: 'Maryam', versesCount: 98, revelationType: 'مكية', page: 305),
    Surah(id: 20, name: 'طه', englishName: 'Taha', versesCount: 135, revelationType: 'مكية', page: 312),
    Surah(id: 21, name: 'الأنبياء', englishName: 'Al-Anbiya', versesCount: 112, revelationType: 'مكية', page: 322),
    Surah(id: 22, name: 'الحج', englishName: 'Al-Hajj', versesCount: 78, revelationType: 'مدنية', page: 332),
    Surah(id: 23, name: 'المؤمنون', englishName: 'Al-Mu' 'minun', versesCount: 118, revelationType: 'مكية', page: 342),
    Surah(id: 24, name: 'النور', englishName: 'An-Nur', versesCount: 64, revelationType: 'مدنية', page: 350),
    Surah(id: 25, name: 'الفرقان', englishName: 'Al-Furqan', versesCount: 77, revelationType: 'مكية', page: 359),
    Surah(id: 36, name: 'يس', englishName: 'Ya-Sin', versesCount: 83, revelationType: 'مكية', page: 440),
    Surah(id: 55, name: 'الرحمن', englishName: 'Ar-Rahman', versesCount: 78, revelationType: 'مدنية', page: 531),
    Surah(id: 56, name: 'الواقعة', englishName: 'Al-Waqi' 'ah', versesCount: 96, revelationType: 'مكية', page: 534),
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
      final response = await http
          .get(Uri.parse('https://api.alquran.cloud/v1/surah/$surahId/quran-uthmani'))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List ayahs = data['data']['ayahs'];
        return ayahs
            .map((e) => Verse(
                  number: e['number'],
                  numberInSurah: e['numberInSurah'],
                  text: e['text'],
                ))
            .toList();
      }
    } catch (_) {}

    return getFallbackVerses(surahId);
  }

  static List<Verse> getFallbackVerses(int surahId) {
    if (surahId == 1) {
      return const [
        Verse(number: 1, numberInSurah: 1, text: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ'),
        Verse(number: 2, numberInSurah: 2, text: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ'),
        Verse(number: 3, numberInSurah: 3, text: 'الرَّحْمَٰنِ الرَّحِيمِ'),
        Verse(number: 4, numberInSurah: 4, text: 'مَالِكِ يَوْمِ الدِّينِ'),
        Verse(number: 5, numberInSurah: 5, text: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ'),
        Verse(number: 6, numberInSurah: 6, text: 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ'),
        Verse(number: 7, numberInSurah: 7, text: 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ'),
      ];
    } else if (surahId == 112) {
      return const [
        Verse(number: 1, numberInSurah: 1, text: 'قُلْ هُوَ اللَّهُ أَحَدٌ'),
        Verse(number: 2, numberInSurah: 2, text: 'اللَّهُ الصَّمَدُ'),
        Verse(number: 3, numberInSurah: 3, text: 'لَمْ يَلِدْ وَلَمْ يُولَدْ'),
        Verse(number: 4, numberInSurah: 4, text: 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ'),
      ];
    } else if (surahId == 113) {
      return const [
        Verse(number: 1, numberInSurah: 1, text: 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ'),
        Verse(number: 2, numberInSurah: 2, text: 'مِن شَرِّ مَا خَلَقَ'),
        Verse(number: 3, numberInSurah: 3, text: 'وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ'),
        Verse(number: 4, numberInSurah: 4, text: 'وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ'),
        Verse(number: 5, numberInSurah: 5, text: 'وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ'),
      ];
    } else if (surahId == 114) {
      return const [
        Verse(number: 1, numberInSurah: 1, text: 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ'),
        Verse(number: 2, numberInSurah: 2, text: 'مَلِكِ النَّاسِ'),
        Verse(number: 3, numberInSurah: 3, text: 'إِلَٰهِ النَّاسِ'),
        Verse(number: 4, numberInSurah: 4, text: 'مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ'),
        Verse(number: 5, numberInSurah: 5, text: 'الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ'),
        Verse(number: 6, numberInSurah: 6, text: 'مِنَ الْجِنَّةِ وَالنَّاسِ'),
      ];
    }
    return [
      const Verse(number: 1, numberInSurah: 1, text: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ'),
      Verse(
        number: 2,
        numberInSurah: 2,
        text: 'جارٍ تحميل آيات السورة من الشبكة... (يرجى التأكد من توفر الاتصال بالإنترنت)',
      ),
    ];
  }
}
