import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;
import 'package:app/zakat_provider.dart';

class HawlScreen extends StatelessWidget {
  const HawlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ZakatProvider>();
    final dateStr = p.hawlStartDate != null ? intl.DateFormat('yyyy/MM/dd').format(p.hawlStartDate!) : 'لم يحدد';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_month, size: 80, color: Color(0xFF1B5E20)),
          const SizedBox(height: 24),
          const Text('بداية الحول الهجري', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(dateStr, style: const TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () async {
              final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
              if (date != null) p.setHawl(date);
            },
            child: const Text('تحديد تاريخ بداية الحول'),
          ),
          const SizedBox(height: 16),
          const Text('ملاحظة: الحول القمري هو 354 يوماً من تاريخ امتلاك النصاب.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
