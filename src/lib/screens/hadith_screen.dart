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
  bool _showSavedOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuranProvider>(context);
    final books = QuranDataService.hadithBooks;

    final List<HadithItem> displayedHadiths = _showSavedOnly
        ? provider.bookmarkedHadiths
        : provider.hadiths.where((h) {
            if (provider.hadithSearchQuery.isEmpty) return true;
            return h.text.contains(provider.hadithSearchQuery) ||
                h.number.toString().contains(provider.hadithSearchQuery);
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLogoIcon(size: 24),
            SizedBox(width: 8),
            Text('الأحاديث النبوية الشريفة'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_showSavedOnly ? Icons.bookmark : Icons.bookmark_border),
            tooltip: _showSavedOnly ? 'عرض كافة الأحاديث' : 'عرض المحفوظات فقط',
            onPressed: () {
              setState(() {
                _showSavedOnly = !_showSavedOnly;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Book Selector Bar
          if (!_showSavedOnly)
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
                      showCheckmark: false,
                      label: Text(book.name),
                      selectedColor: Colors.teal,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : null,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) {
                        provider.setSelectedHadithBook(book);
                      },
                    ),
                  );
                },
              ),
            ),
          // Search field
          if (!_showSavedOnly)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => provider.setHadithSearchQuery(val),
                decoration: InputDecoration(
                  hintText: 'ابحث في متن الحديث أو رقم الحديث...',
                  prefixIcon: const Icon(Icons.search, color: Colors.teal),
                  suffixIcon: provider.hadithSearchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            provider.setHadithSearchQuery('');
                          },
                        )
                      : null,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 4),
          // Content
          Expanded(
            child: provider.isLoadingHadiths && !_showSavedOnly
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('جاري تحميل الأحاديث النبوية...'),
                      ],
                    ),
                  )
                : displayedHadiths.isEmpty
                    ? Center(
                        child: Text(_showSavedOnly
                            ? 'لا توجد أحاديث محفوظة في المفضلة'
                            : 'لا توجد أحاديث تطابق البحث'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: displayedHadiths.length,
                        itemBuilder: (context, idx) {
                          final hadith = displayedHadiths[idx];
                          final isBookmarked = provider.isHadithBookmarked(hadith);
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Chip(
                                        label: Text(
                                          '${hadith.bookName} - حديث رقم ${hadith.number}',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                        backgroundColor: Colors.teal.withValues(alpha: 0.1),
                                      ),
                                      if (hadith.grade.isNotEmpty)
                                        Chip(
                                          label: Text(
                                            hadith.grade,
                                            style: const TextStyle(fontSize: 10, color: Colors.white),
                                          ),
                                          backgroundColor: Colors.teal,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  SelectableText(
                                    hadith.text,
                                    style: const TextStyle(
                                      fontSize: 16.5,
                                      height: 1.8,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Amiri',
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Divider(height: 1),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                          color: Colors.teal,
                                        ),
                                        tooltip: 'حفظ الحديث',
                                        onPressed: () => provider.toggleHadithBookmark(hadith),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.copy, color: Colors.teal),
                                        tooltip: 'نسخ الحديث',
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(text: '${hadith.text}\n[${hadith.bookName} - حديث رقم ${hadith.number}]'));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('تم نسخ الحديث إلى الحافظة')),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.share, color: Colors.teal),
                                        tooltip: 'مشاركة الحديث',
                                        onPressed: () {
                                          Share.share('${hadith.text}\n[${hadith.bookName} - حديث رقم ${hadith.number}]');
                                        },
                                      ),
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
