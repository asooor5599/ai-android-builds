import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/models.dart';
import 'package:app/quran_service.dart';

class QuranProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  List<Reciter> _reciters = [];
  Reciter? _selectedReciter;
  Surah? _selectedSurah;
  
  bool _isLoading = true;
  bool _isPlaying = false;
  bool _isDarkMode = false;
  
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  
  List<String> _bookmarks = [];

  List<Reciter> get reciters => _reciters;
  Reciter? get selectedReciter => _selectedReciter;
  Surah? get selectedSurah => _selectedSurah;
  bool get isLoading => _isLoading;
  bool get isPlaying => _isPlaying;
  bool get isDarkMode => _isDarkMode;
  Duration get position => _position;
  Duration get duration => _duration;
  List<String> get bookmarks => _bookmarks;

  void init() async {
    _reciters = await QuranService.fetchReciters();
    if (_reciters.isNotEmpty) _selectedReciter = _reciters.first;
    _selectedSurah = QuranService.allSurahs.first;
    
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('darkMode') ?? false;
    _bookmarks = prefs.getStringList('bookmarks') ?? [];

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
      notifyListeners();
    });

    _isLoading = false;
    notifyListeners();
  }

  void setReciter(Reciter reciter) {
    _selectedReciter = reciter;
    notifyListeners();
  }

  void setSurah(Surah surah) {
    _selectedSurah = surah;
    notifyListeners();
  }

  void toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', _isDarkMode);
    notifyListeners();
  }

  Future<void> playAudio() async {
    if (_selectedReciter == null || _selectedSurah == null) return;
    final surahStr = _selectedSurah!.id.toString().padLeft(3, '0');
    final url = '${_selectedReciter!.serverUrl}$surahStr.mp3';
    await _audioPlayer.stop();
    await _audioPlayer.play(UrlSource(url));
  }

  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
  }

  Future<void> resumeAudio() async {
    await _audioPlayer.resume();
  }

  Future<void> seek(Duration pos) async {
    await _audioPlayer.seek(pos);
  }

  void toggleBookmark(String verseKey) async {
    if (_bookmarks.contains(verseKey)) {
      _bookmarks.remove(verseKey);
    } else {
      _bookmarks.add(verseKey);
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('bookmarks', _bookmarks);
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}