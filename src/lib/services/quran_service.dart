import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/models/quran_models.dart';

class QuranService {
  static const String recitersApiUrl = 'https://www.mp3quran.net/api/v3/reciters?language=ar';

  static final List<Reciter> fallbackReciters = [
    const Reciter(id: '54', name: 'مشاري العفاسي', rewaya: 'حفص عن عاصم', serverUrl: 'https://server8.mp3quran.net/afs/'),
    const Reciter(id: '102', name: 'عبد الباسط عبد الصمد', rewaya: 'المصحف المرتل', serverUrl: 'https://server7.mp3quran.net/basit/'),
    const Reciter(id: '121', name: 'ماهر المعيقلي', rewaya: 'حفص عن عاصم', serverUrl: 'https://server12.mp3quran.net/maher/'),
    const Reciter(id: '118', name: 'محمود خليل الحصري', rewaya: 'حفص عن عاصم', serverUrl: 'https://server13.mp3quran.net/hssrs/'),
    const Reciter(id: '90', name: 'سعد الغامدي', rewaya: 'حفص عن عاصم', serverUrl: 'https://server7.mp3quran.net/s_gmd/'),
  ];

  static const List<Surah> allSurahs = [
    Surah(id: 1, name: 'الفاتحة', englishName: 'Al-Fatihah', versesCount: 7, revelationType: 'مكية'),
    Surah(id: 2, name: 'البقرة', englishName: 'Al-Baqarah', versesCount: 286, revelationType: 'مدنية'),
    Surah(id: 3, name: 'آل عمران', englishName: 'Al-Imran', versesCount: 200, revelationType: 'مدنية'),
    Surah(id: 4, name: 'النساء', englishName: 'An-Nisa', versesCount: 176, revelationType: 'مدنية'),
    Surah(id: 5, name: 'المائدة', englishName: 'Al-Maidahan', versesCount: 120, revelationType: 'مدنية'),
    Surah(id: 6, name: 'الأنعام', englishName: 'Al-Anam', versesCount: 165, revelationType: 'مكية'),
    Surah(id: 7, name: 'الأعراف', englishName: 'Al-Araf', versesCount: 206, revelationType: 'مكية'),
    Surah(id: 8, name: 'الأنفال', englishName: 'Al-Anfal', versesCount: 75, revelationType: 'مدنية'),
    Surah(id: 9, name: 'التوبة', englishName: 'At-Tawbah', versesCount: 129, revelationType: 'مدنية'),
    Surah(id: 10, name: 'يونس', englishName: 'Yunus', versesCount: 109, revelationType: 'مكية'),
    Surah(id: 11, name: 'هود', englishName: 'Hud', versesCount: 123, revelationType: 'مكية'),
    Surah(id: 12, name: 'يوسف', englishName: 'Yusuf', versesCount: 111, revelationType: 'مكية'),
    Surah(id: 13, name: 'الرعد', englishName: 'Ar-Rad', versesCount: 43, revelationType: 'مدنية'),
    Surah(id: 14, name: 'إبراهيم', englishName: 'Ibrahim', versesCount: 52, revelationType: 'مكية'),
    Surah(id: 15, name: 'الحجر', englishName: 'Al-Hijr', versesCount: 99, revelationType: 'مكية'),
    Surah(id: 16, name: 'النحل', englishName: 'An-Nahl', versesCount: 128, revelationType: 'مكية'),
    Surah(id: 17, name: 'الإسراء', englishName: 'Al-Isra', versesCount: 111, revelationType: 'مكية'),
    Surah(id: 18, name: 'الكهف', englishName: 'Al-Kahf', versesCount: 110, revelationType: 'مكية'),
    Surah(id: 19, name: 'مريم', englishName: 'Maryam', versesCount: 98, revelationType: 'مكية'),
    Surah(id: 20, name: 'طه', englishName: 'Taha', versesCount: 135, revelationType: 'مكية'),
    Surah(id: 21, name: 'الأنبياء', englishName: 'Al-Anbiya', versesCount: 112, revelationType: 'مكية'),
    Surah(id: 22, name: 'الحج', englishName: 'Al-Hajj', versesCount: 78, revelationType: 'مدنية'),
    Surah(id: 23, name: 'المؤمنون', englishName: 'Al-Muminun', versesCount: 118, revelationType: 'مكية'),
    Surah(id: 24, name: 'النور', englishName: 'An-Nur', versesCount: 64, revelationType: 'مدنية'),
    Surah(id: 25, name: 'الفرقان', englishName: 'Al-Furqan', versesCount: 77, revelationType: 'مكية'),
    Surah(id: 26, name: 'الشعراء', englishName: 'Ash-Shuara', versesCount: 227, revelationType: 'مكية'),
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
    Surah(id: 56, name: 'الواقعة', englishName: 'Al-Waqiah', versesCount: 96, revelationType: 'مكية'),
    Surah(id: 57, name: 'الحديد', englishName: 'Al-Hadid', versesCount: 29, revelationType: 'مدنية'),
    Surah(id: 58, name: 'المجادلة', englishName: 'Al-Mujadila', versesCount: 22, revelationType: 'مدنية'),
    Surah(id: 59, name: 'الحشر', englishName: 'Al-Hashr', versesCount: 24, revelationType: 'مدنية'),
    Surah(id: 60, name: 'الممتحنة', englishName: 'Al-Mumtahanah', versesCount: 13, revelationType: 'مدنية'),
    Surah(id: 61, name: 'الصف', englishName: 'As-Saff', versesCount: 14, revelationType: 'مدنية'),
    Surah(id: 62, name: 'الجمعة', englishName: 'Al-Jumuah', versesCount: 11, revelationType: 'مدنية'),
    Surah(id: 63, name: 'المنافقون', englishName: 'Al-Munafiqun', versesCount: 11, revelationType: 'مدنية'),
    Surah(id: 64, name: 'التغابن', englishName: 'At-Taghabun', versesCount: 18, revelationType: 'مدنية'),
    Surah(id: 65, name: 'الطلاق', englishName: 'At-Talaq', versesCount: 12, revelationType: 'مدنية'),
    Surah(id: 66, name: 'التحريم', englishName: 'At-Tahrim', versesCount: 12, revelationType: 'مدنية'),
    Surah(id: 67, name: 'الملك', englishName: 'Al-Mulk', versesCount: 30, revelationType: 'مكية'),
    Surah(id: 68, name: 'القلم', englishName: 'Al-Qalam', versesCount: 52, revelationType: 'مكية'),
    Surah(id: 69, name: 'الحاقة', englishName: 'Al-Haqqah', versesCount: 52, revelationType: 'مكية'),
    Surah(id: 70, name: 'المعارج', englishName: 'Al-Maarij', versesCount: 44, revelationType: 'مكية'),
    Surah(id: 71, name: 'نوح', englishName: 'Nuh', versesCount: 28, revelationType: 'مكية'),
    Surah(id: 72, name: 'الجن', englishName: 'Al-Jinn', versesCount: 28, revelationType: 'مكية'),
    Surah(id: 73, name: 'المزمل', englishName: 'Al-Muzzammil', versesCount: 20, revelationType: 'مكية'),
    Surah(id: 74, name: 'المدثر', englishName: 'Al-Muddaththir', versesCount: 56, revelationType: 'مكية'),
    Surah(id: 75, name: 'القيامة', englishName: 'Al-Qiyamah', versesCount: 40, revelationType: 'مكية'),
    Surah(id: 76, name: 'الإنسان', englishName: 'Al-Insan', versesCount: 31, revelationType: 'مدنية'),
    Surah(id: 77, name: 'المرسلات', englishName: 'Al-Mursalat', versesCount: 50, revelationType: 'مكية'),
    Surah(id: 78, name: 'النبأ', englishName: 'An-Naba', versesCount: 40, revelationType: 'مكية'),
    Surah(id: 79, name: 'النازعات', englishName: 'An-Naziat', versesCount: 46, revelationType: 'مكية'),
    Surah(id: 80, name: 'عبس', englishName: 'Abasa', versesCount: 42, revelationType: 'مكية'),
    Surah(id: 81, name: 'التكوير', englishName: 'At-Takwir', versesCount: 29, revelationType: 'مكية'),
    Surah(id: 82, name: 'الانفطار', englishName: 'Al-Infitar', versesCount: 19, revelationType: 'مكية'),
    Surah(id: 83, name: 'المطففين', englishName: 'Al-Mutaffifin', versesCount: 36, revelationType: 'مكية'),
    Surah(id: 84, name: 'الانشقاق', englishName: 'Al-Inshiqaq', versesCount: 25, revelationType: 'مكية'),
    Surah(id: 85, name: 'البروج', englishName: 'Al-Buruj', versesCount: 22, revelationType: 'مكية'),
    Surah(id: 86, name: 'الطارق', englishName: 'At-Tariq', versesCount: 17, revelationType: 'مكية'),
    Surah(id: 87, name: 'الأعلى', englishName: 'Al-Ala', versesCount: 19, revelationType: 'مكية'),
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
    Surah(id: 101, name: 'القارعة', englishName: 'Al-Qariah', versesCount: 11, revelationType: 'مكية'),
    Surah(id: 102, name: 'التكاثر', englishName: 'At-Takathur', versesCount: 8, revelationType: 'مكية'),
    Surah(id: 103, name: 'العصر', englishName: 'Al-Asr', versesCount: 3, revelationType: 'مكية'),
    Surah(id: 104, name: 'الهمزة', englishName: 'Al-Humazah', versesCount: 9, revelationType: 'مكية'),
    Surah(id: 105, name: 'الفيل', englishName: 'Al-Fil', versesCount: 5, revelationType: 'مكية'),
    Surah(id: 106, name: 'قريش', englishName: 'Quraysh', versesCount: 4, revelationType: 'مكية'),
    Surah(id: 107, name: 'الماعون', englishName: 'Al-Maun', versesCount: 7, revelationType: 'مكية'),
    Surah(id: 108, name: 'الكوثر', englishName: 'Al-Kawthar', versesCount: 3, revelationType: 'مكية'),
    Surah(id: 109, name: 'الكافرون', englishName: 'Al-Kafirun', versesCount: 6, revelationType: 'مكية'),
    Surah(id: 110, name: 'النصر', englishName: 'An-Nasr', versesCount: 3, revelationType: 'مدنية'),
    Surah(id: 111, name: 'المسد', englishName: 'Al-Masad', versesCount: 5, revelationType: 'مكية'),
    Surah(id: 112, name: 'الإخلاص', englishName: 'Al-Ikhlas', versesCount: 4, revelationType: 'مكية'),
    Surah(id: 113, name: 'الفلق', englishName: 'Al-Falaq', versesCount: 5, revelationType: 'مكية'),
    Surah(id: 114, name: 'الناس', englishName: 'An-Nas', versesCount: 6, revelationType: 'مكية'),
  ];

