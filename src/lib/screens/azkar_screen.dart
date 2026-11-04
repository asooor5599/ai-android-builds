import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/models/app_models.dart';

class AzkarScreen extends StatefulWidget {
  const AzkarScreen({super.key});

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<DhikrItem> _morningAzkar = [
    DhikrItem(
      text: 'أَصْبَحْنَا وَأَصْبَحَ المُلْكُ لِلَّهِ، وَالحَمْدُ لِلَّهِ لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ.',
      count: '1',
      reference: 'رواة مسلم',
    ),
    DhikrItem(
      text: 'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ.',
      count: '1',
      reference: 'الترمذي',
    ),
    DhikrItem(
      text: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ: عَدَدَ خَلْقِهِ، وَرِضَا نَفْسِهِ، وَزِنَةَ عَرْشِهِ، وَمِدَادَ كَلِمَاتِهِ.',
      count: '3',
      reference: 'مسلم',
    ),
    DhikrItem(
      text: 'آيَةُ الكُرْسِيِّ: (اللَّهُ لاَ إِلَٰهَ إِلاَّ هُوَ الحَيُّ القَيُّومُ...)',
      count: '1',
      reference: 'البقرة: 255',
    ),
    DhikrItem(
      text: 'اللَّهُمَّ أَنْتَ رَبِّي لاَ إِلَهَ إِلاَّ أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ.',
      count: '1',
      reference: 'سيد الاستغفار - البخاري',
    ),
  ];

  final List<DhikrItem> _eveningAzkar = [
    DhikrItem(
      text: 'أَمْسَيْنَا وَأَمْسَى المُلْكُ لِلَّهِ، وَالحَمْدُ لِلَّهِ لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ.',
      count: '1',
      reference: 'مسلم',
    ),
    DhikrItem(
      text: 'اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ وَإِلَيْكَ المَصِيرُ.',
      count: '1',
      reference: 'الترمذي',
    ),
    DhikrItem(
      text: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ.',
      count: '3',
      reference: 'أحمد والترمذي',
    ),
    DhikrItem(
      text: 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ.',
      count: '100',
      reference: 'البخاري ومسلم',
    ),
  ];

  final List<DhikrItem> _postPrayerAzkar = [
    DhikrItem(
      text: 'أَسْتَغْفِرُ اللَّهَ (ثَلاَثاً)... اللَّهُمَّ أَنْتَ السَّلاَمُ وَمِنْكَ السَّلاَمُ، تَبَارَكْتَ يَا ذَا الجَلاَلِ وَالإِكْرَامِ.',
      count: '1',
      reference: 'مسلم',
    ),
    DhikrItem(
      text: 'سُبْحَانَ اللَّهِ',
      count: '33',
      reference: 'التسبيح بعد الصلاة',
    ),
    DhikrItem(
      text: 'الْحَمْدُ لِلَّهِ',
      count: '33',
      reference: 'التحميد بعد الصلاة',
    ),
    DhikrItem(
      text: 'اللَّهُ أَكْبَرُ',
      count: '33',
      reference: 'التكبير بعد الصلاة',
    ),
    DhikrItem(
      text: 'لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ، لَهُ المُلْكُ وَلَهُ الحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ.',
      count: '1',
      reference: 'تمام المائة',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأذكار والتسابيح'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFD4AF37),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'أذكار الصباح'),
            Tab(text: 'أذكار المساء'),
            Tab(text: 'بعد الصلاة'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAzkarList(_morningAzkar),
          _buildAzkarList(_eveningAzkar),
          _buildAzkarList(_postPrayerAzkar),
        ],
      ),
    );
  }

  Widget _buildAzkarList(List<DhikrItem> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isCompleted = item.isFinished;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: isCompleted
              ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
              : null,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  item.text,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.6,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.reference,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          if (item.currentCount < item.maxCount) {
                            item.currentCount++;
                          } else {
                            item.currentCount = 0;
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCompleted
                            ? Colors.green
                            : Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: Icon(isCompleted ? Icons.check : Icons.touch_app),
                      label: Text(
                        '${item.currentCount} / ${item.count}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}