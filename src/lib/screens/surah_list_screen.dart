import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/quran_provider.dart';
import 'package:app/services/quran_data.dart';
import 'package:app/screens/surah_reader_screen.dart';

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
    final filteredSurahs = QuranDataService.surahs.where((s) {
      return s.name.contains(_searchQuery) ||
          s.englishName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.id.toString() == _searchQuery;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('فهرس السور'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ابحث باسم السورة أو رقمها...',
                prefixIcon: const Icon(Icons.search, color: Colors.teal),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredSurahs.length,
              itemBuilder: (context, index) {
                final surah = filteredSurahs[index];
                return Card(
                  child: ListTile(
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${surah.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                    title: Text(
                      surah.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    subtitle: Text('${surah.revelationType} • ${surah.versesCount} آية'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.play_circle_outline, color: Colors.teal),
                          tooltip: 'استماع',
                          onPressed: () {
                            provider.setSelectedSurah(surah);
                            provider.playCurrentSurah();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.menu_book, color: Colors.teal),
                          tooltip: 'قراءة',
                          onPressed: () {
                            provider.setSelectedSurah(surah);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SurahReaderScreen(surah: surah),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
