import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalculationRecord {
  final double originalPrice;
  final double discountPercentage;
  final double finalPrice;
  final double savedAmount;
  final DateTime timestamp;

  CalculationRecord({
    required this.originalPrice,
    required this.discountPercentage,
    required this.finalPrice,
    required this.savedAmount,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'originalPrice': originalPrice,
    'discountPercentage': discountPercentage,
    'finalPrice': finalPrice,
    'savedAmount': savedAmount,
    'timestamp': timestamp.toIso8601String(),
  };

  factory CalculationRecord.fromJson(Map<String, dynamic> json) => CalculationRecord(
    originalPrice: json['originalPrice'],
    discountPercentage: json['discountPercentage'],
    finalPrice: json['finalPrice'],
    savedAmount: json['savedAmount'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

class CalculatorProvider extends ChangeNotifier {
  List<CalculationRecord> _history = [];
  List<CalculationRecord> get history => _history;

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString('calc_history');
    if (historyJson != null) {
      final List<dynamic> decoded = jsonDecode(historyJson);
      _history = decoded.map((item) => CalculationRecord.fromJson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> addRecord(double price, double discount) async {
    final saved = price * (discount / 100);
    final finalPrice = price - saved;
    
    final record = CalculationRecord(
      originalPrice: price,
      discountPercentage: discount,
      finalPrice: finalPrice,
      savedAmount: saved,
      timestamp: DateTime.now(),
    );

    _history.insert(0, record);
    if (_history.length > 10) {
      _history = _history.sublist(0, 10);
    }

    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_history.map((e) => e.toJson()).toList());
    await prefs.setString('calc_history', encoded);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _history.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('calc_history');
    notifyListeners();
  }
}