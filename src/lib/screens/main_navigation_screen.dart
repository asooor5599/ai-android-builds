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
          NavigationDestination(icon: Icon(Icons.auto_awesome), label: 'الأذكار'),
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
          _buildBannerCard(context),
          const SizedBox(height: 16),
          _buildSectionHeader('اختر القارئ'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.teal),
              title: Text(provider.selectedReciter.name),
              subtitle: Text(provider.selectedReciter.rewaya),
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
              subtitle: Text('${provider.selectedSurah.versesCount} آية'),
              trailing: const Icon(Icons.search),
              onTap: () => _showSearchPicker<Surah>(
                context,
                title: 'اختر السورة',
                items: availableSurahs,
                itemTitle: (s) => 'سورة ${s.name}',
                itemSubtitle: (s) => '${s.versesCount} آية',
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
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('تشغيل الصوت'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              _buildDownloadButton(context, provider),
            ],
          ),
          if (provider.hasAudioStarted) ...[
            const SizedBox(height: 20),
            _buildMiniPlayer(context, provider),
          ]
        ],
      ),
    );
  }

  Widget _buildDownloadButton(BuildContext context, QuranProvider provider) {
    final isDownloaded = provider.isSurahDownloaded(provider.selectedReciter.id, provider.selectedSurah.id);
    final isDownloading = provider.isSurahDownloading(provider.selectedReciter.id, provider.selectedSurah.id);
    if (isDownloading) return const Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator(strokeWidth: 2));
    return IconButton(
      icon: Icon(isDownloaded ? Icons.download_done : Icons.download, color: Colors.teal),
      onPressed: () => provider.downloadSurah(provider.selectedReciter, provider.selectedSurah),
    );
  }

  Widget _buildBannerCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.teal.shade700, Colors.teal.shade900]),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('آية اليوم', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('«أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ»', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)));

  Widget _buildMiniPlayer(BuildContext context, QuranProvider provider) {
    return Card(
      color: Colors.teal.withOpacity(0.1),
      child: Column(
        children: [
          ListTile(
            title: Text('سورة ${provider.selectedSurah.name}'),
            subtitle: Text(provider.selectedReciter.name),
            trailing: IconButton(
              icon: Icon(provider.isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: () => provider.isPlaying ? provider.pauseAudio() : provider.resumeAudio(),
            ),
          ),
          Slider(value: provider.position.inSeconds.toDouble(), max: provider.duration.inSeconds.toDouble() > 0 ? provider.duration.inSeconds.toDouble() : 1.0, onChanged: (v) => provider.seekAudio(Duration(seconds: v.toInt()))),
        ],
      ),
    );
  }

  void _showSearchPicker<T>(BuildContext context, {required String title, required List<T> items, required String Function(T) itemTitle, required String Function(T) itemSubtitle, required Function(T) onSelected}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        builder: (_, scrollController) => Column(
          children: [
            Padding(padding: const EdgeInsets.all(16), child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: items.length,
                itemBuilder: (c, i) => ListTile(
                  title: Text(itemTitle(items[i])),
                  subtitle: Text(itemSubtitle(items[i])),
                  onTap: () {
                    onSelected(items[i]);
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}