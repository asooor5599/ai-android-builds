import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:app/providers/quran_provider.dart';
import 'package:app/models/quran_models.dart';
import 'package:app/services/quran_data.dart';
import 'package:app/screens/main_navigation_screen.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuranProvider>(context);
    final books = QuranDataService.hadithBooks;

    final List<HadithItem> displayedHadiths = provider.hadiths.where((h) {
      if (provider.hadithSearchQuery.isEmpty) return true;
      return h.text.contains(provider.hadithSearchQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLogoIcon(size: 24),
            SizedBox(width: 8),
            Text('الأحاديث النبوية'),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: books.length,
              itemBuilder: (context, idx) {
                final book = books[idx];
                final isSelected = provider.selectedHadithBook.id == book.id;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(book.name),
                    onSelected: (_) => provider.setSelectedHadithBook(book),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => provider.setHadithSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'ابحث في الأحاديث...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          Expanded(
            child: provider.isLoadingHadiths
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: displayedHadiths.length,
                    itemBuilder: (context, idx) {
                      final hadith = displayedHadiths[idx];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('حديث رقم ${hadith.number}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                              const SizedBox(height: 8),
                              Text(hadith.text, style: const TextStyle(fontSize: 16, height: 1.8, fontFamily: 'Amiri')),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(icon: const Icon(Icons.copy), onPressed: () => Clipboard.setData(ClipboardData(text: hadith.text))),
                                  IconButton(icon: const Icon(Icons.share), onPressed: () => Share.share(hadith.text)),
                                ],
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
