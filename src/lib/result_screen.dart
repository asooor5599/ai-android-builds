import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:app/zakat_provider.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ZakatProvider>();
    final primary = Color(0xFF1B5E20);
    final gold = Color(0xFFFFD700);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text('إجمالي المبلغ الخاضع للزكاة', style: TextStyle(fontSize: 16)),
                  Text('${p.totalWealth.toStringAsFixed(2)} ر.س', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primary)),
                  const Divider(height: 40),
                  const Text('قيمة الزكاة الواجبة (2.5%)', style: TextStyle(fontSize: 16)),
                  Text('${p.zakatDue.toStringAsFixed(2)} ر.س', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: p.isNisabMet ? primary : Colors.grey)),
                  const SizedBox(height: 20),
                  if (!p.isNisabMet)
                    const Text('لم يبلغ النصاب بعد', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                  else
                    const Text('بلغ النصاب الشرعي', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final text = '''
ملخص حسبة الزكاة:
إجمالي الثروة: ${p.totalWealth.toStringAsFixed(2)} ر.س
الزكاة الواجبة: ${p.zakatDue.toStringAsFixed(2)} ر.س
تم الحساب عبر تطبيق زكاتي.
''';
                Clipboard.setData(ClipboardData(text: text));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ الملخص للمشاركة')));
                p.saveToHistory();
              },
              icon: const Icon(Icons.share),
              label: const Text('مشاركة وحفظ النتيجة'),
              style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: gold, padding: const EdgeInsets.all(16)),
            ),
          ),
        ],
      ),
    );
  }
}
