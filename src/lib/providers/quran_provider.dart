import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/models/quran_models.dart';
import 'package:app/services/quran_data.dart';

class QuranProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Reciter _selectedReciter = QuranDataService.reciters.first;
  Surah _selectedSurah = QuranDataService.surahs.first;
  bool _isPlaying = false;
  bool _isBuffering = false;
  bool _hasAudioStarted = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _fontSize = 22.0;
  bool _isDarkMode = false;
  List<Bookmark> _bookmarks = [];

  Reciter get selectedReciter => _selectedReciter;
  Surah get selectedSurah => _selectedSurah;
  bool get isPlaying => _isPlaying;
  bool get isBuffering => _isBuffering;
  bool get hasAudioStarted => _hasAudioStarted;
  Duration get position => _position;
  Duration get duration => _duration;
  double get fontSize => _fontSize;
  bool get isDarkMode => _isDarkMode;
  List<Bookmark> get bookmarks => _bookmarks;

  void init() {
    _loadSettings();
    _setupAudioListeners();
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
    notifyListeners();
  }

  void setSelectedSurah(Surah surah) {
    _selectedSurah = surah;
    notifyListeners();
  }

  Future<void> playCurrentSurah() async {
    _hasAudioStarted = true;
    _isBuffering = true;
    notifyListeners();
    try {
      final url = QuranDataService.getAudioUrl(_selectedReciter, _selectedSurah.id);
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      _isBuffering = false;
      notifyListeners();
    }
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
    super.dispose();
  }
}