  static final List<ZekrItem> azkarLibrary = [
    const ZekrItem(
      id: 'z1',
      category: 'أذكار الصباح',
      text: 'أَصْبَحْنَا وَأَصْبَحَ المُلْكُ لِلَّهِ، وَالحَمْدُ لِلَّهِ لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ.',
      count: '1',
      description: 'من قالها حين يصبح أجير بها في يومه.',
    ),
    const ZekrItem(
      id: 'z2',
      category: 'أذكار الصباح',
      text: 'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ.',
      count: '1',
      description: 'دعاء الصباح والتوكل على الله.',
    ),
    const ZekrItem(
      id: 'z3',
      category: 'أذكار المساء',
      text: 'أَمْسَيْنَا وَأَمْسَى المُلْكُ لِلَّهِ، وَالحَمْدُ لِلَّهِ لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ.',
      count: '1',
      description: 'من قالها حين يمسي حفظ في ليلته.',
    ),
    const ZekrItem(
      id: 'z4',
      category: 'أدعية قرآنية',
      text: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ.',
      count: '3',
      description: 'سورة البقرة - الآية 201',
    ),
    const ZekrItem(
      id: 'z5',
      category: 'أدعية قرآنية',
      text: 'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي وَاحْلُلْ عُقْدَةً مِّن لِّسَانِي يَفْقَهُوا قَوْلِي.',
      count: '1',
      description: 'دعاء سيدنا موسى عليه السلام',
    ),
  ];

