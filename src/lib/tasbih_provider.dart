import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TasbihProvider extends ChangeNotifier {
  int _count = 0;
  int _totalCount = 0;
  int _target = 33;
  String _currentDhikr = 'سبحان الله';
  bool _isDarkMode = false;
  bool _vibrationEnabled = true;

  int get count => _count;
  int get totalCount => _totalCount;
  int get target => _target;
  String get currentDhikr => _currentDhikr;
  bool get isDarkMode => _isDarkMode;
  bool get vibrationEnabled => _vibrationEnabled;

  final List<String> dhikrList = [
    'سبحان الله',
    'الحمد لله',
    'لا إله إلا الله',
    'الله أكبر',
    'أستغفر الله',
    'اللهم صلِّ على محمد'
  ];

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _count = prefs.getInt('count') ?? 0;
    _totalCount = prefs.getInt('totalCount') ?? 0;
    _target = prefs.getInt('target') ?? 33;
    _currentDhikr = prefs.getString('currentDhikr') ?? 'سبحان الله';
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;
    notifyListeners();
  }

  Future<void> increment() async {
    _count++;
    _totalCount++;
    if (_vibrationEnabled) {
      HapticFeedback.mediumImpact();
    }
    
    if (_count == _target) {
      HapticFeedback.heavyImpact();
    }
    
    await _saveData();
    notifyListeners();
  }

  Future<void> reset() async {
    _count = 0;
    await _saveData();
    notifyListeners();
  }

  Future<void> setTarget(int newTarget) async {
    _target = newTarget;
    await _saveData();
    notifyListeners();
  }

  Future<void> setDhikr(String dhikr) async {
    _currentDhikr = dhikr;
    _count = 0;
    await _saveData();
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _saveData();
    notifyListeners();
  }

  Future<void> toggleVibration() async {
    _vibrationEnabled = !_vibrationEnabled;
    await _saveData();
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('count', _count);
    await prefs.setInt('totalCount', _totalCount);
    await prefs.setInt('target', _target);
    await prefs.setString('currentDhikr', _currentDhikr);
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setBool('vibrationEnabled', _vibrationEnabled);
  }
}