import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/zakat_provider.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _cashCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();
  final _goldCtrl = TextEditingController();
  final _silverCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final p = context.read<ZakatProvider>();
    _cashCtrl.text = p.cashAmount > 0 ? p.cashAmount.toString() : '';
    _bankCtrl.text = p.bankDeposits > 0 ? p.bankDeposits.toString() : '';
    _goldCtrl.text = p.goldWeight > 0 ? p.goldWeight.toString() : '';
    _silverCtrl.text = p.silverWeight > 0 ? p.silverWeight.toString() : '';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cashCtrl.dispose();
    _bankCtrl.dispose();
    _goldCtrl.dispose();
    _silverCtrl.dispose();
    super.dispose();
  }

  void _showClearConfirmationDialog() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('تأكيد مسح البيانات'),
          ],
        ),
        content: const Text('هل أنت تأكد من رغبتك في مسح كافة الحقول والمدخلات؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              context.read<ZakatProvider>().resetAllInputs();
              setState(() {
                _cashCtrl.clear();
                _bankCtrl.clear();
                _goldCtrl.clear();
                _silverCtrl.clear();
              });
              Navigator.of(dialogCtx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم مسح جميع الحقول بنجاح'),
                  backgroundColor: Color(0xFF1B5E20),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('مسح الكل'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ZakatProvider>();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TabBar(
                  controller: _tabController,
                  tabs: const [Tab(text: 'نقد'), Tab(text: 'ذهب'), Tab(text: 'فضة')],
                  labelColor: const Color(0xFF1B5E20),
                  indicatorColor: const Color(0xFFFFD700),
                ),
              ),
              TextButton.icon(
                onPressed: _showClearConfirmationDialog,
                icon: const Icon(Icons.cleaning_services, size: 18, color: Colors.red),
                label: const Text('مسح الكل', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTab([
                _input(_cashCtrl, 'المبالغ النقدية', Icons.money, (v) => p.setCash(double.tryParse(v) ?? 0, p.bankDeposits)),
                _input(_bankCtrl, 'الودائع البنكية', Icons.account_balance, (v) => p.setCash(p.cashAmount, double.tryParse(v) ?? 0)),
                _infoCard('نصاب النقد: ${p.cashNisabValue.toStringAsFixed(2)} ر.س')
              ]),
              _buildTab([
                const Text('اختر العيار:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [24, 22, 21, 18].map((k) => ChoiceChip(
                    label: Text('عيار $k'),
                    selected: p.goldKarat == k,
                    onSelected: (s) => s ? p.setGold(p.goldWeight, k) : null,
                  )).toList(),
                ),
                const SizedBox(height: 16),
                _input(_goldCtrl, 'الوزن بالجرام', Icons.scale, (v) => p.setGold(double.tryParse(v) ?? 0, p.goldKarat)),
                _infoCard('الوزن الصافي (24): ${p.pureGold24kWeight.toStringAsFixed(2)} جرام')
              ]),
              _buildTab([
                _input(_silverCtrl, 'وزن الفضة بالجرام', Icons.blur_on, (v) => p.setSilver(double.tryParse(v) ?? 0)),
                _infoCard('نصاب الفضة: 595 جرام')
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTab(List<Widget> children) => SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children));

  Widget _input(TextEditingController c, String label, IconData icon, Function(String) onCh) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextField(
      controller: c, keyboardType: TextInputType.number, onChanged: onCh,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
    ),
  );

  Widget _infoCard(String text) => Card(
    color: const Color(0xFFFFD700).withValues(alpha: 0.15),
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [const Icon(Icons.info, color: Color(0xFF1B5E20)), const SizedBox(width: 12), Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)))]))
  );
}
