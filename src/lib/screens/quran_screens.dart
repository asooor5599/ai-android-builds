import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/models/quran_models.dart';
import 'package:app/providers/quran_provider.dart';
import 'package:app/services/quran_data.dart';

class SurahListScreen extends StatelessWidget {
  const SurahListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('فهرس السور')),
      body: ListView.builder(
        itemCount: QuranDataService.surahs.length,
        itemBuilder: (context, index) {
          final s = QuranDataService.surahs[index];
          return ListTile(
            leading: CircleAvatar(child: Text('${s.id}')),
            title: Text(s.name),
            subtitle: Text('${s.versesCount} آية - ${s.revelationType}'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SurahReaderScreen(surah: s))),
          );
        },
      ),
    );
  }
}

class SurahReaderScreen extends StatelessWidget {
  final Surah surah;
  const SurahReaderScreen({super.key, required this.surah});
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuranProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text('سورة ${surah.name}')),
      body: FutureBuilder<List<Verse>>(
        future: QuranDataService.fetchSurahVerses(surah.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final verses = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: verses.length,
            itemBuilder: (context, i) {
              final v = verses[i];
              final isBookmarked = provider.isBookmarked(surah.id, v.numberInSurah);
              return Column(
                children: [
                  Text(v.text, textAlign: TextAlign.center, style: TextStyle(fontSize: provider.fontSize, height: 1.8)),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('﴿${v.numberInSurah}﴾', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                    IconButton(icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border), onPressed: () => provider.toggleBookmark(Bookmark(surahId: surah.id, surahName: surah.name, verseNumber: v.numberInSurah, verseText: v.text))),
                  ]),
                  const Divider(),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
