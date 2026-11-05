import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/quran_provider.dart';
import 'package:app/services/quran_data.dart';
import 'package:app/screens/surah_list_screen.dart';
import 'package:app/screens/surah_reader_screen.dart';
import 'package:app/screens/azkar_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuranProvider>(context);
    final pages = [
      const HomeDashboard(),
      const SurahListScreen(),
      const PlayerTabScreen(),
      const AzkarAndBookmarksScreen(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'الفهرس'),
          NavigationDestination(icon: Icon(Icons.headphones), label: 'المشغل'),
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
          IconButton(
            icon: Icon(provider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => provider.toggleDarkMode(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('اختر القارئ:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          DropdownButtonFormField(value: provider.selectedReciter, items: QuranDataService.reciters.map((r) => DropdownMenuItem(value: r, child: Text(r.name))).toList(), onChanged: (val) => provider.setSelectedReciter(val!), decoration: const InputDecoration(border: OutlineInputBorder())),
          const SizedBox(height: 20),
          const Text('اختر السورة:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          DropdownButtonFormField(value: provider.selectedSurah, items: QuranDataService.surahs.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(), onChanged: (val) => provider.setSelectedSurah(val!), decoration: const InputDecoration(border: OutlineInputBorder())),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => provider.playCurrentSurah(),
            icon: const Icon(Icons.play_arrow),
            label: const Text('تشغيل الآن'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16), backgroundColor: Colors.teal, foregroundColor: Colors.white),
          ),
          const SizedBox(height: 40),
          const Text('سور مقترحة للقراءة:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...QuranDataService.surahs.take(3).map((s) => ListTile(title: Text(s.name), subtitle: Text(s.revelationType), trailing: const Icon(Icons.arrow_forward_ios, size: 16), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SurahReaderScreen(surah: s))))),
        ],
      ),
    );
  }
}

class PlayerTabScreen extends StatelessWidget {
  const PlayerTabScreen({super.key});
  String _format(Duration d) => '${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuranProvider>(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.music_note, size: 100, color: Colors.teal),
          const SizedBox(height: 20),
          Text('سورة ${provider.selectedSurah.name}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(provider.selectedReciter.name, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 30),
          Slider(value: provider.position.inSeconds.toDouble(), max: provider.duration.inSeconds.toDouble() > 0 ? provider.duration.inSeconds.toDouble() : 1.0, onChanged: (v) => provider.seekAudio(Duration(seconds: v.toInt()))),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(_format(provider.position)), Text(_format(provider.duration))])),
          const SizedBox(height: 20),
          if (provider.isBuffering) const CircularProgressIndicator() else IconButton(icon: Icon(provider.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled), iconSize: 80, color: Colors.teal, onPressed: () => provider.isPlaying ? provider.pauseAudio() : provider.resumeAudio()),
        ],
      ),
    );
  }
}
