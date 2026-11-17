class Surah {
  final int id;
  final String name;
  final String url;

  Surah({required this.id, required this.name, required this.url});
}

final List<Surah> quranSurahs = [
  Surah(id: 105, name: 'الفيل', url: 'https://server7.mp3quran.net/shur/105.mp3'),
  Surah(id: 106, name: 'قريش', url: 'https://server7.mp3quran.net/shur/106.mp3'),
  Surah(id: 107, name: 'الماعون', url: 'https://server7.mp3quran.net/shur/107.mp3'),
  Surah(id: 108, name: 'الكوثر', url: 'https://server7.mp3quran.net/shur/108.mp3'),
  Surah(id: 109, name: 'الكافرون', url: 'https://server7.mp3quran.net/shur/109.mp3'),
  Surah(id: 110, name: 'النصر', url: 'https://server7.mp3quran.net/shur/110.mp3'),
  Surah(id: 111, name: 'المسد', url: 'https://server7.mp3quran.net/shur/111.mp3'),
  Surah(id: 112, name: 'الإخلاص', url: 'https://server7.mp3quran.net/shur/112.mp3'),
  Surah(id: 113, name: 'الفلق', url: 'https://server7.mp3quran.net/shur/113.mp3'),
  Surah(id: 114, name: 'الناس', url: 'https://server7.mp3quran.net/shur/114.mp3'),
];