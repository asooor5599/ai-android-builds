import 'package:flutter/material.dart';
import 'package:app/services/quran_data.dart';
import 'package:app/screens/surah_reader_screen.dart';

class SurahListScreen extends StatelessWidget {
  const SurahListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('فهرس السور')),
      body: ListView.builder(
        itemCount: QuranDataService.surahs.length,
        itemBuilder: (context, index) {
          final surah = QuranDataService.surahs[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: Colors.teal.withValues(alpha: 0.1), child: Text('${surah.id}', style: const TextStyle(color: Colors.teal))),
              title: Text(surah.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${surah.versesCount} آية - ${surah.revelationType}'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SurahReaderScreen(surah: surah))),
            ),
          );
        },
      ),
    );
  }
}
