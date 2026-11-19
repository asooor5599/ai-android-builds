import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/models/quran_models.dart';
import 'package:app/providers/quran_provider.dart';
import 'package:app/services/quran_data.dart';
import 'package:app/screens/main_navigation_screen.dart';

class SurahListScreen extends StatefulWidget {
  const SurahListScreen({super.key});

  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuranProvider>(context);
    final surahs = QuranDataService.allSurahs.where((s) => s.name.contains(_searchQuery)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('فهرس السور')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(hintText: 'ابحث عن سورة...', prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: surahs.length,
              itemBuilder: (context, index) {
                final s = surahs[index];
                return ListTile(
                  leading: CircleAvatar(child: Text('${s.id}')),
                  title: Text('سورة ${s.name}'),
                  subtitle: Text('${s.versesCount} آية - ${s.revelationType}'),
                  onTap: () {
                    provider.setSelectedSurah(s);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => SurahReaderScreen(surah: s)));
                  },
                );
              },
            ),
          ),
        ],
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
      appBar: AppBar(title: Text('سورة ${widget.surah.name}')),
      body: FutureBuilder<List<Verse>>(
        future: _versesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData) return const Center(child: Text('تعذر التحميل'));
          final verses = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: verses.length,
            itemBuilder: (context, i) {
              final v = verses[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(v.text, textAlign: TextAlign.center, style: TextStyle(fontSize: provider.fontSize, height: 2.0, fontFamily: 'Amiri')),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
