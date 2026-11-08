import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/quran_provider.dart';
import 'package:app/models/quran_models.dart';
import 'package:app/services/quran_service.dart';

class SurahTextScreen extends StatelessWidget {
  const SurahTextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuranProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paperColor = isDark ? const Color(0xFF1B2420) : const Color(0xFFFFFDF5);

    return Scaffold(
      appBar: AppBar(
        title: Text('سورة ${provider.selectedSurah.name} بالكلمات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () => provider.updateFontSize(2.0),
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () => provider.updateFontSize(-2.0),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.teal.withValues(alpha: 0.1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<int>(
                  value: provider.selectedSurah.id,
                  underline: const SizedBox(),
                  onChanged: (id) {
                    if (id != null) {
                      final s = QuranService.allSurahs.firstWhere((element) => element.id == id);
                      provider.setSelectedSurah(s);
                    }
                  },
                  items: QuranService.allSurahs.map((s) {
                    return DropdownMenuItem<int>(
                      value: s.id,
                      child: Text('سورة ${s.name} (${s.versesCount} آية)', style: const TextStyle(fontWeight: FontWeight.bold)),
                    );
                  }).toList(),
                ),
                IconButton(
                  icon: Icon(provider.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill, color: Colors.teal, size: 30),
                  onPressed: () => provider.isPlaying ? provider.pauseAudio() : provider.playCurrentSurah(),
                ),
              ],
            ),
          ),
          Expanded(
            child: provider.isLoadingVerses
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    color: paperColor,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (provider.selectedSurah.id != 9 && provider.selectedSurah.id != 1) ...[
                          const Center(
                            child: Text(
                              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                                height: 2.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        RichText(
                          textAlign: TextAlign.justify,
                          textDirection: TextDirection.rtl,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: provider.fontSize,
                              height: 2.3,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            children: provider.verses.expand((v) {
                              final isBookmarked = provider.isBookmarked(provider.selectedSurah.id, v.numberInSurah);
                              return [
                                TextSpan(
                                  text: '${v.text} ',
                                  style: TextStyle(
                                    backgroundColor: isBookmarked ? Colors.amber.withValues(alpha: 0.25) : null,
                                  ),
                                ),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: GestureDetector(
                                    onTap: () {
                                      provider.toggleBookmark(
                                        Bookmark(
                                          surahId: provider.selectedSurah.id,
                                          surahName: provider.selectedSurah.name,
                                          verseNumber: v.numberInSurah,
                                          verseText: v.text,
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isBookmarked ? Colors.amber.shade700 : Colors.teal,
                                          width: 1.5,
                                        ),
                                        color: isBookmarked
                                            ? Colors.amber.withValues(alpha: 0.2)
                                            : Colors.teal.withValues(alpha: 0.1),
                                      ),
                                      child: Text(
                                        ' ﴿${v.numberInSurah}﴾ ',
                                        style: TextStyle(
                                          fontSize: provider.fontSize * 0.65,
                                          fontWeight: FontWeight.bold,
                                          color: isBookmarked ? Colors.amber.shade900 : Colors.teal,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ];
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
