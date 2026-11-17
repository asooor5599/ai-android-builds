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
  final _formKey = GlobalKey<FormState>();

  double _resultFinalPrice = 0;
  double _resultSavedAmount = 0;
  bool _showResult = false;

  void _calculate() {
    if (_formKey.currentState!.validate()) {
      final price = double.parse(_priceController.text);
      final discount = double.parse(_discountController.text);
      
      setState(() {
        _resultSavedAmount = price * (discount / 100);
        _resultFinalPrice = price - _resultSavedAmount;
        _showResult = true;
      });

      context.read<CalculatorProvider>().addRecord(price, discount);
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<CalculatorProvider>().history;
    final currencyFormat = intl.NumberFormat.currency(symbol: 'ر.س', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('حاسبة الخصومات', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              key: _formKey,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'السعر الأصلي',
                          prefixIcon: Icon(Icons.sell),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                        validator: (value) => (value == null || value.isEmpty) ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _discountController,
                        decoration: const InputDecoration(
                          labelText: 'نسبة الخصم (%)',
                          prefixIcon: Icon(Icons.percent),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'مطلوب';
                          final val = double.tryParse(value);
                          if (val == null || val > 100) return 'نسبة غير صحيحة';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _calculate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('احسب الآن', style: TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_showResult)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Card(
                  color: Colors.deepPurple[50],
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildResultRow('السعر بعد الخصم:', currencyFormat.format(_resultFinalPrice), Colors.deepPurple, true),
                        const Divider(),
                        _buildResultRow('المبلغ الموفر:', currencyFormat.format(_resultSavedAmount), Colors.green[700]!, false),
                      ],
                    ),
                  ),
                ),
              ),
            const Padding(
              padding: EdgeInsets.only(top: 24, bottom: 8, right: 8),
              child: Text('آخر 10 عمليات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            if (history.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('لا يوجد سجل حالياً')))
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
                        backgroundColor: Colors.deepPurple[100],
                        child: Text('${item.discountPercent.toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      title: Text('السعر: ${currencyFormat.format(item.finalPrice)}'),
                      subtitle: Text('وفرت: ${currencyFormat.format(item.savedAmount)}'),
                      trailing: Text(
                        intl.DateFormat('HH:mm').format(item.timestamp),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
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

  Widget _buildResultRow(String label, String value, Color color, bool isBold) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color)),
      ],
    );
  }
}