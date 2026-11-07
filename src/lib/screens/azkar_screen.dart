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
          title: const Text('المحفوظات والأذكار'),
          bottom: const TabBar(indicatorColor: Colors.white, tabs: [Tab(text: 'الآيات المحفوظة'), Tab(text: 'الأذكار')]),
        ),
        body: TabBarView(
          children: [
            provider.bookmarks.isEmpty
                ? const Center(child: Text('لا توجد آيات محفوظة'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: provider.bookmarks.length,
                    itemBuilder: (c, i) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text('سورة ${provider.bookmarks[i].surahName} (آية ${provider.bookmarks[i].verseNumber})'),
                        subtitle: Text(provider.bookmarks[i].verseText, style: const TextStyle(fontSize: 16)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => provider.toggleBookmark(provider.bookmarks[i]),
                        ),
                      ),
                    ),
                  ),
            ListView(padding: const EdgeInsets.all(16), children: const [
              Card(child: ListTile(title: Text('أذكار الصباح', style: TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('أصبحنا وأصبح الملك لله، والحمد لله، لا إله إلا الله وحده لا شريك له...'))),
              Card(child: ListTile(title: Text('أذكار المساء', style: TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('أمسينا وأمسى الملك لله، والحمد لله، لا إله إلا الله وحده لا شريك له...'))),
              Card(child: ListTile(title: Text('دعاء ختم القرآن', style: TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('اللهم ارحمني بالقرآن واجعله لي إماماً ونوراً وهدى ورحمة...'))),
            ]),
          ],
        ),
      ),
    );
  }
}
