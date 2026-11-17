import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:app/models/quran_models.dart';
import 'package:app/services/quran_data.dart';

class QuranProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<Reciter> _reciters = QuranDataService.fallbackReciters;
  Reciter _selectedReciter = QuranDataService.fallbackReciters.first;
  Surah _selectedSurah = QuranDataService.allSurahs.first;
  bool _isLoadingReciters = true;
  bool _isPlaying = false;
  bool _isBuffering = false;
  bool _hasAudioStarted = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _fontSize = 22.0;
  bool _isDarkMode = false;
  List<Bookmark> _bookmarks = [];
  List<DownloadedSurah> _downloadedSurahs = [];
  final Map<String, double> _downloadProgress = {};
  final Set<String> _downloadingKeys = {};
  int _activeTabIndex = 0;

  PrayerTimesData? _prayerTimes = PrayerTimesData.defaultTimes('موقعي');
  bool _isLoadingPrayers = false;
  String _locationError = '';
  String _currentTime = '';
  Timer? _clockTimer;

  List<ZekrItem> _azkarList = [];
  bool _isLoadingAzkar = true;
  final Map<String, int> _zekrCounters = {};
  List<int> _shownRandomVerses = [];

  List<Reciter> get reciters => _reciters;
  Reciter get selectedReciter => _selectedReciter;
  Surah get selectedSurah => _selectedSurah;
  bool get isLoadingReciters => _isLoadingReciters;
  bool get isPlaying => _isPlaying;
  bool get isBuffering => _isBuffering;
  bool get hasAudioStarted => _hasAudioStarted;
  Duration get position => _position;
  Duration get duration => _duration;
  double get fontSize => _fontSize;
  bool get isDarkMode => _isDarkMode;
  List<Bookmark> get bookmarks => _bookmarks;
  List<DownloadedSurah> get downloadedSurahs => _downloadedSurahs;
  int get activeTabIndex => _activeTabIndex;
  PrayerTimesData? get prayerTimes => _prayerTimes;
  bool get isLoadingPrayers => _isLoadingPrayers;
  String get locationError => _locationError;
  String get currentTime => _currentTime;

  List<ZekrItem> get azkarList => _azkarList;
  bool get isLoadingAzkar => _isLoadingAzkar;

  List<Surah> get availableSurahsForSelectedReciter {
    final ids = _selectedReciter.effectiveSurahIds;
    return QuranDataService.allSurahs.where((s) => ids.contains(s.id)).toList();
  }

  void init() {
    _updateTime();
    _startClock();
    _loadSettings();
    _loadDownloadedSurahs();
    _setupAudioListeners();
    fetchReciters();
    initLocationAndPrayers();
    fetchAzkarData();
  }

  Future<Map<String, String>> getRandomUniqueVerse() async {
    final prefs = await SharedPreferences.getInstance();
    final String? shownJson = prefs.getString('shown_random_verses');
    if (shownJson != null) {
      try {
        _shownRandomVerses = List<int>.from(json.decode(shownJson));
      } catch (_) {}
    }

    if (_shownRandomVerses.length >= 200) {
      _shownRandomVerses.clear();
    }

    final allPool = [argsSample1(), argsSample2(), argsSample3(), argsSample4(), argsSample5(), argsSample6(), argsSample7(), argsSample8(), argsSample9(), argsSample10()];
    int index;
    do {
      index = DateTime.now().millisecondsSinceEpoch % allPool.length;
    } while (_shownRandomVerses.contains(index) && _shownRandomVerses.length < allPool.length);

    _shownRandomVerses.add(index);
    await prefs.setString('shown_random_verses', json.encode(_shownRandomVerses));

    return allPool[index];
  }

  Map<String, String> argsSample1() => {'text': '«الَّذِينَ آمَنُوا وَتَطْمَئِنُّ قُلُوبُهُم بِذِكْرِ اللَّهِ ۗ أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ»', 'ref': 'سورة الرعد: 28'};
  Map<String, String> argsSample2() => {'text': '«وَقَالَ رَبُّكُمُ ادْعُونِي أَسْتَجِبْ لَكُمْ»', 'ref': 'سورة غافر: 60'};
  Map<String, String> argsSample3() => {'text': '«فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ»', 'ref': 'سورة البقرة: 152'};
  Map<String, String> argsSample4() => {'text': '«وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا وَيَرْزُقْهُ من حَيْثُ لَا يَحْتَسِبُ»', 'ref': 'سورة الطلاق: 2-3'};
  Map<String, String> argsSample5() => {'text': '«إِنَّ اللَّهَ وَمَلَائِكَتَهُ يُصَلُّونَ عَلَى النَّبِيِّ ۚ يَا أَيُّهَا الَّذِينَ آمَنُوا صَلَّوْا عَلَيْهِ وَسَلِّمُوا تَسْلِيمًا»', 'ref': 'سورة الأحزاب: 56'};
  Map<String, String> argsSample6() => {'text': '«رَبَّنَا لَا تُزِغْ قُلُوبَبَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مَن لَدُنكَ رَحْمَةً ۚ إِنَّكَ أَنتَ الْوَهَّابُ»', 'ref': 'سورة آل عمران: 8'};
  Map<String, String> argsSample7() => {'text': '«وَاصْبِرْ لِحُكْمِ رَبِّكَ فَإِنَّكَ بِأَعْيُنِنَا»', 'ref': 'سورة الطور: 48'};
  Map<String, String> argsSample8() => {'text': '«قُلْ يَا عِبَادِي الَّذِينَ أَسْرَفُوا عَلَىٰ أَنفُسِهِمْ لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ»', 'ref': 'سورة الزمر: 53'};
  Map<String, String> argsSample9() => {'text': '«وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ»', 'ref': 'سورة الطلاق: 3'};
  Map<String, String> argsSample10() => {'text': '«رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي»', 'ref': 'سورة طه: 25-26'};

  void _updateTime() {
    final now = DateTime.now();
    final hour = now.hour == 0 ? 12 : (now.hour > 12 ? now.hour - 12 : now.hour);
    final period = now.hour >= 12 ? 'م' : 'ص';
    final h = hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');
    _currentTime = '$h:$m:$s $period';
  }

  void _startClock() {
    _updateTime();
    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
      notifyListeners();
    });
  }

  void setActiveTab(int index) {
    _activeTabIndex = index;
    notifyListeners();
  }

  Future<void> fetchAzkarData() async {
    _isLoadingAzkar = true;
    notifyListeners();
    _azkarList = await QuranDataService.fetchAzkarFromApi();
    _isLoadingAzkar = false;
    notifyListeners();
  }

  int getZekrCount(String id, int initialCount) {
    return _zekrCounters[id] ?? initialCount;
  }

  void decrementZekrCount(String id, int initialCount) {
    final current = getZekrCount(id, initialCount);
    if (current > 0) {
      _zekrCounters[id] = current - 1;
      notifyListeners();
    }
  }

  void resetZekrCount(String id, int initialCount) {
    _zekrCounters[id] = initialCount;
    notifyListeners();
  }

  Future<void> fetchReciters() async {
    _isLoadingReciters = true;
    notifyListeners();
    final list = await QuranDataService.fetchAllRecitersFromApi();
    _reciters = list;
    if (list.isNotEmpty) {
      setSelectedReciter(list.first);
    }
    _isLoadingReciters = false;
    notifyListeners();
  }

  Future<void> initLocationAndPrayers() async {
    _isLoadingPrayers = true;
    _locationError = '';
    _prayerTimes ??= PrayerTimesData.defaultTimes('موقعي');
    notifyListeners();
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        final res = await QuranDataService.fetchPrayerTimes(pos.latitude, pos.longitude);
        if (res != null) {
          _prayerTimes = res;
        }
      } else {
        _locationError = 'تم إظهار مواقيت تقريبية (صلاحية الموقع غير ممنوحة)';
      }
    } catch (e) {
      _locationError = 'تعذر التحديد التلقائي للموقع';
    }
    _isLoadingPrayers = false;
    notifyListeners();
  }

  void _setupAudioListeners() {
    _audioPlayer.onPositionChanged.listen((p) {
      _position = p;
      if (_isBuffering && p > Duration.zero) _isBuffering = false;
      notifyListeners();
    });
    _audioPlayer.onDurationChanged.listen((d) {
      _duration = d;
      notifyListeners();
    });
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      if (state == PlayerState.completed) {
        _isPlaying = false;
        _position = Duration.zero;
      }
      notifyListeners();
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _fontSize = prefs.getDouble('fontSize') ?? 22.0;
    final String? bookmarkJson = prefs.getString('bookmarks');
    if (bookmarkJson != null) {
      try {
        final List decoded = json.decode(bookmarkJson);
        _bookmarks = decoded.map((e) => Bookmark.fromJson(e)).toList();
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> _loadDownloadedSurahs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? downloadedJson = prefs.getString('downloaded_surahs');
    if (downloadedJson != null) {
      try {
        final List decoded = json.decode(downloadedJson);
        _downloadedSurahs = decoded.map((e) => DownloadedSurah.fromJson(e)).toList();
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> _saveDownloadedSurahs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'downloaded_surahs',
      json.encode(_downloadedSurahs.map((e) => e.toJson()).toList()),
    );
  }

  bool isDownloading(String reciterId, int surahId) =>
      _downloadingKeys.contains('${reciterId}_$surahId');

  double getDownloadProgress(String reciterId, int surahId) =>
      _downloadProgress['${reciterId}_$surahId'] ?? 0.0;

  bool isSurahDownloaded(String reciterId, int surahId) =>
      _downloadedSurahs.any((d) => d.reciterId == reciterId && d.surahId == surahId);

  DownloadedSurah? getDownloadedSurah(String reciterId, int surahId) {
    final idx = _downloadedSurahs.indexWhere((d) => d.reciterId == reciterId && d.surahId == surahId);
    return idx != -1 ? _downloadedSurahs[idx] : null;
  }

  Future<void> downloadSurah(Surah surah, Reciter reciter) async {
    final key = '${reciter.id}_${surah.id}';
    if (isSurahDownloaded(reciter.id, surah.id) || _downloadingKeys.contains(key)) return;

    _downloadingKeys.add(key);
    _downloadProgress[key] = 0.0;
    notifyListeners();

    try {
      final url = QuranDataService.getAudioUrl(reciter, surah.id);
      final request = http.Request('GET', Uri.parse(url));
      final response = await http.Client().send(request);

      if (response.statusCode == 200) {
        final totalBytes = response.contentLength ?? 0;
        final List<int> bytes = [];
        int receivedBytes = 0;

        await for (var chunk in response.stream) {
          bytes.addAll(chunk);
          receivedBytes += chunk.length;
          if (totalBytes > 0) {
            _downloadProgress[key] = receivedBytes / totalBytes;
            notifyListeners();
          }
        }

        final dir = await getApplicationDocumentsDirectory();
        final filePath = '${dir.path}/quran_${reciter.id}_${surah.id}.mp3';
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        final item = DownloadedSurah(
          surahId: surah.id,
          surahName: surah.name,
          reciterId: reciter.id,
          reciterName: reciter.name,
          localPath: filePath,
          downloadedAt: DateTime.now(),
        );

        _downloadedSurahs.removeWhere((d) => d.key == key);
        _downloadedSurahs.add(item);
        await _saveDownloadedSurahs();
      }
    } catch (_) {
    } finally {
      _downloadingKeys.remove(key);
      _downloadProgress.remove(key);
      notifyListeners();
    }
  }

  Future<void> deleteDownloadedSurah(DownloadedSurah item) async {
    try {
      final file = File(item.localPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
    _downloadedSurahs.removeWhere((d) => d.key == item.key);
    await _saveDownloadedSurahs();
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  void setSelectedReciter(Reciter reciter) {
    _selectedReciter = reciter;
    final available = availableSurahsForSelectedReciter;
    if (available.isNotEmpty && !available.any((s) => s.id == _selectedSurah.id)) {
      _selectedSurah = available.first;
    }
    notifyListeners();
  }

  void setSelectedSurah(Surah surah) {
    _selectedSurah = surah;
    notifyListeners();
  }

  Future<void> playCurrentSurah() async {
    _hasAudioStarted = true;
    _isBuffering = true;
    _isPlaying = false;
    notifyListeners();
    try {
      await _audioPlayer.stop();
      final downloaded = getDownloadedSurah(_selectedReciter.id, _selectedSurah.id);
      if (downloaded != null && File(downloaded.localPath).existsSync()) {
        await _audioPlayer.play(DeviceFileSource(downloaded.localPath));
      } else {
        final url = QuranDataService.getAudioUrl(_selectedReciter, _selectedSurah.id);
        await _audioPlayer.play(UrlSource(url));
      }
    } catch (e) {
      _isBuffering = false;
      notifyListeners();
    }
  }

  Future<void> playDownloadedSurahItem(DownloadedSurah item) async {
    final surah = QuranDataService.allSurahs.firstWhere(
      (s) => s.id == item.surahId,
      orElse: () => QuranDataService.allSurahs.first,
    );
    final reciter = _reciters.firstWhere(
      (r) => r.id == item.reciterId,
      orElse: () => Reciter(id: item.reciterId, name: item.reciterName, rewaya: 'المصحف المرتل', serverUrl: ''),
    );
    _selectedSurah = surah;
    _selectedReciter = reciter;
    _hasAudioStarted = true;
    _isBuffering = true;
    _isPlaying = false;
    notifyListeners();

    try {
      await _audioPlayer.stop();
      if (File(item.localPath).existsSync()) {
        await _audioPlayer.play(DeviceFileSource(item.localPath));
      } else {
        final url = QuranDataService.getAudioUrl(reciter, surah.id);
        await _audioPlayer.play(UrlSource(url));
      }
    } catch (e) {
      _isBuffering = false;
      notifyListeners();
    }
  }

  Future<void> pauseAudio() async => await _audioPlayer.pause();
  Future<void> resumeAudio() async => await _audioPlayer.resume();
  Future<void> seekAudio(Duration position) async =>
      await _audioPlayer.seek(position);

  Future<void> toggleBookmark(Bookmark bookmark) async {
    final index = _bookmarks.indexWhere((b) =>
        b.surahId == bookmark.surahId && b.verseNumber == bookmark.verseNumber);
    if (index >= 0) {
      _bookmarks.removeAt(index);
    } else {
      _bookmarks.add(bookmark);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'bookmarks', json.encode(_bookmarks.map((e) => e.toJson()).toList()));
    notifyListeners();
  }

  bool isBookmarked(int surahId, int verseNumber) =>
      _bookmarks.any((b) => b.surahId == surahId && b.verseNumber == verseNumber);

  @override
  void dispose() {
    _audioPlayer.dispose();
    _clockTimer?.cancel();
    super.dispose();
  }
}
