import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/quran_provider.dart';
import 'package:app/quran_service.dart';
import 'package:app/reader_screen.dart';
import 'package:app/models.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuranProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('القرآن الكريم'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(provider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: provider.toggleDarkMode,
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionTitle('اختر القارئ'),
                  _buildReciterDropdown(provider),
                  const SizedBox(height: 20),
                  _buildSectionTitle('اختر السورة'),
                  _buildSurahDropdown(provider),
                  const SizedBox(height: 30),
                  _buildPlayerCard(provider),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (provider.selectedSurah != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReaderScreen(surah: provider.selectedSurah!),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.menu_book),
                    label: const Text('قراءة السورة بالكلمات'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildReciterDropdown(QuranProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Reciter>(
            isExpanded: true,
            value: provider.selectedReciter,
            items: provider.reciters.map((r) {
              return DropdownMenuItem(value: r, child: Text(r.name));
            }).toList(),
            onChanged: (r) => r != null ? provider.setReciter(r) : null,
          ),
        ),
      ),
    );
  }

  Widget _buildSurahDropdown(QuranProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Surah>(
            isExpanded: true,
            value: provider.selectedSurah,
            items: QuranService.allSurahs.map((s) {
              return DropdownMenuItem(value: s, child: Text('${s.id}. ${s.name}'));
            }).toList(),
            onChanged: (s) => s != null ? provider.setSurah(s) : null,
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerCard(QuranProvider provider) {
    return Card(
      color: Colors.teal.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              provider.selectedSurah?.name ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(provider.selectedReciter?.name ?? ''),
            const SizedBox(height: 10),
            Slider(
              value: provider.position.inSeconds.toDouble(),
              max: provider.duration.inSeconds.toDouble() > 0
                  ? provider.duration.inSeconds.toDouble()
                  : 1.0,
              onChanged: (v) => provider.seek(Duration(seconds: v.toInt())),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 48,
                  icon: Icon(provider.isPlaying ? Icons.pause_circle : Icons.play_circle),
                  color: Colors.teal,
                  onPressed: () {
                    if (provider.isPlaying) {
                      provider.pauseAudio();
                    } else {
                      provider.playAudio();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}