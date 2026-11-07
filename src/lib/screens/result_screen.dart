import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/zakat_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  void _shareSummary(BuildContext context, ZakatProvider provider) async {
    final summaryText = '''
🕋 ملخص حسبة الزكاة (بالريال السعودي SAR)
---------------------------------------
💰 إجمالي الأموال والنقد: ${provider.cashTotal.toStringAsFixed(2)} ر.س
🥇 الذهب (صافي عيار 24): ${provider.pureGold24kWeight.toStringAsFixed(2)} جرام (بقيمة: ${provider.goldValue.toStringAsFixed(2)} ر.س)
🥈 الفضة: ${provider.silverWeight.toStringAsFixed(2)} جرام (بقيمة: ${provider.silverValue.toStringAsFixed(2)} ر.س)
---------------------------------------
💵 إجمالي الثروة: ${provider.totalWealth.toStringAsFixed(2)} ر.س
⚖️ حالة النصاب: ${provider.isTotalNisabMet ? 