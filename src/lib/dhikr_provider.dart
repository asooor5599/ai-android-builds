import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DhikrProvider extends ChangeNotifier {
  int _count = 0;
  String _currentDhikr = 'سبحان الله';
  final List<String> _dhikrList = [
    'سبحان الله',
    'الحمد لله',
    'لا إله إلا الله',
    'الله أكبر',
    'أستغفر الله',
    'اللهم صلِ على محمد'
  ];

  int get count => _count;
  String get currentDhikr => _currentDhikr;
  List<String> get dhikrList => _dhikrList;

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _count = prefs.getInt('count') ?? 0;
    _currentDhikr = prefs.getString('dhikr') ?? 'سبحان الله';
    notifyListeners();
  }

  void increment() async {
    _count++;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('count', _count);
  }

  void reset() async {
    _count = 0;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('count', 0);
  }

  void setDhikr(String dhikr) async {
    _currentDhikr = dhikr;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dhikr', dhikr);
  }
}