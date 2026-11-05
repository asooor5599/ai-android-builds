class Surah {
  final int id;
  final String name;
  final String englishName;
  final int versesCount;
  final String revelationType;
  final int page;

  const Surah({
    required this.id,
    required this.name,
    required this.englishName,
    required this.versesCount,
    required this.revelationType,
    required this.page,
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
        surahName: json['surahName'] as String,
        verseNumber: json['verseNumber'] as int,
        verseText: json['verseText'] as String,
      );
}
