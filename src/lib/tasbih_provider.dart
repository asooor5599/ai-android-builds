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
    'لا حول ولا قوة إلا بالله',
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

  void increment() {
    _count++;
    _totalCount++;
    
    if (_vibrationEnabled) {
      if (_target > 0 && _count % _target == 0) {
        HapticFeedback.vibrate();
      } else {
        HapticFeedback.lightImpact();
      }
    }
    
    _saveData();
    notifyListeners();
  }

  void reset() {
    _count = 0;
    _saveData();
    notifyListeners();
  }

  void setTarget(int newTarget) {
    _target = newTarget;
    _saveData();
    notifyListeners();
  }

  void setDhikr(String dhikr) {
    _currentDhikr = dhikr;
    _count = 0;
    _saveData();
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveData();
    notifyListeners();
  }

  void toggleVibration() {
    _vibrationEnabled = !_vibrationEnabled;
    _saveData();
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