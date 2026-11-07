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
          title: const Text('الأذكار والمحفوظات'),
          bottom: const TabBar(tabs: [Tab(text: 'الأذكار'), Tab(text: 'المحفوظات')]),
        ),
        body: TabBarView(
          children: [
            provider.isLoadingAzkar ? const Center(child: CircularProgressIndicator()) : ListView.builder(itemCount: provider.azkarList.length, itemBuilder: (c, i) {
              final item = provider.azkarList[i];
              final count = provider.getZekrCount(item.id, int.tryParse(item.count) ?? 1);
              return Card(margin: const EdgeInsets.all(8), child: ListTile(title: Text(item.zekr), subtitle: Text(item.category), trailing: ElevatedButton(onPressed: count > 0 ? () => provider.decrementZekrCount(item.id, 1) : null, child: Text('$count'))));
            }),
            ListView.builder(itemCount: provider.bookmarks.length, itemBuilder: (c, i) {
              final b = provider.bookmarks[i];
              return ListTile(title: Text('سورة ${b.surahName} (${b.verseNumber})'), subtitle: Text(b.verseText), trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => provider.toggleBookmark(b)));
            }),
          ],
        ),
      ),
    );
  }
}