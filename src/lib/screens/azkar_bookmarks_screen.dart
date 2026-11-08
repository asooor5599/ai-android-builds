import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/quran_provider.dart';
import 'package:app/services/quran_service.dart';

class AzkarBookmarksScreen extends StatelessWidget {
  const AzkarBookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuranProvider>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الأذكار والآيات المحفوظة'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'الأذكار والأدعية'),
              Tab(text: 'الآيات المحفوظة'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAzkarTab(context, provider),
            _buildBookmarksTab(context, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildAzkarTab(BuildContext context, QuranProvider provider) {
    final items = QuranService.azkarLibrary;
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (ctx, i) {
        final item = items[i];
        final initCount = int.tryParse(item.count) ?? 1;
        final currCount = provider.getZekrCount(item.id, initCount);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Chip(
                  label: Text(item.category, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.teal.withValues(alpha: 0.1),
                ),
                const SizedBox(height: 8),
                Text(
                  item.text,
                  style: const TextStyle(fontSize: 17, height: 1.7, fontWeight: FontWeight.w600),
                ),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(item.description, style: TextStyle(fontSize: 13, color: Colors.teal.shade700)),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: currCount > 0
                          ? () => provider.decrementZekrCount(item.id, initCount)
                          : null,
                      icon: const Icon(Icons.touch_app, size: 18),
                      label: Text(currCount == 0 ? 'تم الإكمال' : 'التكرار: $currCount'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currCount > 0 ? Colors.teal : Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.grey),
                      onPressed: () => provider.resetZekrCount(item.id, initCount),
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

  Widget _buildBookmarksTab(BuildContext context, QuranProvider provider) {
    if (provider.bookmarks.isEmpty) {
      return const Center(child: Text('لا توجد آيات محفوظة حالياً'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: provider.bookmarks.length,
      itemBuilder: (ctx, i) {
        final b = provider.bookmarks[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text('سورة ${b.surahName} - آية ${b.verseNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(b.verseText, style: const TextStyle(fontSize: 15, height: 1.6)),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => provider.toggleBookmark(b),
            ),
          ),
        );
      },
    );
  }
}
