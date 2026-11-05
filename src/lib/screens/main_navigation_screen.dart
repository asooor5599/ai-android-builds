import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/quran_provider.dart';
import 'package:app/screens/quran_screens.dart';
import 'package:app/screens/prayer_times_screen.dart';
import 'package:app/screens/azkar_screen.dart';
import 'package:app/services/quran_data.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('القرآن الكريم'),
        actions: [
          IconButton(icon: Icon(provider.isDarkMode ? Icons.light_mode : Icons.dark_mode), onPressed: () => provider.toggleDarkMode()),
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
              subtitle: Text(provider.selectedReciter.rewaya),
              trailing: const Icon(Icons.search),
              onTap: () => _showReciterPicker(context, provider),
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('اختر السورة'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.menu_book, color: Colors.teal),
              title: Text('سورة ${provider.selectedSurah.name}'),
              subtitle: Text('${provider.selectedSurah.versesCount} آية'),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: () => _showSurahPicker(context, provider),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => provider.playCurrentSurah(),
            icon: const Icon(Icons.play_arrow, size: 30),
            label: const Text('تشغيل الصوت الآن', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16), backgroundColor: Colors.teal, foregroundColor: Colors.white),
          ),
          if (provider.hasAudioStarted) ...[
            const SizedBox(height: 20),
            _buildMiniPlayer(provider),
          ]
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)));

  Widget _buildMiniPlayer(QuranProvider provider) {
    return Card(
      color: Colors.teal.withValues(alpha: 0.1),
      child: Column(
        children: [
          ListTile(
            title: Text('جاري التشغيل: ${provider.selectedSurah.name}'),
            subtitle: Text(provider.selectedReciter.name),
            trailing: IconButton(
              icon: Icon(provider.isPlaying ? Icons.pause_circle : Icons.play_circle, size: 40, color: Colors.teal),
              onPressed: () => provider.isPlaying ? provider.pauseAudio() : provider.resumeAudio(),
            ),
          ),
          Slider(value: provider.position.inSeconds.toDouble(), max: provider.duration.inSeconds.toDouble() > 0 ? provider.duration.inSeconds.toDouble() : 1.0, onChanged: (v) => provider.seekAudio(Duration(seconds: v.toInt()))),
        ],
      ),
    );
  }

  void _showReciterPicker(BuildContext context, QuranProvider provider) {
    showModalBottomSheet(context: context, builder: (ctx) => ListView.builder(itemCount: provider.reciters.length, itemBuilder: (c, i) => ListTile(title: Text(provider.reciters[i].name), onTap: () { provider.setSelectedReciter(provider.reciters[i]); Navigator.pop(ctx); })));
  }

  void _showSurahPicker(BuildContext context, QuranProvider provider) {
    showModalBottomSheet(context: context, builder: (ctx) => ListView.builder(itemCount: QuranDataService.surahs.length, itemBuilder: (c, i) {
      final s = QuranDataService.surahs[i];
      return ListTile(title: Text('سورة ${s.name}'), onTap: () { provider.setSelectedSurah(s); Navigator.pop(ctx); });
    }));
  }
}
