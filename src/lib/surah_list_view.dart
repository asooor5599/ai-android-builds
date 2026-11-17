import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/audio_provider.dart';
import 'package:app/models.dart';

class SurahListView extends StatelessWidget {
  const SurahListView({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioProvider>();

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: quranSurahs.length,
            itemBuilder: (context, index) {
              final surah = quranSurahs[index];
              final isSelected = audio.currentIndex == index;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    child: Text(surah.id.toString()),
                  ),
                  title: Text('سورة ${surah.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('سعود الشريم'),
                  trailing: isSelected && audio.isPlaying
                      ? const Icon(Icons.graphic_eq, color: Colors.green)
                      : const Icon(Icons.play_arrow),
                  onTap: () => audio.playSurah(index),
                ),
              );
            },
          ),
        ),
        if (audio.currentIndex != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'سورة ${quranSurahs[audio.currentIndex!].name}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(icon: const Icon(Icons.skip_previous), onPressed: audio.previous),
                    const SizedBox(width: 20),
                    FloatingActionButton(
                      onPressed: audio.togglePlay,
                      child: Icon(audio.isPlaying ? Icons.pause : Icons.play_arrow),
                    ),
                    const SizedBox(width: 20),
                    IconButton(icon: const Icon(Icons.skip_next), onPressed: audio.next),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}