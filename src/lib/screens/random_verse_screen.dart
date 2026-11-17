import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/quran_provider.dart';
import 'package:app/screens/main_navigation_screen.dart';
import 'package:app/screens/quran_screens.dart';
import 'package:app/services/quran_data.dart';
import 'package:app/models/quran_models.dart';

class RandomVerseScreen extends StatelessWidget {
  const RandomVerseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuranProvider>(context);
    final verse = provider.randomVerse;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLogoIcon(size: 24),
            SizedBox(width: 8),
            Text('آية قرآنية عشوائية'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'آية جديدة',
            onPressed: provider.isLoadingRandomVerse
                ? null
                : () => provider.fetchRandomVerse(),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: provider.isLoadingRandomVerse
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('جاري اختيار آية مباركة...'),
                  ],
                )
              : verse == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 60, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text('تعذر تحميل الآية العشوائية'),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => provider.fetchRandomVerse(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('إعادة المحاولة'),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                colors: Theme.of(context).brightness == Brightness.dark
                                    ? [Colors.teal.shade900, Colors.teal.shade800]
                                    : [const Color(0xFFE0F2F1), const Color(0xFFB2DFDB)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Chip(
                                      backgroundColor: Colors.teal,
                                      label: Text(
                                        'سورة ${verse.surahName}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.shade700,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        'الآية رقم ${verse.verseNumber}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  '«${verse.verseText}»',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: provider.fontSize + 2,
                                    height: 2.1,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : const Color(0xFF004D40),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        provider.isBookmarked(verse.surahId, verse.verseNumber)
                                            ? Icons.bookmark
                                            : Icons.bookmark_border,
                                        color: Colors.teal,
                                        size: 28,
                                      ),
                                      tooltip: 'حفظ الآية',
                                      onPressed: () {
                                        provider.toggleBookmark(
                                          Bookmark(
                                            surahId: verse.surahId,
                                            surahName: verse.surahName,
                                            verseNumber: verse.verseNumber,
                                            verseText: verse.verseText,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => provider.fetchRandomVerse(),
                                icon: const Icon(Icons.shuffle, size: 22),
                                label: const Text('آية أخرى', style: TextStyle(fontSize: 16)),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  backgroundColor: Colors.teal,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  final targetSurah = QuranDataService.allSurahs.firstWhere(
                                    (s) => s.id == verse.surahId,
                                    orElse: () => QuranDataService.allSurahs.first,
                                  );
                                  provider.setSelectedSurah(targetSurah);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SurahReaderScreen(surah: targetSurah),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.menu_book, size: 20),
                                label: const Text('قراءة السورة كاملة', style: TextStyle(fontSize: 14)),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  side: const BorderSide(color: Colors.teal, width: 1.5),
                                  foregroundColor: Colors.teal,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
