class Reciter {
  final String id;
  final String name;
  final String serverUrl;
  final List<int> surahList;

  Reciter({
    required this.id,
    required this.name,
    required this.serverUrl,
    required this.surahList,
  });

  factory Reciter.fromJson(Map<String, dynamic> json) {
    final moshaf = json['moshaf'] != null && (json['moshaf'] as List).isNotEmpty
        ? json['moshaf'][0]
        : null;
    final surahCsv = moshaf != null ? moshaf['surah_list'] as String : '';
    return Reciter(
      id: json['id'].toString(),
      name: json['name'] ?? 'قارئ مجهول',
      serverUrl: moshaf != null ? moshaf['server'] : '',
      surahList: surahCsv.split(',').map((e) => int.tryParse(e) ?? 0).where((e) => e > 0).toList(),
    );
  }
}

class Surah {
  final int id;
  final String name;
  final String englishName;
  final int versesCount;

  const Surah({
    required this.id,
    required this.name,
    required this.englishName,
    required this.versesCount,
  });
}

class Verse {
  final int number;
  final String text;
  const Verse({required this.number, required this.text});
}