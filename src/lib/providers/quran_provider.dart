import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/models/quran_models.dart';
import 'package:app/services/quran_service.dart';

class QuranProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<Reciter> _reciters = QuranService.fallbackReciters;
  Reciter _selectedReciter = QuranService.fallbackReciters.first;
  Surah _selectedSurah = QuranService.allSurahs.first;

  bool _isLoadingReciters = true;
  bool _isPlaying = false;
  bool _isBuffering = false;
  bool _hasAudioStarted = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  List<Verse> _verses = [];
  bool _isLoadingVerses = false;

  bool _isDarkMode = false;
  double _fontSize = 22.0;
  List<Bookmark> _bookmarks = [];
  int _activeTabIndex = 0;
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
  List<Verse> get verses => _verses;
  bool get isLoadingVerses => _isLoadingVerses;
  bool get isDarkMode => _isDarkMode;
  double get fontSize => _fontSize;
  List<Bookmark> get bookmarks => _bookmarks;
  int get activeTabIndex => _activeTabIndex;

  void init() {
    _loadSettings();
    _setupAudioListeners();
    fetchReciters();
    loadVersesForCurrentSurah();
  }

  void setActiveTab(int index) {
    _activeTabIndex = index;
    notifyListeners();
  }

  void _setupAudioListeners() {
    _audioPlayer.onPositionChanged.listen((p) {
      _position = p;
      if (_isBuffering && p > Duration.zero) {
        _isBuffering = false;
      }
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

  Future<void> fetchReciters() async {
    _isLoadingReciters = true;
    notifyListeners();
    final list = await QuranService.fetchReciters();
    _reciters = list;
    if (list.isNotEmpty) {
      _selectedReciter = list.first;
    }
    _isLoadingReciters = false;
    notifyListeners();
  }

  Future<void> loadVersesForCurrentSurah() async {
    _isLoadingVerses = true;
    notifyListeners();
    _verses = await QuranService.fetchSurahVerses(_selectedSurah.id);
    _isLoadingVerses = false;
    notifyListeners();
  }

  void setSelectedReciter(Reciter reciter) {
    _selectedReciter = reciter;
    notifyListeners();
    if (_hasAudioStarted) {
      playCurrentSurah();
    }
  }

  void setSelectedSurah(Surah surah) {
    _selectedSurah = surah;
    loadVersesForCurrentSurah();
    notifyListeners();
    if (_hasAudioStarted) {
      playCurrentSurah();
    }
  }

  Future<void> playCurrentSurah() async {
    _hasAudioStarted = true;
    _isBuffering = true;
    _isPlaying = false;
    notifyListeners();

    try {
      await _audioPlayer.stop();
      final url = QuranService.getAudioUrl(_selectedReciter, _selectedSurah.id);
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      _isBuffering = false;
      notifyListeners();
    }
  }

  Future<void> pauseAudio() async => await _audioPlayer.pause();
  Future<void> resumeAudio() async => await _audioPlayer.resume();
  Future<void> seekAudio(Duration pos) async => await _audioPlayer.seek(pos);

  void playNextSurah() {
    if (_selectedSurah.id < 114) {
      final next = QuranService.allSurahs.firstWhere((s) => s.id == _selectedSurah.id + 1);
      setSelectedSurah(next);
    }
  }

  void playPreviousSurah() {
    if (_selectedSurah.id > 1) {
      final prev = QuranService.allSurahs.firstWhere((s) => s.id == _selectedSurah.id - 1);
      setSelectedSurah(prev);
    }
  }

  void updateFontSize(double delta) {
    _fontSize = (_fontSize + delta).clamp(16.0, 36.0);
    notifyListeners();
    _saveSettings();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    _saveSettings();
  }

  Future<void> toggleBookmark(Bookmark bookmark) async {
    final idx = _bookmarks.indexWhere((b) =>
        b.surahId == bookmark.surahId && b.verseNumber == bookmark.verseNumber);
    if (idx >= 0) {
      _bookmarks.removeAt(idx);
    } else {
      _bookmarks.add(bookmark);
    }
    notifyListeners();
    _saveSettings();
  }

  bool isBookmarked(int surahId, int verseNumber) {
    return _bookmarks.any((b) => b.surahId == surahId && b.verseNumber == verseNumber);
  }

  int getZekrCount(String id, int initialCount) {
    return _zekrCounters[id] ?? initialCount;
  }

  void decrementZekrCount(String id, int initialCount) {
    final curr = getZekrCount(id, initialCount);
    if (curr > 0) {
      _zekrCounters[id] = curr - 1;
      notifyListeners();
    }
  }

  void resetZekrCount(String id, int initialCount) {
    _zekrCounters[id] = initialCount;
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _fontSize = prefs.getDouble('fontSize') ?? 22.0;
    final bookmarkJson = prefs.getString('bookmarks');
    if (bookmarkJson != null) {
      try {
        final List decoded = json.decode(bookmarkJson);
        _bookmarks = decoded.map((e) => Bookmark.fromJson(e)).toList();
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setDouble('fontSize', _fontSize);
    await prefs.setString(
      'bookmarks',
      json.encode(_bookmarks.map((e) => e.toJson()).toList()),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
