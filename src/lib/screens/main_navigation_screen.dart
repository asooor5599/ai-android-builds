import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/quran_provider.dart';
import 'package:app/screens/quran_screens.dart';
import 'package:app/screens/prayer_times_screen.dart';
import 'package:app/screens/azkar_screen.dart';
import 'package:app/models/quran_models.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuranProvider>(context);
    final pages = [
      const HomeDashboard(),
      const SurahListScreen(),
      const PrayerTimesScreen(),
      const AzkarAndBookmarksScreen(),
    ];

    return Scaffold(
      body: pages[provider.activeTabIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: provider.activeTabIndex,
        onDestinationSelected: (idx) => provider.setActiveTab(idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'المصحف'),
          NavigationDestination(icon: Icon(Icons.access_time), label: 'المواقيت'),
          NavigationDestination(icon: Icon(Icons.download_done_rounded), label: 'الأذكار والمحفوظات'),
        ],
      ),
    );
  }
}

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

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
    final availableSurahs = provider.availableSurahsForSelectedReciter;
    final isDownloaded = provider.isSurahDownloaded(provider.selectedSurah.id, provider.selectedReciter.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('القرآن الكريم'),
        actions: [
          IconButton(
            icon: Icon(provider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => provider.toggleDarkMode(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildBannerCard(context),
          const SizedBox(height: 16),
          _buildSectionHeader('اختر القارئ'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.teal),
              title: Text(provider.selectedReciter.name),
              subtitle: Text('${provider.selectedReciter.rewaya} (${availableSurahs.length} سورة متاحة)'),
              trailing: const Icon(Icons.search),
              onTap: () => _showSearchPicker<Reciter>(
                context,
                title: 'ابحث عن قارئ',
                items: provider.reciters,
                itemTitle: (r) => r.name,
                itemSubtitle: (r) => r.rewaya,
                onSelected: (r) => provider.setSelectedReciter(r),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('اختر السورة'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.menu_book, color: Colors.teal),
              title: Text('سورة ${provider.selectedSurah.name}'),
              subtitle: Text('${provider.selectedSurah.versesCount} آية - ${provider.selectedSurah.revelationType}'),
              trailing: isDownloaded
                  ? const Icon(Icons.offline_pin, color: Colors.green)
                  : const Icon(Icons.search),
              onTap: () => _showSearchPicker<Surah>(
                context,
                title: 'اختر السورة (${availableSurahs.length} سورة)',
                items: availableSurahs,
                itemTitle: (s) => 'سورة ${s.name}',
                itemSubtitle: (s) => '${s.versesCount} آية - ${s.revelationType}',
                onSelected: (s) => provider.setSelectedSurah(s),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => provider.playCurrentSurah(),
                      icon: Icon(isDownloaded ? Icons.play_arrow : Icons.play_arrow, size: 24),
                      label: Text(
                        isDownloaded ? 'تشغيل (محملة ⚡)' : 'تشغيل الصوت',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: isDownloaded ? Colors.teal.shade800 : Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => _showDownloadDialog(
                      context,
                      provider,
                      provider.selectedSurah,
                      provider.selectedReciter,
                    ),
                    icon: Icon(isDownloaded ? Icons.download_done : Icons.file_download, size: 22),
                    label: Text(isDownloaded ? 'محملة' : 'تحميل'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      backgroundColor: isDownloaded ? Colors.green.shade700 : Colors.amber.shade800,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SurahReaderScreen(surah: provider.selectedSurah),
                      ),
                    );
                  },
                  icon: const Icon(Icons.auto_stories, size: 22),
                  label: const Text('قراءة المصحف بالكلمات', style: TextStyle(fontSize: 15)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Colors.teal, width: 1.5),
                    foregroundColor: Colors.teal,
                  ),
                ),
              ),
            ],
          ),
          if (provider.hasAudioStarted) ...[
            const SizedBox(height: 20),
            _buildMiniPlayer(provider),
          ]
        ],
      ),
    );
  }

  Widget _buildBannerCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade700, Colors.teal.shade900],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.format_quote, color: Colors.amber, size: 28),
              SizedBox(width: 8),
              Text(
                'آية اليوم',
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '«الَّذِينَ آمَنُوا وَتَطْمَئِنُّ قُلُوبُهُم بِذِكْرِ اللَّهِ ۗ أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ»',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 15,
              height: 1.6,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '[ سورة الرعد: 28 ]',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      );

  Widget _buildMiniPlayer(QuranProvider provider) {
    final isOffline = provider.isSurahDownloaded(provider.selectedSurah.id, provider.selectedReciter.id);
    return Card(
      color: Colors.teal.withValues(alpha: 0.1),
      child: Column(
        children: [
          ListTile(
            title: Text('جاري التشغيل: سورة ${provider.selectedSurah.name} ${isOffline ? '(بدون إنترنت ⚡)' : ''}'),
            subtitle: Text(provider.selectedReciter.name),
            trailing: provider.isBuffering
                ? const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : IconButton(
                    icon: Icon(
                      provider.isPlaying ? Icons.pause_circle : Icons.play_circle,
                      size: 40,
                      color: Colors.teal,
                    ),
                    onPressed: () => provider.isPlaying
                        ? provider.pauseAudio()
                        : provider.resumeAudio(),
                  ),
          ),
          Slider(
            value: provider.position.inSeconds.toDouble().clamp(
                  0.0,
                  provider.duration.inSeconds.toDouble() > 0
                      ? provider.duration.inSeconds.toDouble()
                      : 1.0,
                ),
            max: provider.duration.inSeconds.toDouble() > 0
                ? provider.duration.inSeconds.toDouble()
                : 1.0,
            onChanged: (v) => provider.seekAudio(Duration(seconds: v.toInt())),
          ),
        ],
      ),
    );
  }

  void _showSearchPicker<T>(
    BuildContext context, {
    required String title,
    required List<T> items,
    required String Function(T) itemTitle,
    required String Function(T) itemSubtitle,
    required Function(T) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _SearchPickerWidget<T>(
        title: title,
        items: items,
        itemTitle: itemTitle,
        itemSubtitle: itemSubtitle,
        onSelected: onSelected,
      ),
    );
  }
}

class _SearchPickerWidget<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) itemTitle;
  final String Function(T) itemSubtitle;
  final Function(T) onSelected;
  const _SearchPickerWidget({
    required this.title,
    required this.items,
    required this.itemTitle,
    required this.itemSubtitle,
    required this.onSelected,
  });
  @override
  State<_SearchPickerWidget<T>> createState() => _SearchPickerWidgetState<T>();
}

class _SearchPickerWidgetState<T> extends State<_SearchPickerWidget<T>> {
  late List<T> filteredItems;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
  }

  void _filter(String query) {
    setState(() {
      filteredItems = widget.items
          .where((item) =>
              widget.itemTitle(item).toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(widget.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            onChanged: _filter,
            decoration: InputDecoration(
              hintText: 'ابحث هنا...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: filteredItems.isEmpty
                ? const Center(child: Text('لا توجد نتائج'))
                : ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (c, i) => ListTile(
                      title: Text(widget.itemTitle(filteredItems[i])),
                      subtitle: Text(widget.itemSubtitle(filteredItems[i])),
                      onTap: () {
                        widget.onSelected(filteredItems[i]);
                        Navigator.pop(context);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
