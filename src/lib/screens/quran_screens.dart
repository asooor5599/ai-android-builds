import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/models/quran_models.dart';
import 'package:app/providers/quran_provider.dart';
import 'package:app/services/quran_data.dart';

class SurahListScreen extends StatefulWidget {
  const SurahListScreen({super.key});

  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  void _showDownloadDialog(BuildContext context, QuranProvider provider, Surah surah, Reciter reciter) {
    double progress = 0.0;
    String statusMessage = 'جاري البدء بالتحميل...';
    bool isCompleted = false;
    bool hasError = false;
    bool hasStarted = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            if (!hasStarted) {
              hasStarted = true;
              provider.downloadSurah(
                surah,
                reciter,
                (p, msg) {
                  if (dialogContext.mounted) {
                    setDialogState(() {
                      progress = p;
                      statusMessage = msg;
                      if (p >= 1.0) isCompleted = true;
                      if (p < 0) hasError = true;
                    });
                  }
                },
              );
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.download_for_offline, color: Colors.teal),
                  SizedBox(width: 8),
                  Text('تحميل السورة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'سورة ${surah.name} - بصوت ${reciter.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  if (!hasError && !isCompleted) ...[
                    LinearProgressIndicator(
                      value: progress > 0 ? progress : null,
                      backgroundColor: Colors.teal.withValues(alpha: 0.2),
                      color: Colors.teal,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      statusMessage,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ] else if (isCompleted) ...[
                    const Icon(Icons.check_circle, color: Colors.green, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      statusMessage,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      statusMessage,
                      style: const TextStyle(fontSize: 13, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
              actions: [
                if (isCompleted || hasError)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('إغلاق'),
                  )
                else
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('إلغاء'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuranProvider>(context);
    final surahs = QuranDataService.allSurahs.where((s) {
      return s.name.contains(_searchQuery) ||
          s.englishName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.id.toString() == _searchQuery;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('المصحف الشريف - فهرس السور'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'ابحث عن سورة بالاسم أو الرقم...',
                prefixIcon: const Icon(Icons.search, color: Colors.teal),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: surahs.length,
              itemBuilder: (context, index) {
                final s = surahs[index];
                final isSelected = provider.selectedSurah.id == s.id;
                final isDownloaded = provider.isSurahDownloaded(s.id, provider.selectedReciter.id);

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.teal.withValues(alpha: 0.1) : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDownloaded ? Colors.green.shade700 : Colors.teal,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${s.id}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      'سورة ${s.name}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text('${s.versesCount} آية - ${s.revelationType} ${isDownloaded ? '• (محملة)' : ''}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            isDownloaded ? Icons.download_done : Icons.file_download_outlined,
                            color: isDownloaded ? Colors.green : Colors.amber.shade900,
                          ),
                          tooltip: isDownloaded ? 'محملة جاهزة للاستماع' : 'تحميل السورة',
                          onPressed: () => _showDownloadDialog(
                            context,
                            provider,
                            s,
                            provider.selectedReciter,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.play_circle_fill, color: Colors.teal, size: 28),
                          onPressed: () {
                            provider.setSelectedSurah(s);
                            provider.playCurrentSurah();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('بدأ تشغيل سورة ${s.name} بصوت ${provider.selectedReciter.name}'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      provider.setSelectedSurah(s);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SurahReaderScreen(surah: s),
                        ),
                      );
                    },
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

class SurahReaderScreen extends StatefulWidget {
  final Surah surah;
  const SurahReaderScreen({super.key, required this.surah});

  @override
  State<SurahReaderScreen> createState() => _SurahReaderScreenState();
}

class _SurahReaderScreenState extends State<SurahReaderScreen> {
  final TransformationController _transformationController = TransformationController();
  final PageController _pageController = PageController();
  late Future<List<Verse>> _versesFuture;
  int _currentPageIndex = 0;
  bool _isPageView = true;

  @override
  void initState() {
    super.initState();
    _versesFuture = QuranDataService.fetchSurahVerses(widget.surah.id);
  }

  @override
  void didUpdateWidget(SurahReaderScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.surah.id != widget.surah.id) {
      setState(() {
        _versesFuture = QuranDataService.fetchSurahVerses(widget.surah.id);
      });
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    final Matrix4 current = _transformationController.value;
    final double scale = current.getMaxScaleOnAxis();
    if (scale < 3.5) {
      _transformationController.value = current.scaled(1.2, 1.2, 1.0);
    }
  }

  void _zoomOut() {
    final Matrix4 current = _transformationController.value;
    final double scale = current.getMaxScaleOnAxis();
    if (scale > 0.8) {
      _transformationController.value = current.scaled(0.8, 0.8, 1.0);
    }
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  List<List<Verse>> _paginateVerses(List<Verse> verses, int versesPerPage) {
    List<List<Verse>> pages = [];
    for (var i = 0; i < verses.length; i += versesPerPage) {
      pages.add(verses.sublist(i, i + versesPerPage > verses.length ? verses.length : i + versesPerPage));
    }
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuranProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('سورة ${widget.surah.name}'),
        actions: [
          IconButton(
            icon: Icon(_isPageView ? Icons.view_agenda_outlined : Icons.menu_book),
            tooltip: _isPageView ? 'عرض الآيات متتالية' : 'عرض المصحف الورقي',
            onPressed: () {
              setState(() {
                _isPageView = !_isPageView;
                _resetZoom();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            tooltip: 'تكبير الصفحة',
            onPressed: _zoomIn,
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            tooltip: 'تصغير الصفحة',
            onPressed: _zoomOut,
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: 'إعادة الضبط',
            onPressed: _resetZoom,
          ),
        ],
      ),
      body: FutureBuilder<List<Verse>>(
        future: _versesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('جاري فتح المصحف...'),
                ],
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('تعذر تحميل آيات السورة'));
          }

          final verses = snapshot.data!;

          if (!_isPageView) {
            return _buildListView(verses, provider);
          }

          final pages = _paginateVerses(verses, 7);

          return Column(
            children: [
              if (provider.hasAudioStarted && provider.selectedSurah.id == widget.surah.id)
                _buildCompactAudioBanner(provider),
              Expanded(
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 0.7,
                  maxScale: 3.5,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (idx) {
                      setState(() {
                        _currentPageIndex = idx;
                      });
                    },
                    itemCount: pages.length,
                    itemBuilder: (context, pageIdx) {
                      final pageVerses = pages[pageIdx];
                      return _buildMushafPage(
                        pageVerses: pageVerses,
                        pageNumber: pageIdx + 1,
                        totalPages: pages.length,
                        surah: widget.surah,
                        provider: provider,
                      );
                    },
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Theme.of(context).cardColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _currentPageIndex > 0
                          ? () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          : null,
                    ),
                    Text(
                      'ورقة ${_currentPageIndex + 1} من ${pages.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: _currentPageIndex < pages.length - 1
                          ? () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCompactAudioBanner(QuranProvider provider) {
    return Container(
      color: Colors.teal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.volume_up, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'القارئ: ${provider.selectedReciter.name}',
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(
              provider.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () => provider.isPlaying ? provider.pauseAudio() : provider.resumeAudio(),
          ),
        ],
      ),
    );
  }

  Widget _buildMushafPage({
    required List<Verse> pageVerses,
    required int pageNumber,
    required int totalPages,
    required Surah surah,
    required QuranProvider provider,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paperColor = isDark ? const Color(0xFF1E2623) : const Color(0xFFFFFDF5);
    final borderColor = isDark ? const Color(0xFF385549) : const Color(0xFFC7B280);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: paperColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: borderColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'سورة ${surah.name}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.tealAccent : const Color(0xFF5A4418),
                    ),
                  ),
                  Text(
                    '${surah.revelationType} - ${surah.versesCount} آية',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[300] : const Color(0xFF6B5A33),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (pageNumber == 1 && surah.id != 9) ...[
              Text(
                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: provider.fontSize + 2,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade700,
                  height: 2.0,
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
                  height: 2.2,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                children: pageVerses.expand((v) {
                  final isBookmarked = provider.isBookmarked(surah.id, v.numberInSurah);
                  return [
                    TextSpan(
                      text: '${v.text} ',
                      style: TextStyle(
                        backgroundColor: isBookmarked
                            ? Colors.teal.withValues(alpha: 0.2)
                            : null,
                      ),
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: GestureDetector(
                        onTap: () {
                          provider.toggleBookmark(
                            Bookmark(
                              surahId: surah.id,
                              surahName: surah.name,
                              verseNumber: v.numberInSurah,
                              verseText: v.text,
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isBookmarked
                                    ? 'تم إزالة الآية ${v.numberInSurah} من المحفوظات'
                                    : 'تم حفظ الآية ${v.numberInSurah} في المحفوظات',
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isBookmarked ? Colors.amber : Colors.teal,
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
            const SizedBox(height: 24),
            Divider(color: borderColor.withValues(alpha: 0.5), thickness: 1),
            Text(
              'صفحة $pageNumber / $totalPages',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(List<Verse> verses, QuranProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: verses.length,
      itemBuilder: (context, i) {
        final v = verses[i];
        final isBookmarked = provider.isBookmarked(widget.surah.id, v.numberInSurah);
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  v.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: provider.fontSize,
                    height: 2.0,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'آية ${v.numberInSurah}',
                        style: const TextStyle(
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: Colors.teal,
                      ),
                      onPressed: () => provider.toggleBookmark(
                        Bookmark(
                          surahId: widget.surah.id,
                          surahName: widget.surah.name,
                          verseNumber: v.numberInSurah,
                          verseText: v.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
