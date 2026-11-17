import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:app/models.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  int? _currentIndex;
  bool _isPlaying = false;

  AudioProvider() {
    _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });
    _player.currentIndexStream.listen((index) {
      _currentIndex = index;
      notifyListeners();
    });
  }

  AudioPlayer get player => _player;
  bool get isPlaying => _isPlaying;
  int? get currentIndex => _currentIndex;

  Future<void> playSurah(int index) async {
    final playlist = ConcatenatingAudioSource(
      children: quranSurahs.map((s) => AudioSource.uri(
        Uri.parse(s.url),
        tag: MediaItem(
          id: s.id.toString(),
          album: 'القرآن الكريم',
          title: 'سورة ${s.name}',
          artist: 'سعود الشريم',
        ),
      )).toList(),
    );

    try {
      await _player.setAudioSource(playlist, initialIndex: index);
      _player.play();
    } catch (e) {
      debugPrint('Error loading audio: $e');
    }
  }

  void togglePlay() {
    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  void next() => _player.seekToNext();
  void previous() => _player.seekToPrevious();

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}