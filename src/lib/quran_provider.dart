import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/models.dart';
import 'package:app/api_service.dart';

class QuranProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Surah> _surahs = [];
  List<Surah> _filteredSurahs = [];
  bool _isLoading = false;
  int? _lastReadSurah;

  List<Surah> get surahs => _filteredSurahs.isEmpty && _surahs.isNotEmpty ? _surahs : _filteredSurahs;
  bool get isLoading => _isLoading;
  int? get lastReadSurah => _lastReadSurah;

  QuranProvider() {
    fetchSurahs();
    loadLastRead();
  }

  Future<void> fetchSurahs() async {
    _isLoading = true;
    notifyListeners();
    try {
      _surahs = await _apiService.getSurahs();
      _filteredSurahs = _surahs;
    } catch (e) {
      debugPrint(e.toString());
    }
    _isLoading = false;
    notifyListeners();
  }

  void filterSurahs(String query) {
    if (query.isEmpty) {
      _filteredSurahs = _surahs;
    } else {
      _filteredSurahs = _surahs.where((s) => 
        s.name.contains(query) || 
        s.englishName.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
    notifyListeners();
  }

  Future<void> saveLastRead(int surahNumber) async {
    _lastReadSurah = surahNumber;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastRead', surahNumber);
    notifyListeners();
  }

  Future<void> loadLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    _lastReadSurah = prefs.getInt('lastRead');
    notifyListeners();
  }

  Future<List<Ayah>> getAyahs(int number) => _apiService.getSurahDetails(number);
}