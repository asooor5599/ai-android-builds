import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/zakat_provider.dart';
import 'package:app/screens/result_screen.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _cashController = TextEditingController();
  final TextEditingController _bankController = TextEditingController();
  final TextEditingController _goldWeightController = TextEditingController();
  final TextEditingController _silverWeightController = TextEditingController();

  int _selectedKarat = 24;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ZakatProvider>(context, listen: false);
      if (provider.cashAmount > 0) {
        _cashController.text = provider.cashAmount.toString();
      }
      if (provider.bankDeposits > 0) {
        _bankController.text = provider.bankDeposits.toString();
      }
      if (provider.goldWeight > 0) {
        _goldWeightController.text = provider.goldWeight.toString();
      }
      if (provider.silverWeight > 0) {
        _silverWeightController.text = provider.silverWeight.toString();
      }
      setState(() {
        _selectedKarat = provider.goldKarat;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cashController.dispose();
    _bankController.dispose();
    _goldWeightController.dispose();
    _silverWeightController.dispose();
    super.dispose();
  }

  void _onCashChanged(ZakatProvider provider) {
    final cash = double.tryParse(_cashController.text) ?? 0.0;
    final bank = double.tryParse(_bankController.text) ?? 0.0;
    provider.setCashInputs(cash, bank);
  }

  void _onGoldChanged(ZakatProvider provider) {
    final weight = double.tryParse(_goldWeightController.text) ?? 0.0;
    provider.setGoldInputs(weight, _selectedKarat);
  }

  void _onSilverChanged(ZakatProvider provider) {
    final weight = double.tryParse(_silverWeightController.text) ?? 0.0;
    provider.setSilverInput(weight);
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1B5E20);
    const goldColor = Color(0xFFFFD700);
    final provider = Provider.of<ZakatProvider>(context);

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: primaryColor.withValues(alpha: 0.06),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    const Icon(Icons.monetization_on, color: primaryColor, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'جرام 24: ${provider.goldPrice24k.toStringAsFixed(1)} ر.س',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ],
                ),
                Container(height: 16, width: 1, color: Colors.grey.shade400),
                Row(
                  children: [
                    const Icon(Icons.scale, color: primaryColor, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'جرام الفضة: ${provider.silverPrice.toStringAsFixed(2)} ر.س',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: primaryColor,
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: goldColor,
              indicatorWeight: 4,
              tabs: const [
                Tab(icon: Icon(Icons.account_balance_wallet), text: 'نقد وودائع'),
                Tab(icon: Icon(Icons.military_tech), text: 'الذهب'),
                Tab(icon: Icon(Icons.circle_outlined), text: 'الفضة'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'الأموال والسيولة النقدية',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'قم بإدخال المبالغ النقدية المتوفرة والودائع البنكية بالريال السعودي.',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _cashController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => _onCashChanged(provider),
                        decoration: InputDecoration(
                          labelText: 'المبالغ النقدية السيّالة (ر.س)',
                          hintText: 'مثال: 15000',
                          prefixIcon: const Icon(Icons.money, color: primaryColor),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _bankController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => _onCashChanged(provider),
                        decoration: InputDecoration(
                          labelText: 'الودائع والأرصدة البنكية (ر.س)',
                          hintText: 'مثال: 50000',
                          prefixIcon: const Icon(Icons.account_balance, color: primaryColor),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Card(
                        color: goldColor.withValues(alpha: 0.15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: goldColor, width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.info_outline, color: primaryColor),
                                  SizedBox(width: 8),
                                  Text(
                                    'معلومات نصاب النقد',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'نصاب النقد يعادل قيمة 85 جرام من الذهب الصافي (عيار 24).
النصاب الحالي: ${provider.cashNisabValue.toStringAsFixed(2)} ر.س',
                                style: const TextStyle(fontSize: 13, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'حساب زكاة الذهب',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'اختر العيار وأدخل الوزن بالجرام ليتم تحويله تلقائياً لعيار 24 الصافي.',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'اختر العيار:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [24, 22, 21, 18].map((karat) {
                          final isSelected = _selectedKarat == karat;
                          return ChoiceChip(
                            label: Text('عيار $karat'),
                            selected: isSelected,
                            selectedColor: primaryColor,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                            backgroundColor: Colors.white,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedKarat = karat;
                                });
                                _onGoldChanged(provider);
                              }
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _goldWeightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => _onGoldChanged(provider),
                        decoration: InputDecoration(
                          labelText: 'وزن الذهب الإجمالي (جرام)',
                          hintText: 'مثال: 100',
                          prefixIcon: const Icon(Icons.scale, color: primaryColor),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('الوزن الخالص (عيار 24 الصافي):'),
                                  Text(
                                    '${provider.pureGold24kWeight.toStringAsFixed(2)} جرام',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('القيمة التقديرية للذهب:'),
                                  Text(
                                    '${provider.goldValue.toStringAsFixed(2)} ر.س',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    provider.isGoldNisabMet ? Icons.check_circle : Icons.warning_amber_rounded,
                                    color: provider.isGoldNisabMet ? primaryColor : Colors.amber.shade800,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      provider.isGoldNisabMet
                                          ? 'بلغ نصاب الذهب المستقل (85 جرام عيار 24 الصافي).'Platform.isAndroid ? '' : '',
                                          : 'نصاب الذهب المستقل هو 85 جرام من عيار 24 الصافي.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: provider.isGoldNisabMet ? primaryColor : Colors.amber.shade900,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'حساب زكاة الفضة',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'أدخل وزن الفضة بالجرام لحساب النصاب والزكاة المستحقة.',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _silverWeightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => _onSilverChanged(provider),
                        decoration: InputDecoration(
                          labelText: 'وزن الفضة الإجمالي (جرام)',
                          hintText: 'مثال: 600',
                          prefixIcon: const Icon(Icons.scale_outlined, color: primaryColor),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('القيمة التقديرية للفضة:'),
                                  Text(
                                    '${provider.silverValue.toStringAsFixed(2)} ر.س',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                children: [
                                  Icon(
                                    provider.isSilverNisabMet ? Icons.check_circle : Icons.warning_amber_rounded,
                                    color: provider.isSilverNisabMet ? primaryColor : Colors.amber.shade800,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      provider.isSilverNisabMet
                                          ? 'بلغ نصاب الفضة المستقل (595 جرام).' 
                                          : 'نصاب الفضة المستقل هو 595 جرام.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: provider.isSilverNisabMet ? primaryColor : Colors.amber.shade900,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'إجمالي الثروة الخاضعة للتقييم:',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          '${provider.totalWealth.toStringAsFixed(2)} ر.س',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: goldColor,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ResultScreen()),
                      );
                    },
                    icon: const Icon(Icons.calculate, color: goldColor),
                    label: const Text(
                      'عرض النتيجة',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
