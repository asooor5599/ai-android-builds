import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DhikrProvider extends ChangeNotifier {
  final List<String> _dhikrList = [
    'سبحان الله',
    'الحمد لله',
    'الله أكبر',
    'لا إله إلا الله',
    'أستغفر الله',
    'لا حول ولا قوة إلا بالله',
    'اللهم صلِّ وسلم على نبينا محمد'
  ];

  int _currentIndex = 0;
  final Map<String, int> _counts = {};
  int _targetCount = 33;

  int get currentIndex => _currentIndex;
  String get currentDhikr => _dhikrList[_currentIndex];
  List<String> get dhikrList => _dhikrList;
  int get currentCount => _counts[currentDhikr] ?? 0;
  int get targetCount => _targetCount;

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _currentIndex = prefs.getInt('currentIndex') ?? 0;
    if (_currentIndex >= _dhikrList.length) _currentIndex = 0;
    _targetCount = prefs.getInt('targetCount') ?? 33;

    for (var dhikr in _dhikrList) {
      _counts[dhikr] = prefs.getInt('count_$dhikr') ?? 0;
    }
    notifyListeners();
  }

  void selectDhikr(int index) async {
    _currentIndex = index;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentIndex', index);
  }

  void increment() async {
    final key = currentDhikr;
    final current = _counts[key] ?? 0;
    _counts[key] = current + 1;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('count_$key', _counts[key]!);
  }

  void resetCurrent() async {
    final key = currentDhikr;
    _counts[key] = 0;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('count_$key', 0);
  }

  void resetAll() async {
    for (var dhikr in _dhikrList) {
      _counts[dhikr] = 0;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    for (var dhikr in _dhikrList) {
      await prefs.setInt('count_$dhikr', 0);
    }
  }

  void setTargetCount(int target) async {
    _targetCount = target;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('targetCount', target);
  }
}