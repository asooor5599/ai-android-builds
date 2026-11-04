import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/tasbih_provider.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TasbihProvider>(context);

    return AlertDialog(
      title: const Text('إعدادات الهدف'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('اختر عدد التسبيحات المطلوب للوصول للتنبيه:'),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            children: [33, 100, 1000].map((t) {
              final isSelected = provider.target == t;
              return ChoiceChip(
                label: Text('$t'),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) provider.setTarget(t);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 15),
          TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'هدف مخصص',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onSubmitted: (value) {
              final n = int.tryParse(value);
              if (n != null && n > 0) {
                provider.setTarget(n);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }
}