import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;
import 'package:app/zakat_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ZakatProvider>();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('سجل العمليات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () => p.clearHistory(), child: const Text('مسح الكل', style: TextStyle(color: Colors.red))),
            ],
          ),
        ),
        Expanded(
          child: p.history.isEmpty 
            ? const Center(child: Text('لا يوجد سجلات حتى الآن'))
            : ListView.builder(
                itemCount: p.history.length,
                itemBuilder: (context, i) {
                  final item = p.history[i];
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.history)),
                    title: Text('زكاة: ${item.zakatAmount.toStringAsFixed(2)} ر.س'),
                    subtitle: Text('الثروة: ${item.totalWealth.toStringAsFixed(2)} ر.س'),
                    trailing: Text(intl.DateFormat('yyyy/MM/dd').format(item.date)),
                  );
                },
              ),
        ),
      ],
    );
  }
}
