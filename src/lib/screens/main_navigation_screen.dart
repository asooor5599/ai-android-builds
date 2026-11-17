import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/quran_provider.dart';
import 'package:app/screens/quran_screens.dart';
import 'package:app/screens/prayer_times_screen.dart';
import 'package:app/screens/azkar_screen.dart';
import 'package:app/screens/random_verse_screen.dart';
import 'package:app/models/quran_models.dart';

class AppLogoIcon extends StatelessWidget {
  final double size;
  const AppLogoIcon({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Colors.amber, Colors.teal],
          radius: 0.85,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(size * 0.15),
      child: Center(
        child: Icon(
          Icons.auto_stories_rounded,
          size: size * 0.65,
          color: Colors.white,
        ),
      ),
    );
  }
}

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuranProvider>(context);
    final pages = [
      const RandomVerseScreen(),
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
          NavigationDestination(icon: Icon(Icons.format_quote), label: 'آية عشوائية'),
          NavigationDestination(icon: Icon(Icons.home), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'المصحف'),
          NavigationDestination(icon: Icon(Icons.access_time), label: 'المواقيت'),
          NavigationDestination(icon: Icon(Icons.auto_awesome), label: 'الأذكار والمحفوظات'),
        ],
      ),
    );
  }
}

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuranProvider>(context);
    final availableSurahs = provider.availableSurahsForSelectedReciter;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLogoIcon(size: 26),
            SizedBox(width: 10),
            Text('تطبيق القرآن الكريم'),
          ],
        ),
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
          _buildBannerCard(context, provider),
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
              trailing: const Icon(Icons.search),
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
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => provider.playCurrentSurah(),
                  icon: const Icon(Icons.play_arrow, size: 24),
                  label: const Text('تشغيل الصوت', style: TextStyle(fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildDownloadButton(context, provider),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SurahReaderScreen(surah: provider.selectedSurah),
                      ),
                    );
                  },
                  icon: const Icon(Icons.auto_stories, size: 20),
                  label: const Text('قراءة المصحف', style: TextStyle(fontSize: 14)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
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

  Widget _buildDownloadButton(BuildContext context, QuranProvider provider) {
    final isDownloaded = provider.isSurahDownloaded(provider.selectedReciter.id, provider.selectedSurah.id);
    final isDownloading = provider.isDownloading(provider.selectedReciter.id, provider.selectedSurah.id);
    final progress = provider.getDownloadProgress(provider.selectedReciter.id, provider.selectedSurah.id);

    if (isDownloaded) {
      return OutlinedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('هذه السورة محملة بالفعل في المحفوظات وتعمل بدون إنترنت')),
          );
        },
        icon: const Icon(Icons.check_circle, color: Colors.teal, size: 20),
        label: const Text('محمّلة', style: TextStyle(fontSize: 13)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          side: const BorderSide(color: Colors.teal),
          foregroundColor: Colors.teal,
        ),
      );
    }

    if (isDownloading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.teal),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(value: progress > 0 ? progress : null, strokeWidth: 2),
            ),
            const SizedBox(width: 6),
            Text('${(progress * 100).toInt()}%', style: const TextStyle(color: Colors.teal, fontSize: 12)),
          ],
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: () async {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('بدأ تحميل سورة ${provider.selectedSurah.name}...')),
        );
        await provider.downloadSurah(provider.selectedSurah, provider.selectedReciter);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم تحميل سورة ${provider.selectedSurah.name} وحفظها بنجاح في تبويب المحفوظات')),
          );
        }
      },
      icon: const Icon(Icons.download, size: 20),
      label: const Text('تحميل', style: TextStyle(fontSize: 14)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        side: const BorderSide(color: Colors.teal, width: 1.5),
        foregroundColor: Colors.teal,
      ),
    );
  }

  Widget _buildBannerCard(BuildContext context, QuranProvider provider) {
    final verse = provider.randomVerse;
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.format_quote, color: Colors.amber, size: 28),
                  SizedBox(width: 8),
                  Text(
                    'آية اليوم / آية عشوائية',
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.amber, size: 20),
                onPressed: () => provider.fetchRandomVerse(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            verse != null ? '«${verse.verseText}»' : '«الَّذِينَ آمَنُوا وَتَطْمَئِنُّ قُلُوبُهُم بِذِكْرِ اللَّهِ ۗ أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ»',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 15,
              height: 1.6,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              verse != null ? '[ سورة ${verse.surahName}: ${verse.verseNumber} ]' : '[ سورة الرعد: 28 ]',
              style: const TextStyle(color: Colors.white60, fontSize: 12),
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
    final isDownloaded = provider.isSurahDownloaded(provider.selectedReciter.id, provider.selectedSurah.id);
    final isDownloading = provider.isDownloading(provider.selectedReciter.id, provider.selectedSurah.id);

    return Card(
      color: Colors.teal.withValues(alpha: 0.1),
      child: Column(
        children: [
          ListTile(
            title: Text('جاري التشغيل: سورة ${provider.selectedSurah.name}'),
            subtitle: Text(provider.selectedReciter.name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isDownloading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (isDownloaded)
                  const Icon(Icons.download_done, color: Colors.teal)
                else
                  IconButton(
                    icon: const Icon(Icons.download, color: Colors.teal),
                    tooltip: 'تحميل السورة',
                    onPressed: () => provider.downloadSurah(provider.selectedSurah, provider.selectedReciter),
                  ),
                const SizedBox(width: 4),
                provider.isBuffering
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
              ],
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
