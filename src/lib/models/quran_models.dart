class Surah {
  final int id;
  final String name;
  final String englishName;
  final int versesCount;
  final String revelationType;
  const Surah({
    required this.id,
    required this.name,
    required this.englishName,
    required this.versesCount,
    required this.revelationType,
  });
}

class Reciter {
  final String id;
  final String name;
  final String rewaya;
  final String serverUrl;
  final List<int> availableSurahIds;
  const Reciter({
    required this.id,
    required this.name,
    required this.rewaya,
    required this.serverUrl,
    this.availableSurahIds = const [],
  });

  List<int> get effectiveSurahIds =>
      availableSurahIds.isEmpty ? List.generate(114, (i) => i + 1) : availableSurahIds;

  factory Reciter.fromJson(Map<String, dynamic> json) {
    final id = json['id'].toString();
    final name = json['name'] as String? ?? 'قارئ غير معروف';
    final moshafList = json['moshaf'] as List?;
    String serverUrl = '';
    String rewaya = 'المصحف المرتل';
    List<int> surahs = [];
    if (moshafList != null && moshafList.isNotEmpty) {
      final firstMoshaf = moshafList.first;
      serverUrl = firstMoshaf['server'] as String? ?? '';
      rewaya = firstMoshaf['name'] as String? ?? 'المصحف المرتل';
      final surahCsv = firstMoshaf['surah_list'] as String?;
      if (surahCsv != null && surahCsv.isNotEmpty) {
        surahs = surahCsv
            .split(',')
            .map((e) => int.tryParse(e.trim()) ?? 0)
            .where((e) => e > 0)
            .toList();
      }
    }
    if (serverUrl.isNotEmpty && !serverUrl.endsWith('/')) {
      serverUrl = '$serverUrl/';
    }
    return Reciter(
      id: id,
      name: name,
      rewaya: rewaya,
      serverUrl: serverUrl,
      availableSurahIds: surahs,
    );
  }
}

class Verse {
  final int number;
  final int numberInSurah;
  final String text;
  const Verse({
    required this.number,
    required this.numberInSurah,
    required this.text,
  });
}

class Bookmark {
  final int surahId;
  final String surahName;
  final int verseNumber;
  final String verseText;
  const Bookmark({
    required this.surahId,
    required this.surahName,
    required this.verseNumber,
    required this.verseText,
  });
  Map<String, dynamic> toJson() => {
        'surahId': surahId,
        'surahName': surahName,
        'verseNumber': verseNumber,
        'verseText': verseText,
      };
  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
        surahId: json['surahId'],
        surahName: json['surahName'],
        verseNumber: json['verseNumber'],
        verseText: json['verseText'],
      );
}

class PrayerTimesData {
  final Map<String, String> timings;
  final String date;
  final String cityArabic;
  const PrayerTimesData({
    required this.timings,
    required this.date,
    required this.cityArabic,
  });
}
