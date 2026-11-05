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
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _playbackSpeed = 1.0;
  double _fontSize = 22.0;
  bool _isDarkMode = false;

  List<Bookmark> _bookmarks = [];
  String _audioError = '';

  Reciter get selectedReciter => _selectedReciter;
  Surah get selectedSurah => _selectedSurah;
  bool get isPlaying => _isPlaying;
  bool get isBuffering => _isBuffering;
  Duration get position => _position;
  Duration get duration => _duration;
  double get playbackSpeed => _playbackSpeed;
  double get fontSize => _fontSize;
  bool get isDarkMode => _isDarkMode;
  List<Bookmark> get bookmarks => _bookmarks;
  String get audioError => _audioError;

  void init() {
    _loadSettings();
    _setupAudioListeners();
  }

  void _setupAudioListeners() {
    _audioPlayer.onPositionChanged.listen((p) {
      _position = p;
      notifyListeners();
    });
    _audioPlayer.onDurationChanged.listen((d) {
      _duration = d;
      notifyListeners();
    });
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      _isBuffering = state == PlayerState.buffering;
      notifyListeners();
    });
    _audioPlayer.onPlayerComplete.listen((_) {
      _isPlaying = false;
      _position = Duration.zero;
      playNextSurah();
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

  Future<void> setFontSize(double size) async {
    _fontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', size);
    notifyListeners();
  }

  void setSelectedReciter(Reciter reciter) {
    _selectedReciter = reciter;
    notifyListeners();
    if (_isPlaying) {
      playCurrentSurah();
    }
  }

  void setSelectedSurah(Surah surah) {
    _selectedSurah = surah;
    notifyListeners();
  }

  Future<void> playCurrentSurah() async {
    _audioError = '';
    _isBuffering = true;
    notifyListeners();
    try {
      final url = QuranDataService.getAudioUrl(_selectedReciter, _selectedSurah.id);
      await _audioPlayer.stop();
      await _audioPlayer.setPlaybackRate(_playbackSpeed);
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      _audioError = 'تعذر تشغيل الصوت، تأكد من الاتصال بالإنترنت';
      _isPlaying = false;
      _isBuffering = false;
      notifyListeners();
    }
  }

  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
  }

  Future<void> resumeAudio() async {
    if (_position > Duration.zero) {
      await _audioPlayer.resume();
    } else {
      playCurrentSurah();
    }
  }

  Future<void> seekAudio(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> setSpeed(double speed) async {
    _playbackSpeed = speed;
    await _audioPlayer.setPlaybackRate(speed);
    notifyListeners();
  }

  void playNextSurah() {
    final currentIndex = QuranDataService.surahs.indexWhere((s) => s.id == _selectedSurah.id);
    if (currentIndex != -1 && currentIndex < QuranDataService.surahs.length - 1) {
      _selectedSurah = QuranDataService.surahs[currentIndex + 1];
      playCurrentSurah();
    }
  }

  void playPreviousSurah() {
    final currentIndex = QuranDataService.surahs.indexWhere((s) => s.id == _selectedSurah.id);
    if (currentIndex > 0) {
      _selectedSurah = QuranDataService.surahs[currentIndex - 1];
      playCurrentSurah();
    }
  }

  Future<void> toggleBookmark(Bookmark bookmark) async {
    final index = _bookmarks.indexWhere(
        (b) => b.surahId == bookmark.surahId && b.verseNumber == bookmark.verseNumber);
    if (index >= 0) {
      _bookmarks.removeAt(index);
    } else {
      _bookmarks.add(bookmark);
    }
    final prefs = await SharedPreferences.getInstance();
    final String jsonStr = json.encode(_bookmarks.map((e) => e.toJson()).toList());
    await prefs.setString('bookmarks', jsonStr);
    notifyListeners();
  }

  bool isBookmarked(int surahId, int verseNumber) {
    return _bookmarks.any((b) => b.surahId == surahId && b.verseNumber == verseNumber);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