  static Future<List<Reciter>> fetchReciters() async {
    try {
      final response = await http.get(Uri.parse(recitersApiUrl)).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final List recitersJson = data['reciters'] ?? [];
        final list = recitersJson
            .map((r) => Reciter.fromJson(r))
            .where((r) => r.serverUrl.isNotEmpty)
            .toList();
        if (list.isNotEmpty) return list;
      }
    } catch (_) {}
    return fallbackReciters;
  }

  static String getAudioUrl(Reciter reciter, int surahId) {
    final formattedId = surahId.toString().padLeft(3, '0');
    return '${reciter.serverUrl}$formattedId.mp3';
  }

  static Future<List<Verse>> fetchSurahVerses(int surahId) async {
    try {
      final url = 'https://api.alquran.cloud/v1/surah/$surahId/quran-uthmani';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final List ayahs = data['data']['ayahs'];
        return ayahs.map((e) => Verse(
          number: e['number'] as int,
          numberInSurah: e['numberInSurah'] as int,
          text: e['text'] as String,
        )).toList();
      }
    } catch (_) {}

    return _getFallbackVerses(surahId);
  }

  static List<Verse> _getFallbackVerses(int surahId) {
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
    return List.generate(
      QuranService.allSurahs.firstWhere((s) => s.id == surahId, orElse: () => QuranService.allSurahs.first).versesCount,
      (index) => Verse(
        number: index + 1,
        numberInSurah: index + 1,
        text: 'آية رقم ${index + 1} من سورة الشريفة. (يتطلب اتصال بالإنترنت لعرض النص الكامل)',
      ),
    );
  }
}
