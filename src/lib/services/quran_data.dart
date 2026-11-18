import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/models/quran_models.dart';

class QuranDataService {
  static const String mp3QuranApiUrl = 'https://www.mp3quran.net/api/v3/reciters?language=ar';
  static const String azkarApiUrl = 'https://raw.githubusercontent.com/nawafalqari/azkar-api/56df51279ab6eb86dc2f6202c7de26c8948331c1/azkar.json';

  static final Map<int, List<Verse>> _versesCache = {};

  static const List<Map<String, String>> randomVerses = [
    {'text': 'الَّذِينَ آمَنُوا وَتَطْمَئِنُّ قُلُوبُهُم بِذِكْرِ اللَّهِ ۗ أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ', 'surah': 'سورة الرعد: 28'},
    {'text': 'وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ ۖ أُجِيبُ دَعْوَةَ الدَّاعِ إِذَا دَانِ', 'surah': 'سورة البقرة: 186'},
    {'text': 'إِنَّ مَعَ الْعُسْرِ يُسْرًا', 'surah': 'سورة الشرح: 6'},
    {'text': 'وَقُل رَّبِّ زِدْنِي عِلْمًا', 'surah': 'سورة طه: 114'},
    {'text': 'فَاصْبِرْ صَبْرًا جَمِيلًا', 'surah': 'سورة المعارج: 5'},
    {'text': 'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ', 'surah': 'سورة الطلاق: 3'},
  ];

  static final List<Reciter> fallbackReciters = [
    const Reciter(id: '54', name: 'مشاري العفاسي', rewaya: 'حفص عن عاصم', serverUrl: 'https://server8.mp3quran.net/afs/'),
    const Reciter(id: '102', name: 'عبد الباسط عبد الصمد', rewaya: 'المصحف المرتل', serverUrl: 'https://server7.mp3quran.net/basit/'),
    const Reciter(id: '121', name: 'ماهر المعيقلي', rewaya: 'حفص عن عاصم', serverUrl: 'https://server12.mp3quran.net/maher/'),
    const Reciter(id: '118', name: 'محمود خليل الحصري', rewaya: 'حفص عن عاصم', serverUrl: 'https://server13.mp3quran.net/hssrs/'),
  ];

