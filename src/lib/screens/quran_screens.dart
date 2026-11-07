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
        itemCount: QuranDataService.allSurahs.length,
        itemBuilder: (context, index) {
          final s = QuranDataService.allSurahs[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              child: Text('${s.id}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            title: Text('سورة ${s.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${s.versesCount} آية - ${s.revelationType}'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SurahReaderScreen(surah: s)),
            ),
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('تعذر تحميل آيات السورة'));
          }
          final verses = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: verses.length,
            itemBuilder: (context, i) {
              final v = verses[i];
              final isBookmarked =
                  provider.isBookmarked(surah.id, v.numberInSurah);
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        v.text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: provider.fontSize,
                          height: 2.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.teal.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'آية ${v.numberInSurah}',
                              style: const TextStyle(
                                  color: Colors.teal,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                              color: Colors.teal,
                            ),
                            onPressed: () => provider.toggleBookmark(
                              Bookmark(
                                surahId: surah.id,
                                surahName: surah.name,
                                verseNumber: v.numberInSurah,
                                verseText: v.text,
                              ),
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
        },
      ),
    );
  }
}
