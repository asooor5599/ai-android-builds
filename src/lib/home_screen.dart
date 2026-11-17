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
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  double? _resultFinal;
  double? _resultSaved;

  void _calculate() {
    final double? price = double.tryParse(_priceController.text);
    final double? discount = double.tryParse(_discountController.text);

    if (price != null && discount != null) {
      setState(() {
        _resultSaved = price * (discount / 100);
        _resultFinal = price - _resultSaved!;
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
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.white),
            onPressed: () => context.read<CalculatorProvider>().clearHistory(),
            tooltip: 'مسح السجل',
          )
        ],
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
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'السعر الأصلي',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _discountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'نسبة الخصم (%)',
                      prefixIcon: Icon(Icons.percent),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _calculate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('احسب الآن', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
            if (_resultFinal != null) ...[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    _ResultCard(title: 'السعر النهائي', value: currencyFormat.format(_resultFinal), color: Colors.green),
                    const SizedBox(width: 10),
                    _ResultCard(title: 'المبلغ الموفر', value: currencyFormat.format(_resultSaved), color: Colors.deepPurple),
                  ],
                ),
              ),
            ],
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('آخر 10 عمليات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                      leading: const CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        child: Icon(Icons.history, color: Colors.white, size: 20),
                      ),
                      title: Text('خصم ${item.discountPercent.toStringAsFixed(0)}% من ${currencyFormat.format(item.originalPrice)}'),
                      subtitle: Text('السعر: ${currencyFormat.format(item.finalPrice)} | وفرت: ${currencyFormat.format(item.savedAmount)}'),
                      trailing: Text(
                        intl.DateFormat('HH:mm').format(item.timestamp),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _ResultCard({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            FittedBox(child: Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color))),
          ],
        ),
      ),
    );
  }
}