  static const List<Surah> allSurahs = [
    Surah(id: 1, name: 'الفاتحة', englishName: 'Al-Fatihah', versesCount: 7, revelationType: 'مكية'),
    Surah(id: 2, name: 'البقرة', englishName: 'Al-Baqarah', versesCount: 286, revelationType: 'مدنية'),
    Surah(id: 3, name: 'آل عمران', englishName: 'Al-Imran', versesCount: 200, revelationType: 'مدنية'),
    Surah(id: 4, name: 'النساء', englishName: 'An-Nisa', versesCount: 176, revelationType: 'مدنية'),
    Surah(id: 5, name: 'المائدة', englishName: 'Al-Ma\'idah', versesCount: 120, revelationType: 'مدنية'),
    Surah(id: 6, name: 'الأنعام', englishName: 'Al-An\'am', versesCount: 165, revelationType: 'مكية'),
    Surah(id: 7, name: 'الأعراف', englishName: 'Al-A\'raf', versesCount: 206, revelationType: 'مكية'),
    Surah(id: 8, name: 'الأنفال', englishName: 'Al-Anfal', versesCount: 75, revelationType: 'مدنية'),
    Surah(id: 9, name: 'التوبة', englishName: 'At-Tawbah', versesCount: 129, revelationType: 'مدنية'),
    Surah(id: 10, name: 'يونس', englishName: 'Yunus', versesCount: 109, revelationType: 'مكية'),
    Surah(id: 11, name: 'هود', englishName: 'Hud', versesCount: 123, revelationType: 'مكية'),
    Surah(id: 12, name: 'يوسف', englishName: 'Yusuf', versesCount: 111, revelationType: 'مكية'),
    Surah(id: 13, name: 'الرعد', englishName: 'Ar-Ra\'d', versesCount: 43, revelationType: 'مدنية'),
    Surah(id: 14, name: 'إبراهيم', englishName: 'Ibrahim', versesCount: 52, revelationType: 'مكية'),
    Surah(id: 15, name: 'الحجر', englishName: 'Al-Hijr', versesCount: 99, revelationType: 'مكية'),
    Surah(id: 16, name: 'النحل', englishName: 'An-Nahl', versesCount: 128, revelationType: 'مكية'),
    Surah(id: 17, name: 'الإسراء', englishName: 'Al-Isra', versesCount: 111, revelationType: 'مكية'),
    Surah(id: 18, name: 'الكهف', englishName: 'Al-Kahf', versesCount: 110, revelationType: 'مكية'),
    Surah(id: 19, name: 'مريم', englishName: 'Maryam', versesCount: 98, revelationType: 'مكية'),
    Surah(id: 20, name: 'طه', englishName: 'Taha', versesCount: 135, revelationType: 'مكية'),
    Surah(id: 21, name: 'الأنبياء', englishName: 'Al-Anbiya', versesCount: 112, revelationType: 'مكية'),
    Surah(id: 22, name: 'الحج', englishName: 'Al-Hajj', versesCount: 78, revelationType: 'مدنية'),
    Surah(id: 23, name: 'المؤمنون', englishName: 'Al-Mu\'minun', versesCount: 118, revelationType: 'مكية'),
    Surah(id: 24, name: 'النور', englishName: 'An-Nur', versesCount: 64, revelationType: 'مدنية'),
    Surah(id: 25, name: 'الفرقان', englishName: 'Al-Furqan', versesCount: 77, revelationType: 'مكية'),
    Surah(id: 26, name: 'الشعراء', englishName: 'Ash-Shu\'ara', versesCount: 227, revelationType: 'مكية'),
    Surah(id: 27, name: 'النمل', englishName: 'An-Naml', versesCount: 93, revelationType: 'مكية'),
    Surah(id: 28, name: 'القصص', englishName: 'Al-Qasas', versesCount: 88, revelationType: 'مكية'),
    Surah(id: 29, name: 'العنكبوت', englishName: 'Al-Ankabut', versesCount: 69, revelationType: 'مكية'),
    Surah(id: 30, name: 'الروم', englishName: 'Ar-Rum', versesCount: 60, revelationType: 'مكية'),
    Surah(id: 31, name: 'لقمان', englishName: 'Luqman', versesCount: 34, revelationType: 'مكية'),
    Surah(id: 32, name: 'السجدة', englishName: 'As-Sajdah', versesCount: 30, revelationType: 'مكية'),
    Surah(id: 33, name: 'الأحزاب', englishName: 'Al-Ahzab', versesCount: 73, revelationType: 'مدنية'),
    Surah(id: 34, name: 'سبأ', englishName: 'Saba', versesCount: 54, revelationType: 'مكية'),
    Surah(id: 35, name: 'فاطر', englishName: 'Fatir', versesCount: 45, revelationType: 'مكية'),
    Surah(id: 36, name: 'يس', englishName: 'Ya-Sin', versesCount: 83, revelationType: 'مكية'),
    Surah(id: 37, name: 'الصافات', englishName: 'As-Saffat', versesCount: 182, revelationType: 'مكية'),
    Surah(id: 38, name: 'ص', englishName: 'Sad', versesCount: 88, revelationType: 'مكية'),
    Surah(id: 39, name: 'الزمر', englishName: 'Az-Zumar', versesCount: 75, revelationType: 'مكية'),
    Surah(id: 40, name: 'غافر', englishName: 'Ghafir', versesCount: 85, revelationType: 'مكية'),
    Surah(id: 41, name: 'فصلت', englishName: 'Fussilat', versesCount: 54, revelationType: 'مكية'),
    Surah(id: 42, name: 'الشورى', englishName: 'Ash-Shura', versesCount: 53, revelationType: 'مكية'),
    Surah(id: 43, name: 'الزخرف', englishName: 'Az-Zukhruf', versesCount: 89, revelationType: 'مكية'),
    Surah(id: 44, name: 'الدخان', englishName: 'Ad-Dukhan', versesCount: 59, revelationType: 'مكية'),
    Surah(id: 45, name: 'الجاثية', englishName: 'Al-Jathiyah', versesCount: 37, revelationType: 'مكية'),
    Surah(id: 46, name: 'الأحقاف', englishName: 'Al-Ahqaf', versesCount: 35, revelationType: 'مكية'),
    Surah(id: 47, name: 'محمد', englishName: 'Muhammad', versesCount: 38, revelationType: 'مدنية'),
    Surah(id: 48, name: 'الفتح', englishName: 'Al-Fath', versesCount: 29, revelationType: 'مدنية'),
    Surah(id: 49, name: 'الحجرات', englishName: 'Al-Hujurat', versesCount: 18, revelationType: 'مدنية'),
    Surah(id: 50, name: 'ق', englishName: 'Qaf', versesCount: 45, revelationType: 'مكية'),
    Surah(id: 51, name: 'الذاريات', englishName: 'Adh-Dhariyat', versesCount: 60, revelationType: 'مكية'),
    Surah(id: 52, name: 'الطور', englishName: 'At-Tur', versesCount: 49, revelationType: 'مكية'),
    Surah(id: 53, name: 'النجم', englishName: 'An-Najm', versesCount: 62, revelationType: 'مكية'),
    Surah(id: 54, name: 'القمر', englishName: 'Al-Qamar', versesCount: 55, revelationType: 'مكية'),
    Surah(id: 55, name: 'الرحمن', englishName: 'Ar-Rahman', versesCount: 78, revelationType: 'مدنية'),
    Surah(id: 56, name: 'الواقعة', englishName: 'Al-Waqi\'ah', versesCount: 96, revelationType: 'مكية'),
    Surah(id: 57, name: 'الحديد', englishName: 'Al-Hadid', versesCount: 29, revelationType: 'مدنية'),
    Surah(id: 58, name: 'المجادلة', englishName: 'Al-Mujadila', versesCount: 22, revelationType: 'مدنية'),
    Surah(id: 59, name: 'الحشر', englishName: 'Al-Hashr', versesCount: 24, revelationType: 'مدنية'),
    Surah(id: 60, name: 'الممتحنة', englishName: 'Al-Mumtahanah', versesCount: 13, revelationType: 'مدنية'),
    Surah(id: 61, name: 'الصف', englishName: 'As-Saff', versesCount: 14, revelationType: 'مدنية'),
    Surah(id: 62, name: 'الجمعة', englishName: 'Al-Jumu\'ah', versesCount: 11, revelationType: 'مدنية'),
    Surah(id: 63, name: 'المنافقون', englishName: 'Al-Munafiqun', versesCount: 11, revelationType: 'مدنية'),
    Surah(id: 64, name: 'التغابن', englishName: 'At-Taghabun', versesCount: 18, revelationType: 'مدنية'),
    Surah(id: 65, name: 'الطلاق', englishName: 'At-Talaq', versesCount: 12, revelationType: 'مدنية'),
    Surah(id: 66, name: 'التحريم', englishName: 'At-Tahrim', versesCount: 12, revelationType: 'مدنية'),
    Surah(id: 67, name: 'الملك', englishName: 'Al-Mulk', versesCount: 30, revelationType: 'مكية'),
    Surah(id: 68, name: 'القلم', englishName: 'Al-Qalam', versesCount: 52, revelationType: 'مكية'),
    Surah(id: 69, name: 'الحاقة', englishName: 'Al-Haqqah', versesCount: 52, revelationType: 'مكية'),
    Surah(id: 70, name: 'المعارج', englishName: 'Al-Ma\'arij', versesCount: 44, revelationType: 'مكية'),
    Surah(id: 71, name: 'نوح', englishName: 'Nuh', versesCount: 28, revelationType: 'مكية'),
    Surah(id: 72, name: 'الجن', englishName: 'Al-Jinn', versesCount: 28, revelationType: 'مكية'),
    Surah(id: 73, name: 'المزمل', englishName: 'Al-Muzzammil', versesCount: 20, revelationType: 'مكية'),
    Surah(id: 74, name: 'المدثر', englishName: 'Al-Muddaththir', versesCount: 56, revelationType: 'مكية'),
    Surah(id: 75, name: 'القيامة', englishName: 'Al-Qiyamah', versesCount: 40, revelationType: 'مكية'),
    Surah(id: 76, name: 'الإنسان', englishName: 'Al-Insan', versesCount: 31, revelationType: 'مدنية'),
    Surah(id: 77, name: 'المرسلات', englishName: 'Al-Mursalat', versesCount: 50, revelationType: 'مكية'),
    Surah(id: 78, name: 'النبأ', englishName: 'An-Naba', versesCount: 40, revelationType: 'مكية'),
    Surah(id: 79, name: 'النازعات', englishName: 'An-Nazi\'at', versesCount: 46, revelationType: 'مكية'),
    Surah(id: 80, name: 'عبس', englishName: 'Abasa', versesCount: 42, revelationType: 'مكية'),
    Surah(id: 81, name: 'التكوير', englishName: 'At-Takwir', versesCount: 29, revelationType: 'مكية'),
    Surah(id: 82, name: 'الانفطار', englishName: 'Al-Infitar', versesCount: 19, revelationType: 'مكية'),
    Surah(id: 83, name: 'المطففين', englishName: 'Al-Mutaffifin', versesCount: 36, revelationType: 'مكية'),
    Surah(id: 84, name: 'الانشقاق', englishName: 'Al-Inshiqaq', versesCount: 25, revelationType: 'مكية'),
    Surah(id: 85, name: 'البروج', englishName: 'Al-Buruj', versesCount: 22, revelationType: 'مكية'),
    Surah(id: 86, name: 'الطارق', englishName: 'At-Tariq', versesCount: 17, revelationType: 'مكية'),
    Surah(id: 87, name: 'الأعلى', englishName: 'Al-A\'la', versesCount: 19, revelationType: 'مكية'),
    Surah(id: 88, name: 'الغاشية', englishName: 'Al-Ghashiyah', versesCount: 26, revelationType: 'مكية'),
    Surah(id: 89, name: 'الفجر', englishName: 'Al-Fajr', versesCount: 30, revelationType: 'مكية'),
    Surah(id: 90, name: 'البلد', englishName: 'Al-Balad', versesCount: 20, revelationType: 'مكية'),
    Surah(id: 91, name: 'الشمس', englishName: 'Ash-Shams', versesCount: 15, revelationType: 'مكية'),
    Surah(id: 92, name: 'الليل', englishName: 'Al-Layl', versesCount: 21, revelationType: 'مكية'),
    Surah(id: 93, name: 'الضحى', englishName: 'Ad-Duha', versesCount: 11, revelationType: 'مكية'),
    Surah(id: 94, name: 'الشرح', englishName: 'Ash-Sharh', versesCount: 8, revelationType: 'مكية'),
    Surah(id: 95, name: 'التين', englishName: 'At-Tin', versesCount: 8, revelationType: 'مكية'),
    Surah(id: 96, name: 'العلق', englishName: 'Al-Alaq', versesCount: 19, revelationType: 'مكية'),
    Surah(id: 97, name: 'القدر', englishName: 'Al-Qadr', versesCount: 5, revelationType: 'مكية'),
    Surah(id: 98, name: 'البينة', englishName: 'Al-Bayyinah', versesCount: 8, revelationType: 'مدنية'),
    Surah(id: 99, name: 'الزلزلة', englishName: 'Az-Zalzalah', versesCount: 8, revelationType: 'مدنية'),
    Surah(id: 100, name: 'العاديات', englishName: 'Al-Adiyat', versesCount: 11, revelationType: 'مكية'),
    Surah(id: 101, name: 'القارعة', englishName: 'Al-Qari\'ah', versesCount: 11, revelationType: 'مكية'),
    Surah(id: 102, name: 'التكاثر', englishName: 'At-Takathur', versesCount: 8, revelationType: 'مكية'),
    Surah(id: 103, name: 'العصر', englishName: 'Al-Asr', versesCount: 3, revelationType: 'مكية'),
    Surah(id: 104, name: 'الهمزة', englishName: 'Al-Humazah', versesCount: 9, revelationType: 'مكية'),
    Surah(id: 105, name: 'الفيل', englishName: 'Al-Fil', versesCount: 5, revelationType: 'مكية'),
    Surah(id: 106, name: 'قريش', englishName: 'Quraysh', versesCount: 4, revelationType: 'مكية'),
    Surah(id: 107, name: 'الماعون', englishName: 'Al-Ma\'un', versesCount: 7, revelationType: 'مكية'),
    Surah(id: 108, name: 'الكوثر', englishName: 'Al-Kawthar', versesCount: 3, revelationType: 'مكية'),
    Surah(id: 109, name: 'الكافرون', englishName: 'Al-Kafirun', versesCount: 6, revelationType: 'مكية'),
    Surah(id: 110, name: 'النصر', englishName: 'An-Nasr', versesCount: 3, revelationType: 'مدنية'),
    Surah(id: 111, name: 'المسد', englishName: 'Al-Masad', versesCount: 5, revelationType: 'مكية'),
    Surah(id: 112, name: 'الإخلاص', englishName: 'Al-Ikhlas', versesCount: 4, revelationType: 'مكية'),
    Surah(id: 113, name: 'الفلق', englishName: 'Al-Falaq', versesCount: 5, revelationType: 'مكية'),
    Surah(id: 114, name: 'الناس', englishName: 'An-Nas', versesCount: 6, revelationType: 'مكية'),
  ];

