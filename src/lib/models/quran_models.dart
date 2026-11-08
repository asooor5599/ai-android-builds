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

  const Reciter({
    required this.id,
    required this.name,
    required this.rewaya,
    required this.serverUrl,
  });

  factory Reciter.fromJson(Map<String, dynamic> json) {
    final id = json['id'].toString();
    final name = json['name'] as String? ?? 'قارئ غير معروف';
    final moshafList = json['moshaf'] as List?;
    String serverUrl = '';
    String rewaya = 'المصحف المرتل';
    if (moshafList != null && moshafList.isNotEmpty) {
      final firstMoshaf = moshafList.first;
      serverUrl = firstMoshaf['server'] as String? ?? '';
      rewaya = firstMoshaf['name'] as String? ?? 'المصحف المرتل';
    }
    if (serverUrl.isNotEmpty && !serverUrl.endsWith('/')) {
      serverUrl = '$serverUrl/';
    }
    return Reciter(
      id: id,
      name: name,
      rewaya: rewaya,
      serverUrl: serverUrl,
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
        surahId: json['surahId'] as int,
        surahName: json['surahName'] as String? ?? '',
        verseNumber: json['verseNumber'] as int,
        verseText: json['verseText'] as String? ?? '',
      );
}

class ZekrItem {
  final String id;
  final String category;
  final String text;
  final String count;
  final String description;

  const ZekrItem({
    required this.id,
    required this.category,
    required this.text,
    this.count = '1',
    this.description = '',
  });
}
