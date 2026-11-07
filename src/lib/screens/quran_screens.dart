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
      appBar: AppBar(title: const Text('سور القرآن الكريم')),
      body: ListView.builder(
        itemCount: QuranDataService.allSurahs.length,
        itemBuilder: (context, index) {
          final surah = QuranDataService.allSurahs[index];
          return ListTile(
            leading: CircleAvatar(child: Text('${surah.id}')),
            title: Text(surah.name),
            subtitle: Text('${surah.versesCount} آية - ${surah.revelationType}'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SurahReaderScreen(surah: surah))),
          );
        },
      ),
    );
  }
}

class SurahReaderScreen extends StatefulWidget {
  final Surah surah;
  const SurahReaderScreen({super.key, required this.surah});

  @override
  State<SurahReaderScreen> createState() => _SurahReaderScreenState();
}

class _SurahReaderScreenState extends State<SurahReaderScreen> {
  List<Verse> _verses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadText();
  }

  void _loadText() async {
    final data = await QuranDataService.fetchSurahText(widget.surah.id);
    if (mounted) setState(() { _verses = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuranProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text('سورة ${widget.surah.name}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _verses.length,
              itemBuilder: (context, index) {
                final v = _verses[index];
                final isBookmarked = provider.isBookmarked(widget.surah.id, v.numberInSurah);
                return Column(
                  children: [
                    ListTile(
                      title: Text(v.text, textAlign: TextAlign.center, style: TextStyle(fontSize: provider.fontSize, height: 2)),
                      subtitle: Text('(${v.numberInSurah})', textAlign: TextAlign.center),
                      trailing: IconButton(
                        icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: Colors.teal),
                        onPressed: () => provider.toggleBookmark(Bookmark(surahId: widget.surah.id, surahName: widget.surah.name, verseNumber: v.numberInSurah, verseText: v.text)),
                      ),
                    ),
                    const Divider(),
                  ],
                );
              },
            ),
    );
  }
}