import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ZakatHistoryItem {
  final String id;
  final DateTime date;
  final double totalWealth;
  final double zakatAmount;

  ZakatHistoryItem({
    required this.id,
    required this.date,
    required this.totalWealth,
    required this.zakatAmount,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'totalWealth': totalWealth,
        'zakatAmount': zakatAmount,
      };

  factory ZakatHistoryItem.fromJson(Map<String, dynamic> json) => ZakatHistoryItem(
        id: json['id'] ?? '',
        date: DateTime.parse(json['date']),
        totalWealth: (json['totalWealth'] as num).toDouble(),
        zakatAmount: (json['zakatAmount'] as num).toDouble(),
      );
}

class ZakatProvider extends ChangeNotifier {
  double _goldPrice24k = 310.0;
  double _silverPrice = 3.6;
  double _cashAmount = 0.0;
  double _bankDeposits = 0.0;
  double _goldWeight = 0.0;
  int _goldKarat = 24;
  double _silverWeight = 0.0;
  DateTime? _hawlStartDate;
  List<ZakatHistoryItem> _history = [];

  double get goldPrice24k => _goldPrice24k;
  double get silverPrice => _silverPrice;
  double get cashAmount => _cashAmount;
  double get bankDeposits => _bankDeposits;
  double get goldWeight => _goldWeight;
  int get goldKarat => _goldKarat;
  double get silverWeight => _silverWeight;
  DateTime? get hawlStartDate => _hawlStartDate;
  List<ZakatHistoryItem> get history => _history;

  double get pureGold24kWeight => _goldWeight * (_goldKarat / 24.0);
  double get cashTotal => _cashAmount + _bankDeposits;
  double get goldValue => pureGold24kWeight * _goldPrice24k;
  double get silverValue => _silverWeight * _silverPrice;
  double get totalWealth => cashTotal + goldValue + silverValue;
  double get cashNisabValue => 85.0 * _goldPrice24k;

  bool get isNisabMet => (totalWealth >= cashNisabValue) || (pureGold24kWeight >= 85.0) || (_silverWeight >= 595.0);
  double get zakatDue => isNisabMet ? totalWealth * 0.025 : 0.0;

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _goldPrice24k = prefs.getDouble('goldPrice24k') ?? 310.0;
    _silverPrice = prefs.getDouble('silverPrice') ?? 3.6;
    final hawlMs = prefs.getInt('hawlStartDate');
    if (hawlMs != null) _hawlStartDate = DateTime.fromMillisecondsSinceEpoch(hawlMs);
    final historyStrings = prefs.getStringList('history') ?? [];
    _history = historyStrings.map((s) => ZakatHistoryItem.fromJson(jsonDecode(s))).toList();
    notifyListeners();
  }

  Future<void> setPrices(double gold, double silver) async {
    _goldPrice24k = gold;
    _silverPrice = silver;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('goldPrice24k', gold);
    await prefs.setDouble('silverPrice', silver);
    notifyListeners();
  }

  void setCash(double cash, double bank) {
    _cashAmount = cash;
    _bankDeposits = bank;
    notifyListeners();
  }

  void setGold(double weight, int karat) {
    _goldWeight = weight;
    _goldKarat = karat;
    notifyListeners();
  }

  void setSilver(double weight) {
    _silverWeight = weight;
    notifyListeners();
  }

  void resetAllInputs() {
    _cashAmount = 0.0;
    _bankDeposits = 0.0;
    _goldWeight = 0.0;
    _goldKarat = 24;
    _silverWeight = 0.0;
    notifyListeners();
  }

  Future<void> setHawl(DateTime date) async {
    _hawlStartDate = date;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('hawlStartDate', date.millisecondsSinceEpoch);
    notifyListeners();
  }

  Future<void> saveToHistory() async {
    if (zakatDue <= 0) return;
    final item = ZakatHistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      totalWealth: totalWealth,
      zakatAmount: zakatDue,
    );
    _history.insert(0, item);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('history', _history.map((e) => jsonEncode(e.toJson())).toList());
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _history.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('history');
    notifyListeners();
  }
}
