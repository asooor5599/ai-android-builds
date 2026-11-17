import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;
import 'package:app/calculator_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  double? _resultPrice;
  double? _resultSaved;

  void _calculate() {
    final double? price = double.tryParse(_priceController.text);
    final double? discount = double.tryParse(_discountController.text);

    if (price != null && discount != null) {
      setState(() {
        _resultSaved = price * (discount / 100);
        _resultPrice = price - _resultSaved!;
      });
      context.read<CalculatorProvider>().addRecord(price, discount);
      HapticFeedback.lightImpact();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال قيم صحيحة')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<CalculatorProvider>().history;
    final currencyFormat = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('حاسبة الخصومات', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'السعر الأصلي',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _discountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'نسبة الخصم (%)',
                      prefixIcon: Icon(Icons.percent),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _calculate,
                    icon: const Icon(Icons.calculate),
                    label: const Text('احسب الآن', style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
            if (_resultPrice != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  color: Colors.deepPurple,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _ResultItem(label: 'السعر النهائي', value: currencyFormat.format(_resultPrice)),
                        const VerticalDivider(color: Colors.white54),
                        _ResultItem(label: 'المبلغ الموفر', value: currencyFormat.format(_resultSaved)),
                      ],
                    ),
                  ),
                ),
              ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.history, color: Colors.deepPurple),
                  SizedBox(width: 8),
                  Text('آخر 10 عمليات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            if (history.isEmpty)
              const Padding(
                padding: EdgeInsets.all(40.0),
                child: Text('لا يوجد سجل حالياً', style: TextStyle(color: Colors.grey)),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final item = history[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple.withValues(alpha: 0.1),
                        child: Text('${item.discountPercentage.toInt()}%', style: const TextStyle(fontSize: 12, color: Colors.deepPurple)),
                      ),
                      title: Text('السعر: ${currencyFormat.format(item.finalPrice)}'),
                      subtitle: Text('وفرت: ${currencyFormat.format(item.savedAmount)} (من ${currencyFormat.format(item.originalPrice)})'),
                      trailing: Text(
                        intl.DateFormat('HH:mm').format(item.timestamp),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  );
                },
              ),
            if (history.isNotEmpty)
              TextButton.icon(
                onPressed: () => context.read<CalculatorProvider>().clearHistory(),
                icon: const Icon(Icons.delete_sweep, color: Colors.red),
                label: const Text('مسح السجل', style: TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ResultItem extends StatelessWidget {
  final String label;
  final String value;

  const _ResultItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
      ],
    );
  }
}