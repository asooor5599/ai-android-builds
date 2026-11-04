import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/tasbih_provider.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TasbihProvider>(context);

    return AlertDialog(
      title: const Text('تحديد الهدف'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('اختر عدد التسبيحات المطلوب للوصول للتنبيه:'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [33, 100, 1000].map((t) {
                final isSelected = provider.target == t;
                return ChoiceChip(
                  label: Text('$t'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      provider.setTarget(t);
                      Navigator.pop(context);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'هدف مخصص',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (val) {
                final n = int.tryParse(val);
                if (n != null && n > 0) {
                  provider.setTarget(n);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            final n = int.tryParse(_controller.text);
            if (n != null && n > 0) {
              provider.setTarget(n);
            }
            Navigator.pop(context);
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}