import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/zakat_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _goldCtrl = TextEditingController();
  final _silverCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final p = context.read<ZakatProvider>();
    _goldCtrl.text = p.goldPrice24k.toString();
    _silverCtrl.text = p.silverPrice.toString();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ZakatProvider>();
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('إعدادات الأسعار الحالية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(
            controller: _goldCtrl, keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'سعر جرام الذهب عيار 24 (ر.س)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _silverCtrl, keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'سعر جرام الفضة (ر.س)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                p.setPrices(double.tryParse(_goldCtrl.text) ?? 310.0, double.tryParse(_silverCtrl.text) ?? 3.6);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ الأسعار')));
              },
              child: const Text('حفظ التعديلات'),
            ),
          ),
        ],
      ),
    );
  }
}
