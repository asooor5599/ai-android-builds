import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
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
  int _activeTabIndex = 0;

  PrayerTimesData? _prayerTimes;
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
    _loadSettings();
    _setupAudioListeners();
    _startClock();
    fetchReciters();
    initLocationAndPrayers();
    fetchAzkarData();
  }

  void _startClock() {
    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _currentTime = DateFormat('hh:mm:ss a', 'ar').format(DateTime.now());
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
        _prayerTimes =
            await QuranDataService.fetchPrayerTimes(pos.latitude, pos.longitude);
      } else {
        _locationError = 'تم رفض صلاحية الموقع';
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
      final url =
          QuranDataService.getAudioUrl(_selectedReciter, _selectedSurah.id);
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
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
