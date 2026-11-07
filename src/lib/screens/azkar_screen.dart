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
              Tab(text: 'الآيات المحفوظة'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAzkarTab(provider),
            _buildBookmarksTab(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildAzkarTab(QuranProvider provider) {
    if (provider.isLoadingAzkar) {
      return const Center(child: CircularProgressIndicator());
    }

    final categories = ['الكل', ...provider.azkarList.map((e) => e.category).toSet().toList()];
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

  Widget _buildBookmarksTab(QuranProvider provider) {
    return provider.bookmarks.isEmpty
        ? const Center(child: Text('لا توجد آيات محفوظة في المفضلة'))
        : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: provider.bookmarks.length,
            itemBuilder: (context, i) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(
                  'سورة ${provider.bookmarks[i].surahName} (آية ${provider.bookmarks[i].verseNumber})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    provider.bookmarks[i].verseText,
                    style: const TextStyle(fontSize: 16, height: 1.6),
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => provider.toggleBookmark(provider.bookmarks[i]),
                ),
              ),
            ),
          );
  }
}
