import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TasbihProvider with ChangeNotifier {
  int _totalCounter = 0;
  int _sessionCounter = 0;
  int _goal = 33;

  int get totalCounter => _totalCounter;
  int get sessionCounter => _sessionCounter;
  int get goal => _goal;

  TasbihProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _totalCounter = prefs.getInt('total_counter') ?? 0;
    _goal = prefs.getInt('tasbih_goal') ?? 33;
    notifyListeners();
  }

  void setGoal(int newGoal) async {
    _goal = newGoal;
    _sessionCounter = 0;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('tasbih_goal', _goal);
  }

  void increment() async {
    _totalCounter++;
    _sessionCounter++;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('total_counter', _totalCounter);
  }

  void resetSession() {
    _sessionCounter = 0;
    notifyListeners();
  }

  void resetTotal() async {
    _totalCounter = 0;
    _sessionCounter = 0;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('total_counter', 0);
  }
}