import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
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
  final Map<String, bool> _downloadingMap = {};
  int _activeTabIndex = 0;
  PrayerTimesData? _prayerTimes = PrayerTimesData.defaultTimes('موقعي');
  bool _isLoadingPrayers = false;
  String _locationError = '';
  String _currentTime = '';
  Timer? _clockTimer;
  List<ZekrItem> _azkarList = [];
  bool _isLoadingAzkar = true;
  final Map<String, int> _zekrCounters = {};

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
    _setupAudioListeners();
    fetchReciters();
    initLocationAndPrayers();
    fetchAzkarData();
  }

  void _updateTime() {
    final now = DateTime.now();
    final hour = now.hour == 0 ? 12 : (now.hour > 12 ? now.hour - 12 : now.hour);
    final period = now.hour >= 12 ? 'م' : 'ص';
    _currentTime = '${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')} $period';
  }

  void _startClock() {
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

  int getZekrCount(String id, int initialCount) => _zekrCounters[id] ?? initialCount;
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
    if (list.isNotEmpty) setSelectedReciter(list.first);
    _isLoadingReciters = false;
    notifyListeners();
  }

  Future<void> initLocationAndPrayers() async {
    _isLoadingPrayers = true;
    _locationError = '';
    notifyListeners();
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        final res = await QuranDataService.fetchPrayerTimes(pos.latitude, pos.longitude);
        if (res != null) _prayerTimes = res;
      } else {
        _locationError = 'الموقع غير متاح';
      }
    } catch (e) {
      _locationError = 'خطأ في تحديد الموقع';
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
    final String? downloadsJson = prefs.getString('downloadedSurahs');
    if (downloadsJson != null) {
      try {
        final List decoded = json.decode(downloadsJson);
        _downloadedSurahs = decoded.map((e) => DownloadedSurah.fromJson(e)).toList();
      } catch (_) {}
    }
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

  bool isSurahDownloaded(String reciterId, int surahId) => _downloadedSurahs.any((d) => d.reciterId == reciterId && d.surahId == surahId);
  bool isSurahDownloading(String reciterId, int surahId) => _downloadingMap['${reciterId}_$surahId'] == true;

  Future<bool> downloadSurah(Reciter reciter, Surah surah) async {
    final key = '${reciter.id}_${surah.id}';
    if (_downloadingMap[key] == true) return false;
    _downloadingMap[key] = true;
    notifyListeners();
    try {
      final url = QuranDataService.getAudioUrl(reciter, surah.id);
      final response = await http.get(Uri.parse(url)).timeout(const Duration(minutes: 5));
      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final filePath = '${dir.path}/surah_${reciter.id}_${surah.id}.mp3';
        await File(filePath).writeAsBytes(response.bodyBytes);
        final item = DownloadedSurah(surahId: surah.id, surahName: surah.name, reciterId: reciter.id, reciterName: reciter.name, localPath: filePath, downloadTime: DateTime.now());
        _downloadedSurahs.removeWhere((d) => d.surahId == surah.id && d.reciterId == reciter.id);
        _downloadedSurahs.add(item);
        await _saveDownloadedSurahs();
        return true;
      }
    } catch (_) {}
    finally {
      _downloadingMap.remove(key);
      notifyListeners();
    }
    return false;
  }

  Future<void> deleteDownloadedSurah(DownloadedSurah downloaded) async {
    try {
      final file = File(downloaded.localPath);
      if (await file.exists()) await file.delete();
    } catch (_) {}
    _downloadedSurahs.removeWhere((d) => d.surahId == downloaded.surahId && d.reciterId == downloaded.reciterId);
    await _saveDownloadedSurahs();
    notifyListeners();
  }

  Future<void> _saveDownloadedSurahs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('downloadedSurahs', json.encode(_downloadedSurahs.map((e) => e.toJson()).toList()));
  }

  Future<void> playCurrentSurah() async {
    _hasAudioStarted = true;
    _isBuffering = true;
    _isPlaying = false;
    notifyListeners();
    try {
      await _audioPlayer.stop();
      final downloaded = _downloadedSurahs.cast<DownloadedSurah?>().firstWhere((d) => d?.reciterId == _selectedReciter.id && d?.surahId == _selectedSurah.id, orElse: () => null);
      if (downloaded != null && File(downloaded.localPath).existsSync()) {
        await _audioPlayer.play(DeviceFileSource(downloaded.localPath));
      } else {
        final url = QuranDataService.getAudioUrl(_selectedReciter, _selectedSurah.id);
        await _audioPlayer.play(UrlSource(url));
      }
    } catch (_) {
      _isBuffering = false;
      notifyListeners();
    }
  }

  Future<void> playDownloadedSurah(DownloadedSurah item) async {
    _selectedSurah = QuranDataService.allSurahs.firstWhere((s) => s.id == item.surahId, orElse: () => QuranDataService.allSurahs.first);
    _selectedReciter = _reciters.firstWhere((r) => r.id == item.reciterId, orElse: () => Reciter(id: item.reciterId, name: item.reciterName, rewaya: 'المصحف المرتل', serverUrl: ''));
    await playCurrentSurah();
  }

  Future<void> pauseAudio() async => await _audioPlayer.pause();
  Future<void> resumeAudio() async => await _audioPlayer.resume();
  Future<void> seekAudio(Duration position) async => await _audioPlayer.seek(position);

  Future<void> toggleBookmark(Bookmark bookmark) async {
    final index = _bookmarks.indexWhere((b) => b.surahId == bookmark.surahId && b.verseNumber == bookmark.verseNumber);
    if (index >= 0) _bookmarks.removeAt(index); else _bookmarks.add(bookmark);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bookmarks', json.encode(_bookmarks.map((e) => e.toJson()).toList()));
    notifyListeners();
  }

  bool isBookmarked(int surahId, int verseNumber) => _bookmarks.any((b) => b.surahId == surahId && b.verseNumber == verseNumber);

  @override
  void dispose() {
    _audioPlayer.dispose();
    _clockTimer?.cancel();
    super.dispose();
  }
}