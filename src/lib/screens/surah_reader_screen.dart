import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/models/quran_models.dart';
import 'package:app/providers/quran_provider.dart';
import 'package:app/services/quran_data.dart';

class SurahReaderScreen extends StatefulWidget {
  final Surah surah;
  const SurahReaderScreen({super.key, required this.surah});

  @override
  State<SurahReaderScreen> createState() => _SurahReaderScreenState();
}

class _SurahReaderScreenState extends State<SurahReaderScreen> {
  late Future<List<Verse>> _versesFuture;

  @override
  void initState() {
    super.initState();
    _versesFuture = QuranDataService.fetchSurahVerses(widget.surah.id);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuranProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.surah.id}. سورة ${widget.surah.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () {
              provider.setSelectedSurah(widget.surah);
              provider.playCurrentSurah();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('جاري تشغيل سورة ${widget.surah.name}'))
              );
            },
            tooltip: 'تشغيل الصوت الآن',
          ),
        ],
      ),
      body: FutureBuilder<List<Verse>>(
        future: _versesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final verses = snapshot.data ?? [];
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: verses.length,
            itemBuilder: (context, index) {
              final verse = verses[index];
              final isBookmarked = provider.isBookmarked(widget.surah.id, verse.numberInSurah);
              return Column(
                children: [
                  ListTile(
                    title: Text(
                      verse.text,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: provider.fontSize, height: 1.8),
                    ),
                    subtitle: Text('﴿${verse.numberInSurah}﴾', textAlign: TextAlign.center, style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                    trailing: IconButton(
                      icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: isBookmarked ? Colors.teal : null),
                      onPressed: () => provider.toggleBookmark(Bookmark(surahId: widget.surah.id, surahName: widget.surah.name, verseNumber: verse.numberInSurah, verseText: verse.text)),
                    ),
                  ),
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
