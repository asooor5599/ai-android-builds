import 'package:flutter/material.dart';
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
    final filteredSurahs = QuranDataService.surahs.where((s) => s.name.contains(_searchQuery)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('فهرس السور')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'ابحث باسم السورة...',
                prefixIcon: const Icon(Icons.search, color: Colors.teal),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredSurahs.length,
              itemBuilder: (context, index) {
                final surah = filteredSurahs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal.withValues(alpha: 0.1),
                      child: Text('${surah.id}', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(surah.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${surah.versesCount} آية - ${surah.revelationType}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SurahReaderScreen(surah: surah))),
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
