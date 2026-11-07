import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ZakatHistoryItem {
  final String id;
  final DateTime date;
  final double totalWealth;
  final double zakatAmount;
  final double cashTotal;
  final double goldWeight24k;
  final double silverWeight;

  ZakatHistoryItem({
    required this.id,
    required this.date,
    required this.totalWealth,
    required this.zakatAmount,
    required this.cashTotal,
    required this.goldWeight24k,
    required this.silverWeight,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'totalWealth': totalWealth,
        'zakatAmount': zakatAmount,
        'cashTotal': cashTotal,
        'goldWeight24k': goldWeight24k,
        'silverWeight': silverWeight,
      };

  factory ZakatHistoryItem.fromJson(Map<String, dynamic> json) => ZakatHistoryItem(
        id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
        totalWealth: (json['totalWealth'] as num?)?.toDouble() ?? 0.0,
        zakatAmount: (json['zakatAmount'] as num?)?.toDouble() ?? 0.0,
        cashTotal: (json['cashTotal'] as num?)?.toDouble() ?? 0.0,
        goldWeight24k: (json['goldWeight24k'] as num?)?.toDouble() ?? 0.0,
        silverWeight: (json['silverWeight'] as num?)?.toDouble() ?? 0.0,
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
  List<ZakatHistoryItem> get history => List.unmodifiable(_history);

  double get pureGold24kWeight => _goldWeight * (_goldKarat / 24.0);
  double get cashTotal => _cashAmount + _bankDeposits;
  double get goldValue => pureGold24kWeight * _goldPrice24k;
  double get silverValue => _silverWeight * _silverPrice;
  double get totalWealth => cashTotal + goldValue + silverValue;

  double get goldNisabThreshold => 85.0;
  double get silverNisabThreshold => 595.0;
  double get cashNisabValue => 85.0 * _goldPrice24k;

  bool get isGoldNisabMet => pureGold24kWeight >= goldNisabThreshold;
  bool get isSilverNisabMet => _silverWeight >= silverNisabThreshold;
  bool get isCashNisabMet => cashTotal >= cashNisabValue;

  bool get isTotalNisabMet {
    return totalWealth >= cashNisabValue || isGoldNisabMet || isSilverNisabMet;
  }

  double get zakatRate => 0.025;
  double get zakatDue => isTotalNisabMet ? totalWealth * zakatRate : 0.0;

  int get daysElapsedHawl {
    if (_hawlStartDate == null) return 0;
    return DateTime.now().difference(_hawlStartDate!).inDays;
  }

  int get daysRemainingHawl {
    const lunarYearDays = 354;
    final remaining = lunarYearDays - daysElapsedHawl;
    return remaining < 0 ? 0 : remaining;
  }

  double get hawlProgress {
    if (_hawlStartDate == null) return 0.0;
    final progress = daysElapsedHawl / 354.0;
    return progress > 1.0 ? 1.0 : progress;
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _goldPrice24k = prefs.getDouble('goldPrice24k') ?? 310.0;
    _silverPrice = prefs.getDouble('silverPrice') ?? 3.6;

    final hawlMs = prefs.getInt('hawlStartDate');
    if (hawlMs != null) {
      _hawlStartDate = DateTime.fromMillisecondsSinceEpoch(hawlMs);
    }

    final historyStringList = prefs.getStringList('history_list') ?? [];
    _history = historyStringList.map((str) {
      return ZakatHistoryItem.fromJson(jsonDecode(str));
    }).toList();

    notifyListeners();
  }

  Future<void> setPrices(double gold24k, double silver) async {
    _goldPrice24k = gold24k;
    _silverPrice = silver;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('goldPrice24k', gold24k);
    await prefs.setDouble('silverPrice', silver);
  }

  void setCashInputs(double cash, double deposits) {
    _cashAmount = cash;
    _bankDeposits = deposits;
    notifyListeners();
  }

  void setGoldInputs(double weight, int karat) {
    _goldWeight = weight;
    _goldKarat = karat;
    notifyListeners();
  }

  void setSilverInput(double weight) {
    _silverWeight = weight;
    notifyListeners();
  }

  Future<void> setHawlStartDate(DateTime date) async {
    _hawlStartDate = date;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('hawlStartDate', date.millisecondsSinceEpoch);
  }

  Future<void> resetHawl() async {
    _hawlStartDate = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('hawlStartDate');
  }

  Future<void> saveCurrentCalculationToHistory() async {
    if (totalWealth <= 0) return;
    final item = ZakatHistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      totalWealth: totalWealth,
      zakatAmount: zakatDue,
      cashTotal: cashTotal,
      goldWeight24k: pureGold24kWeight,
      silverWeight: _silverWeight,
    );
    _history.insert(0, item);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final encodedList = _history.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('history_list', encodedList);
  }

  Future<void> clearHistory() async {
    _history.clear();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('history_list');
  }
}