  static final List<ZekrItem> fallbackAzkar = [
    const ZekrItem(
      id: 'fb_1',
      category: 'أذكار الصباح',
      zekr: 'أَصْبَحْنَا وَأَصْبَحَ المُلْكُ لِلَّهِ، وَالحَمْدُ لِلَّهِ لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ.',
      description: 'من قالها حين يصبح أجير بها في يومه.',
      count: '1',
      reference: 'مسلم',
    ),
    const ZekrItem(
      id: 'fb_2',
      category: 'أذكار المساء',
      zekr: 'أَمْسَيْنَا وَأَمْسَى المُلْكُ لِلَّهِ، وَالحَمْدُ لِلَّهِ لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ.',
      description: 'من قالها حين يمسي أجير بها في ليلته.',
      count: '1',
      reference: 'مسلم',
    ),
  ];

  static Future<List<Reciter>> fetchAllRecitersFromApi() async {
    try {
      final response = await http.get(Uri.parse(mp3QuranApiUrl)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final List recitersJson = data['reciters'] ?? [];
        final list = recitersJson.map((r) => Reciter.fromJson(r)).where((r) => r.serverUrl.isNotEmpty).toList();
        if (list.isNotEmpty) return list;
      }
    } catch (_) {}
    return fallbackReciters;
  }

