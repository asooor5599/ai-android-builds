import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/quran_provider.dart';
import 'package:app/screens/surah_list_screen.dart';
import 'package:app/screens/azkar_screen.dart';
import 'package:app/screens/surah_reader_screen.dart';
import 'package:app/services/quran_data.dart';

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
      body: Stack(
        children: [
          pages[_currentIndex],
          if (provider.isPlaying || provider.isBuffering || provider.position > Duration.zero)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildMiniAudioPlayer(provider),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'الفهرس'),
          NavigationDestination(icon: Icon(Icons.headphones), label: 'المشغل'),
          NavigationDestination(icon: Icon(Icons.bookmark), label: 'المفضلة'),
        ],
      ),
    );
  }

  Widget _buildMiniAudioPlayer(QuranProvider provider) {
    return Material(
      elevation: 12,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.teal.withValues(alpha: 0.3))),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.teal,
              child: const Icon(Icons.music_note, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'سورة ${provider.selectedSurah.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    provider.selectedReciter.name,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (provider.isBuffering)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              IconButton(
                icon: Icon(provider.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
                iconSize: 36,
                color: Colors.teal,
                onPressed: () {
                  if (provider.isPlaying) {
                    provider.pauseAudio();
                  } else {
                    provider.resumeAudio();
                  }
                },
              ),
            IconButton(
              icon: const Icon(Icons.skip_next),
              onPressed: () => provider.playNextSurah(),
            ),
          ],
        ),
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
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade700, Colors.teal.shade400],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.amber),
                    SizedBox(width: 8),
                    Text(
                      'آية اليوم',
                      style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  '«أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ»',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('سورة الرعد - الآية 28', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'القارئ الحالي',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.teal,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(provider.selectedReciter.name),
              subtitle: Text(provider.selectedReciter.rewaya),
              trailing: const Icon(Icons.swap_horiz, color: Colors.teal),
              onTap: () => _showReciterSelector(context, provider),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'سور ممتازة للقراءة والاستماع',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...QuranDataService.surahs.take(5).map((surah) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.withValues(alpha: 0.1),
                    child: Text(
                      '${surah.id}',
                      style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(surah.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${surah.versesCount} آية - ${surah.revelationType}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.play_circle_fill, color: Colors.teal),
                        onPressed: () {
                          provider.setSelectedSurah(surah);
                          provider.playCurrentSurah();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.menu_book, color: Colors.teal),
                        onPressed: () {
                          provider.setSelectedSurah(surah);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SurahReaderScreen(surah: surah),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  void _showReciterSelector(BuildContext context, QuranProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'اختر القارئ المفضَّل',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: QuranDataService.reciters.length,
              itemBuilder: (context, index) {
                final reciter = QuranDataService.reciters[index];
                final isSelected = reciter.id == provider.selectedReciter.id;
                return ListTile(
                  leading: Icon(
                    Icons.mic,
                    color: isSelected ? Colors.teal : Colors.grey,
                  ),
                  title: Text(reciter.name),
                  subtitle: Text(reciter.rewaya),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Colors.teal)
                      : null,
                  onTap: () {
                    provider.setSelectedReciter(reciter);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PlayerTabScreen extends StatelessWidget {
  const PlayerTabScreen({super.key});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuranProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('مشغل التلاوات'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.teal.withValues(alpha: 0.1),
                border: Border.all(color: Colors.teal, width: 4),
              ),
              child: const Icon(
                Icons.menu_book_sharp,
                size: 80,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'سورة ${provider.selectedSurah.name}',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'بصوت الشيخ: ${provider.selectedReciter.name}',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            if (provider.audioError.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  provider.audioError,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
            Slider(
              value: provider.position.inSeconds.toDouble(),
              max: (provider.duration.inSeconds > 0
                      ? provider.duration.inSeconds
                      : 100)
                  .toDouble(),
              activeColor: Colors.teal,
              onChanged: (val) {
                provider.seekAudio(Duration(seconds: val.toInt()));
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(provider.position)),
                  Text(_formatDuration(provider.duration)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  iconSize: 40,
                  onPressed: () => provider.playPreviousSurah(),
                ),
                const SizedBox(width: 16),
                if (provider.isBuffering)
                  const SizedBox(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(),
                  )
                else
                  IconButton(
                    icon: Icon(
                      provider.isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                    ),
                    iconSize: 72,
                    color: Colors.teal,
                    onPressed: () {
                      if (provider.isPlaying) {
                        provider.pauseAudio();
                      } else {
                        provider.resumeAudio();
                      }
                    },
                  ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  iconSize: 40,
                  onPressed: () => provider.playNextSurah(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [0.75, 1.0, 1.25, 1.5].map((speed) {
                final isSelected = provider.playbackSpeed == speed;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text('${speed}x'),
                    selected: isSelected,
                    onSelected: (_) => provider.setSpeed(speed),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
