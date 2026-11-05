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
          bottom: const TabBar(tabs: [Tab(text: 'الآيات'), Tab(text: 'الأذكار')]),
        ),
        body: TabBarView(
          children: [
            provider.bookmarks.isEmpty
                ? const Center(child: Text('لا توجد آيات محفوظة'))
                : ListView.builder(
                    itemCount: provider.bookmarks.length,
                    itemBuilder: (context, index) {
                      final b = provider.bookmarks[index];
                      return ListTile(title: Text('سورة ${b.surahName} - آية ${b.verseNumber}'), subtitle: Text(b.verseText, maxLines: 1, overflow: TextOverflow.ellipsis), trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => provider.toggleBookmark(b)));
                    }),
            ListView(padding: const EdgeInsets.all(16), children: const [
              Card(child: ListTile(title: Text('أذكار الصباح'), subtitle: Text('أصبحنا وأصبح الملك لله والحمد لله...'))),
              Card(child: ListTile(title: Text('أذكار المساء'), subtitle: Text('أمسينا وأمسى الملك لله والحمد لله...'))),
              Card(child: ListTile(title: Text('سيد الاستغفار'), subtitle: Text('اللهم أنت ربي لا إله إلا أنت خلقتني وأنا عبدك...'))),
            ]),
          ],
        ),
      ),
    );
  }
}
