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
          NavigationDestination(icon: Icon(Icons.bookmark), label: 'المحفوظات'),
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
                  label: const Text('تشغيل الصوت', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
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
                  icon: const Icon(Icons.auto_stories, size: 24),
                  label: const Text('قراءة المصحف', style: TextStyle(fontSize: 16)),
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

  Widget _buildSectionHeader(String title) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      );

  Widget _buildMiniPlayer(QuranProvider provider) {
    return Card(
      color: Colors.teal.withValues(alpha: 0.1),
      child: Column(
        children: [
          ListTile(
            title: Text('جاري التشغيل: سورة ${provider.selectedSurah.name}'),
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
