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

class DownloadedSurah {
  final int surahId;
  final String surahName;
  final String reciterId;
  final String reciterName;
  final String localPath;
  final DateTime downloadTime;

  const DownloadedSurah({
    required this.surahId,
    required this.surahName,
    required this.reciterId,
    required this.reciterName,
    required this.localPath,
    required this.downloadTime,
  });

  Map<String, dynamic> toJson() => {
        'surahId': surahId,
        'surahName': surahName,
        'reciterId': reciterId,
        'reciterName': reciterName,
        'localPath': localPath,
        'downloadTime': downloadTime.toIso8601String(),
      };

  factory DownloadedSurah.fromJson(Map<String, dynamic> json) => DownloadedSurah(
        surahId: json['surahId'],
        surahName: json['surahName'],
        reciterId: json['reciterId'],
        reciterName: json['reciterName'],
        localPath: json['localPath'],
        downloadTime: DateTime.parse(json['downloadTime']),
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

  factory PrayerTimesData.defaultTimes([String city = 'موقعي']) {
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';
    return PrayerTimesData(
      timings: const {
        'Fajr': '04:45',
        'Sunrise': '06:10',
        'Dhuhr': '12:15',
        'Asr': '15:30',
        'Maghrib': '18:10',
        'Isha': '19:40',
      },
      date: dateStr,
      cityArabic: city,
    );
  }
}

class ZekrItem {
  final String id;
  final String category;
  final String zekr;
  final String description;
  final String count;
  final String reference;

  const ZekrItem({
    required this.id,
    required this.category,
    required this.zekr,
    this.description = '',
    this.count = '1',
    this.reference = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'zekr': zekr,
        'description': description,
        'count': count,
        'reference': reference,
      };

  factory ZekrItem.fromJson(Map<String, dynamic> json, [String defaultCategory = 'أذكار']) {
    final cat = json['category'] as String? ?? defaultCategory;
    String content = (json['zekr'] as String?) ??
        (json['content'] as String?) ??
        (json['text'] as String?) ??
        '';
    
    content = content.replaceAll('\\n', '\n').replaceAll(RegExp(r'\n+'), '\n').trim();
    String desc = (json['description'] as String?) ?? (json['bless'] as String?) ?? '';
    desc = desc.replaceAll('\\n', '\n').replaceAll(RegExp(r'\n+'), '\n').trim();

    final cnt = json['count']?.toString() ?? json['repeat']?.toString() ?? '1';
    final ref = json['reference'] as String? ?? '';
    final id = json['id']?.toString() ?? '${cat.hashCode}_${content.hashCode}';
    
    return ZekrItem(
      id: id,
      category: cat,
      zekr: content,
      description: desc,
      count: cnt,
      reference: ref,
    );
  }
}
