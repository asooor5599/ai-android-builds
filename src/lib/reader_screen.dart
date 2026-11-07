import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/models.dart';
import 'package:app/quran_service.dart';
import 'package:app/quran_provider.dart';

class ReaderScreen extends StatefulWidget {
  final Surah surah;
  const ReaderScreen({super.key, required this.surah});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late Future<List<Verse>> _versesFuture;

  @override
  void initState() {
    super.initState();
    _versesFuture = QuranService.fetchSurahVerses(widget.surah.id);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuranProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('سورة ${widget.surah.name}'),
      ),
      body: FutureBuilder<List<Verse>>(
        future: _versesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('حدث خطأ أثناء تحميل الآيات'));
          }

          final verses = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: verses.length,
            itemBuilder: (context, index) {
              final v = verses[index];
              final key = '${widget.surah.id}_${v.number}';
              final isBookmarked = provider.bookmarks.contains(key);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    v.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      height: 1.8,
                      fontFamily: 'serif',
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.teal,
                          child: Text(
                            '${v.number}',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: Colors.amber,
                          ),
                          onPressed: () => provider.toggleBookmark(key),
                        ),
                      ],
                    ),
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