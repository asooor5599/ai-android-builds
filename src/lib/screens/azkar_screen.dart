import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/quran_provider.dart';

class AzkarAndBookmarksScreen extends StatelessWidget {
  const AzkarAndBookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuranProvider>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المفضلة والأذكار'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.bookmark), text: 'الآيات المحفوظة'),
              Tab(icon: Icon(Icons.wb_sunny), text: 'أذكار اليوم'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBookmarksList(provider),
            _buildAzkarList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBookmarksList(QuranProvider provider) {
    if (provider.bookmarks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_outline, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('لا توجد آيات محفوظة بعد',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: provider.bookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = provider.bookmarks[index];
        return Card(
          child: ListTile(
            title: Text(
              'سورة ${bookmark.surahName} - آية ${bookmark.verseNumber}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            subtitle: Text(
              bookmark.verseText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => provider.toggleBookmark(bookmark),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAzkarList() {
    final azkar = [
      'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ.',
      'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ.',
      'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ: عَدَدَ خَلْقِهِ، وَرِضَا نَفْسِهِ، وَزِنَةَ عَرْشِهِ، وَمِدَادَ كَلِمَاتِهِ.',
      'لا إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ.',
      'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ (100 مرة)',
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: azkar.length,
      itemBuilder: (context, index) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.teal.withValues(alpha: 0.1),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    azkar[index],
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
