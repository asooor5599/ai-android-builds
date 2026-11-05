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
                : ListView.builder(itemCount: provider.bookmarks.length, itemBuilder: (c, i) => Card(child: ListTile(title: Text(provider.bookmarks[i].surahName), subtitle: Text(provider.bookmarks[i].verseText), trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => provider.toggleBookmark(provider.bookmarks[i]))))),
            ListView(padding: const EdgeInsets.all(16), children: const [
              Card(child: ListTile(title: Text('أذكار الصباح'), subtitle: Text('أصبحنا وأصبح الملك لله...'))),
              Card(child: ListTile(title: Text('أذكار المساء'), subtitle: Text('أمسينا وأمسى الملك لله...'))),
              Card(child: ListTile(title: Text('دعاء ختم القرآن'), subtitle: Text('اللهم ارحمني بالقرآن...'))),
            ]),
          ],
        ),
      ),
    );
  }
}
