import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/models/quran_models.dart';
import 'package:app/providers/quran_provider.dart';
import 'package:app/services/quran_data.dart';
import 'package:app/screens/surah_list_screen.dart';
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
    final pages = [
      HomeDashboard(onNavigateToPlayer: () => setState(() => _currentIndex = 2)),
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

class HomeDashboard extends StatefulWidget {
  final VoidCallback onNavigateToPlayer;
  const HomeDashboard({super.key, required this.onNavigateToPlayer});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  void _showReciterSearchModal(BuildContext context, QuranProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return const _ReciterSearchBottomSheet();
      },
    );
  }

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
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.person, color: Colors.teal),
                          SizedBox(width: 8),
                          Text('اختر القارئ:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () => _showReciterSearchModal(context, provider),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.teal.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(provider.selectedReciter.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    Text(provider.selectedReciter.rewaya, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.search, color: Colors.teal),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<Reciter>(
                        value: provider.selectedReciter,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'أو اختر من القائمة المنسدلة',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: QuranDataService.reciters.map((r) => DropdownMenuItem(value: r, child: Text(r.name, overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (val) {
                          if (val != null) provider.setSelectedReciter(val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.menu_book, color: Colors.teal),
                          SizedBox(width: 8),
                          Text('اختر السورة:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<Surah>(
                        value: provider.selectedSurah,
                        isExpanded: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: QuranDataService.surahs.map((s) => DropdownMenuItem(value: s, child: Text('سورة ${s.name} (${s.revelationType})', overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (val) {
                          if (val != null) provider.setSelectedSurah(val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () => provider.playCurrentSurah(),
                icon: const Icon(Icons.play_arrow, size: 28),
                label: const Text('تشغيل الآن', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 100), // extra padding for bottom mini player
            ],
          ),
          if (provider.hasAudioStarted)
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: _MiniPlayerWidget(onTapExpand: widget.onNavigateToPlayer),
            ),
        ],
      ),
    );
  }
}

class _ReciterSearchBottomSheet extends StatefulWidget {
  const _ReciterSearchBottomSheet();

  @override
  State<_ReciterSearchBottomSheet> createState() => _ReciterSearchBottomSheetState();
}

class _ReciterSearchBottomSheetState extends State<_ReciterSearchBottomSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuranProvider>(context, listen: false);
    final filteredReciters = QuranDataService.reciters.where((r) => r.name.contains(_query) || r.rewaya.contains(_query)).toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (ctx, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2)),
              ),
              TextField(
                autofocus: true,
                onChanged: (val) => setState(() => _query = val),
                decoration: InputDecoration(
                  hintText: 'ابحث باسم القارئ...',
                  prefixIcon: const Icon(Icons.search, color: Colors.teal),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.teal, width: 2)),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: filteredReciters.isEmpty
                    ? const Center(child: Text('لم يتم العثور على نتائج'))
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: filteredReciters.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, idx) {
                          final reciter = filteredReciters[idx];
                          final isSelected = provider.selectedReciter.id == reciter.id;
                          return ListTile(
                            title: Text(reciter.name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.teal : null)),
                            subtitle: Text(reciter.rewaya, style: const TextStyle(fontSize: 12)),
                            trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.teal) : null,
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
      },
    );
  }
}

class _MiniPlayerWidget extends StatelessWidget {
  final VoidCallback onTapExpand;
  const _MiniPlayerWidget({required this.onTapExpand});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuranProvider>(context);
    final double progress = (provider.duration.inMilliseconds > 0)
        ? (provider.position.inMilliseconds / provider.duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: provider.isDarkMode ? Colors.teal.shade900 : Colors.teal.shade50,
      child: InkWell(
        onTap: onTapExpand,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Icon(
                      provider.isPlaying ? Icons.music_note : Icons.music_off,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('سورة ${provider.selectedSurah.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text(provider.selectedReciter.name, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  if (provider.isBuffering)
                    const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5))
                  else
                    IconButton(
                      icon: Icon(provider.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 36, color: Colors.teal),
                      onPressed: () => provider.isPlaying ? provider.pauseAudio() : provider.resumeAudio(),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(value: progress, minHeight: 4, backgroundColor: Colors.teal.withValues(alpha: 0.2), valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal)),
              ),
            ],
          ),
        ),
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
    return Scaffold(
      appBar: AppBar(title: const Text('مشغل الصوت')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.teal.withValues(alpha: 0.1),
                ),
                child: const Icon(Icons.headphones, size: 100, color: Colors.teal),
              ),
              const SizedBox(height: 30),
              Text('سورة ${provider.selectedSurah.name}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(provider.selectedReciter.name, style: const TextStyle(fontSize: 18, color: Colors.grey)),
              const SizedBox(height: 30),
              Slider(
                value: provider.position.inSeconds.toDouble(),
                max: provider.duration.inSeconds.toDouble() > 0 ? provider.duration.inSeconds.toDouble() : 1.0,
                onChanged: (v) => provider.seekAudio(Duration(seconds: v.toInt())),
                activeColor: Colors.teal,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_format(provider.position)),
                    Text(_format(provider.duration)),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              if (provider.isBuffering)
                const CircularProgressIndicator()
              else
                IconButton(
                  icon: Icon(provider.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
                  iconSize: 84,
                  color: Colors.teal,
                  onPressed: () => provider.isPlaying ? provider.pauseAudio() : provider.resumeAudio(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
