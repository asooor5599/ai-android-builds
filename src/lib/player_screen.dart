import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:app/reminders_screen.dart';

class Surah {
  final String id;
  final String name;
  Surah(this.id, this.name);
}

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late AudioPlayer _player;
  final List<Surah> surahs = [
    Surah('105', 'الفيل'),
    Surah('106', 'قريش'),
    Surah('107', 'الماعون'),
    Surah('108', 'الكوثر'),
    Surah('109', 'الكافرون'),
    Surah('110', 'النصر'),
    Surah('111', 'المسد'),
    Surah('112', 'الإخلاص'),
    Surah('113', 'الفلق'),
    Surah('114', 'الناس'),
  ];

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initPlaylist();
  }

  Future<void> _initPlaylist() async {
    final playlist = ConcatenatingAudioSource(
      children: surahs.map((s) => AudioSource.uri(
        Uri.parse('https://server7.mp3quran.net/shur/${s.id}.mp3'),
        tag: MediaItem(
          id: s.id,
          title: 'سورة ${s.name}',
          artist: 'سعود الشريم',
          album: 'المصحف المرتل',
        ),
      )).toList(),
    );
    await _player.setAudioSource(playlist);
    _player.currentIndexStream.listen((index) {
      if (index != null && mounted) setState(() => _currentIndex = index);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مصحف الشريم'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const RemindersScreen())),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: surahs.length,
              itemBuilder: (context, index) {
                final isPlaying = _currentIndex == index;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isPlaying ? Colors.green[800] : Colors.green[100],
                    child: Text(surahs[index].id, style: TextStyle(color: isPlaying ? Colors.white : Colors.green[800])),
                  ),
                  title: Text('سورة ${surahs[index].name}', style: TextStyle(fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal)),
                  trailing: isPlaying ? Icon(Icons.graphic_eq, color: Colors.green[800]) : null,
                  onTap: () => _player.seek(Duration.zero, index: index).then((_) => _player.play()),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('سورة ${surahs[_currentIndex].name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(icon: const Icon(Icons.skip_previous), onPressed: _player.hasPrevious ? _player.seekToPrevious : null),
                    StreamBuilder<PlayerState>(
                      stream: _player.playerStateStream,
                      builder: (context, snapshot) {
                        final playing = snapshot.data?.playing ?? false;
                        return IconButton(
                          iconSize: 48,
                          icon: Icon(playing ? Icons.pause_circle_filled : Icons.play_circle_filled, color: Colors.green[800]),
                          onPressed: playing ? _player.pause : _player.play,
                        );
                      },
                    ),
                    IconButton(icon: const Icon(Icons.skip_next), onPressed: _player.hasNext ? _player.seekToNext : null),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}