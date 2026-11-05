import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        title: Text('سورة ${widget.surah.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_increase),
            onPressed: () => provider.setFontSize(provider.fontSize + 2),
          ),
          IconButton(
            icon: const Icon(Icons.text_decrease),
            onPressed: () =>
                provider.setFontSize((provider.fontSize - 2).clamp(14.0, 40.0)),
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
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.teal.withValues(alpha: 0.1),
                child: const Text(
                  'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif',
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: verses.length,
                  separatorBuilder: (_, __) => const Divider(height: 24),
                  itemBuilder: (context, index) {
                    final verse = verses[index];
                    final isBookmarked = provider.isBookmarked(
                        widget.surah.id, verse.numberInSurah);

                    return InkWell(
                      onLongPress: () {
                        Clipboard.setData(ClipboardData(text: verse.text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم نسخ الآية بنجاح')),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  '${verse.text} ﴿${verse.numberInSurah}﴾',
                                  style: TextStyle(
                                    fontSize: provider.fontSize,
                                    height: 1.8,
                                    fontFamily: 'serif',
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                  color: isBookmarked ? Colors.teal : Colors.grey,
                                ),
                                onPressed: () {
                                  provider.toggleBookmark(
                                    Bookmark(
                                      surahId: widget.surah.id,
                                      surahName: widget.surah.name,
                                      verseNumber: verse.numberInSurah,
                                      verseText: verse.text,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          provider.setSelectedSurah(widget.surah);
          provider.playCurrentSurah();
        },
        icon: const Icon(Icons.play_arrow),
        label: const Text('تشغيل التلاوة'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
    );
  }
}
