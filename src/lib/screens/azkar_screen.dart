import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/models/quran_models.dart';
import 'package:app/providers/quran_provider.dart';

class AzkarAndBookmarksScreen extends StatefulWidget {
  const AzkarAndBookmarksScreen({super.key});

  @override
  State<AzkarAndBookmarksScreen> createState() => _AzkarAndBookmarksScreenState();
}

class _AzkarAndBookmarksScreenState extends State<AzkarAndBookmarksScreen> {
  String _selectedCategory = 'الكل';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuranProvider>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الأذكار والمحفوظات'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'مكتبة الأذكار والأدعية'),
              Tab(text: 'السور المحملة'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAzkarTab(provider),
            _buildDownloadedAndBookmarksTab(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildAzkarTab(QuranProvider provider) {
    if (provider.isLoadingAzkar) {
      return const Center(child: CircularProgressIndicator());
    }

    final categories = [
      'الكل',
      ...provider.azkarList
          .map((e) => e.category)
          .where((cat) => cat.toLowerCase().trim() != 'stop' && cat.trim().isNotEmpty)
          .toSet()
          .toList()
    ];

    final filtered = provider.azkarList.where((z) {
      final matchesCat = _selectedCategory == 'الكل' || z.category == _selectedCategory;
      final matchesQuery = z.zekr.contains(_searchQuery) || z.description.contains(_searchQuery);
      return matchesCat && matchesQuery;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'ابحث في الأذكار والأدعية...',
              prefixIcon: const Icon(Icons.search, color: Colors.teal),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: categories.length,
            itemBuilder: (context, idx) {
              final cat = categories[idx];
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: Colors.teal,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : null),
                  onSelected: (val) {
                    if (val) setState(() => _selectedCategory = cat);
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('لا توجد أذكار تطابق البحث'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  itemBuilder: (context, idx) {
                    final item = filtered[idx];
                    final initialCount = int.tryParse(item.count) ?? 1;
                    final currentCount = provider.getZekrCount(item.id, initialCount);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Chip(
                                  label: Text(item.category, style: const TextStyle(fontSize: 11)),
                                  backgroundColor: Colors.teal.withValues(alpha: 0.1),
                                ),
                                if (item.reference.isNotEmpty)
                                  Text(item.reference, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.zekr,
                              style: const TextStyle(fontSize: 17, height: 1.8, fontWeight: FontWeight.w600),
                            ),
                            if (item.description.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                item.description,
                                style: TextStyle(fontSize: 13, color: Colors.teal.shade700),
                              ),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: currentCount > 0
                                      ? () => provider.decrementZekrCount(item.id, initialCount)
                                      : null,
                                  icon: const Icon(Icons.touch_app, size: 18),
                                  label: Text(currentCount == 0 ? 'تم الإكمال' : 'التكرار: $currentCount'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: currentCount > 0 ? Colors.teal : Colors.grey,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.refresh, color: Colors.grey),
                                  tooltip: 'إعادة العداد',
                                  onPressed: () => provider.resetZekrCount(item.id, initialCount),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDownloadedAndBookmarksTab(QuranProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle('السور المحملة (الاستماع بدون إنترنت ⚡)'),
        if (provider.downloadedSurahs.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.downloading_outlined, size: 40, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'لا توجد سور محملة حالياً.\nيمكنك تحميل أي سورة للاستماع إليها بدون إنترنت في أي وقت.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, height: 1.5),
                  ),
                ],
              ),
            ),
          )
        else
          ...provider.downloadedSurahs.map((item) {
            final isCurrentlyPlaying = provider.isPlaying &&
                provider.selectedSurah.id == item.surahId &&
                provider.selectedReciter.id == item.reciterId;
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.teal,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.offline_pin, color: Colors.white, size: 20),
                ),
                title: Text(
                  'سورة ${item.surahName}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text('القارئ: ${item.reciterName} • الحجم: ${item.fileSizeMB} ميجابايت'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        isCurrentlyPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                        color: Colors.teal,
                        size: 32,
                      ),
                      onPressed: () {
                        if (isCurrentlyPlaying) {
                          provider.pauseAudio();
                        } else {
                          provider.playDownloadedSurahItem(item);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'حذف السورة المحملة',
                      onPressed: () => _confirmDeleteSurah(context, provider, item),
                    ),
                  ],
                ),
              );
            }),
        const SizedBox(height: 24),
        _buildSectionTitle('الآيات المحفوظة في المفضلة'),
        if (provider.bookmarks.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'لا توجد آيات محفوظة في المفضلة',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          )
        else
          ...provider.bookmarks.map((bm) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(
                    'سورة ${bm.surahName} (آية ${bm.verseNumber})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      bm.verseText,
                      style: const TextStyle(fontSize: 15, height: 1.6),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => provider.toggleBookmark(bm),
                  ),
                ),
              )),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
      ),
    );
  }

  void _confirmDeleteSurah(BuildContext context, QuranProvider provider, DownloadedSurah item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف السورة المحملة'),
        content: Text('هل أنت أؤكد من حذف ملف سورة ${item.surahName} للمقرئ ${item.reciterName}؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              provider.deleteDownloadedSurah(item);
              Navigator.pop(ctx);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