  static String getAudioUrl(Reciter reciter, int surahId) {
    final formattedNumber = surahId.toString().padLeft(3, '0');
    return '${reciter.serverUrl}$formattedNumber.mp3';
  }

  static Future<List<Verse>> fetchSurahVerses(int surahId) async {
    if (_versesCache.containsKey(surahId)) {
      return _versesCache[surahId]!;
    }
    try {
      final response = await http.get(Uri.parse('https://api.alquran.cloud/v1/surah/$surahId/quran-uthmani')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final List ayahs = data['data']['ayahs'];
        final list = ayahs.map((e) => Verse(number: e['number'], numberInSurah: e['numberInSurah'], text: e['text'])).toList();
        if (list.isNotEmpty) {
          _versesCache[surahId] = list;
        }
        return list;
      }
    } catch (_) {}
    return [const Verse(number: 1, numberInSurah: 1, text: 'تعذر تحميل الآيات. يرجى التأكد من اتصال الإنترنت.')];
  }

  static Future<PrayerTimesData?> fetchPrayerTimes(double lat, double lng) async {
    try {
      String cityArabic = 'موقعي';
      try {
        final geoUrl = 'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&accept-language=ar';
        final geoResponse = await http.get(Uri.parse(geoUrl), headers: {'User-Agent': 'QuranApp/1.0'});
        if (geoResponse.statusCode == 200) {
          final geoData = json.decode(geoResponse.body);
          final address = geoData['address'];
          cityArabic = address['city'] ?? address['town'] ?? address['village'] ?? address['state'] ?? 'موقعي';
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

  static Future<List<ZekrItem>> fetchAzkarFromApi() async {
    try {
      final response = await http.get(Uri.parse(azkarApiUrl)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        List<ZekrItem> items = [];
        if (decoded is Map<String, dynamic>) {
          decoded.forEach((key, value) {
            if (key.toLowerCase().trim() == 'stop') return;
            if (value is List) {
              for (var elem in value) {
                if (elem is Map<String, dynamic>) {
                  items.add(ZekrItem.fromJson(elem, key));
                }
              }
            }
          });
        }
        if (items.isNotEmpty) return items;
      }
    } catch (_) {}
    return fallbackAzkar;
  }
}
