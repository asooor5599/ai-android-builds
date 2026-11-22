import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audio_session/audio_session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:app/models/quran_models.dart';
import 'package:app/services/quran_data.dart';

class QuranProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<Reciter> _reciters = QuranDataService.fallbackReciters;
  Reciter _selectedReciter = QuranDataService.fallbackReciters.first;
  Surah _selectedSurah = QuranDataService.allSurahs.first;
  bool _isLoadingReciters = true;
  bool _isPlaying = false;
  bool _isBuffering = false;
  bool _hasAudioStarted = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  final double _fontSize = 22.0;
  bool _isDarkMode = false;
  List<Bookmark> _bookmarks = [];
  List<DownloadedSurah> _downloadedSurahs = [];
  final Map<String, double> _downloadProgress = {};
  final Set<String> _downloadingKeys = {};
  int _activeTabIndex = 0;
  Map<String, String> _dailyVerse = {};

  PrayerTimesData? _prayerTimes = PrayerTimesData.defaultTimes('موقعي');
  bool _isLoadingPrayers = false;
  String _locationError = '';
  String _currentTime = '';
  Timer? _clockTimer;

  List<ZekrItem> _azkarList = [];
  bool _isLoadingAzkar = true;
  final Map<String, int> _zekrCounters = {};

  List<Reciter> get reciters => _reciters;
  Reciter get selectedReciter => _selectedReciter;
  Surah get selectedSurah => _selectedSurah;
  bool get isLoadingReciters => _isLoadingReciters;
  bool get isPlaying => _isPlaying;
  bool get isBuffering => _isBuffering;
  bool get hasAudioStarted => _hasAudioStarted;
  Duration get position => _position;
  Duration get duration => _duration;
  double get fontSize => _fontSize;
  bool get isDarkMode => _isDarkMode;
  List<Bookmark> get bookmarks => _bookmarks;
  List<DownloadedSurah> get downloadedSurahs => _downloadedSurahs;
  int get activeTabIndex => _activeTabIndex;
  Map<String, String> get dailyVerse => _dailyVerse;
  PrayerTimesData? get prayerTimes => _prayerTimes;
  bool get isLoadingPrayers => _isLoadingPrayers;
  String get locationError => _locationError;
  String get currentTime => _currentTime;
  List<ZekrItem> get azkarList => _azkarList;
  bool get isLoadingAzkar => _isLoadingAzkar;

  List<Surah> get availableSurahsForSelectedReciter {
    final ids = _selectedReciter.effectiveSurahIds;
    return QuranDataService.allSurahs.where((s) => ids.contains(s.id)).toList();
  }

  void init() {
    _dailyVerse = getRandomVerse();
    _updateTime();
    _startClock();
    _loadSettings();
    _loadDownloadedSurahs();
    _setupAudioListeners();
    fetchReciters();
    requestPermissionsAndInitLocation();
    fetchAzkarData();
  }

  Future<void> requestPermissionsAndInitLocation() async {
    if (!kIsWeb) {
      try {
        final localNotifications = FlutterLocalNotificationsPlugin();
        await localNotifications
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      } catch (_) {}
    }
    await initLocationAndPrayers();
  }

  Map<String, String> getRandomVerse() {
    final random = Random();
    return QuranDataService.randomVerses[random.nextInt(QuranDataService.randomVerses.length)];
  }

  void _updateTime() {
    final now = DateTime.now();
    final hour = now.hour == 0 ? 12 : (now.hour > 12 ? now.hour - 12 : now.hour);
    final period = now.hour >= 12 ? 'م' : 'ص';
    final h = hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');
    _currentTime = '$h:$m:$s $period';
  }

  void _startClock() {
    _updateTime();
    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
      notifyListeners();
    });
  }

  void setActiveTab(int index) {
    _activeTabIndex = index;
    notifyListeners();
  }

  Future<void> fetchAzkarData() async {
    _isLoadingAzkar = true;
    notifyListeners();
    _azkarList = await QuranDataService.fetchAzkarFromApi();
    _isLoadingAzkar = false;
    notifyListeners();
  }

  int getZekrCount(String id, int initialCount) {
    return _zekrCounters[id] ?? initialCount;
  }

  void decrementZekrCount(String id, int initialCount) {
    final current = getZekrCount(id, initialCount);
    if (current > 0) {
      _zekrCounters[id] = current - 1;
      notifyListeners();
    }
  }

  void resetZekrCount(String id, int initialCount) {
    _zekrCounters[id] = initialCount;
    notifyListeners();
  }

  Future<void> fetchReciters() async {
    _isLoadingReciters = true;
    notifyListeners();
    final list = await QuranDataService.fetchAllRecitersFromApi();
    _reciters = list;
    if (list.isNotEmpty) {
      setSelectedReciter(list.first);
    }
    _isLoadingReciters = false;
    notifyListeners();
  }

  Future<void> initLocationAndPrayers() async {
    _isLoadingPrayers = true;
    _locationError = '';
    _prayerTimes ??= PrayerTimesData.defaultTimes('موقعي');
    notifyListeners();
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
        final res = await QuranDataService.fetchPrayerTimes(pos.latitude, pos.longitude);
        if (res != null) {
          _prayerTimes = res;
        }
      } else {
        _locationError = 'تم إظهار مواقيت تقريبية (صلاحية الموقع غير ممنوحة)';
      }
    } catch (e) {
      _locationError = 'تعذر التحديد التلقائي للموقع';
    }
    _isLoadingPrayers = false;
    notifyListeners();
  }

  void _setupAudioListeners() {
    _audioPlayer.positionStream.listen((p) {
      _position = p;
      notifyListeners();
    });
    _audioPlayer.durationStream.listen((d) {
      _duration = d ?? Duration.zero;
      notifyListeners();
    });
    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      _isBuffering = state.processingState == ProcessingState.buffering;
      if (state.processingState == ProcessingState.completed) {
        _isPlaying = false;
        _position = Duration.zero;
      }
      notifyListeners();
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;

    final String? bookmarkJson = prefs.getString('bookmarks');
    if (bookmarkJson != null) {
      try {
        final List decoded = json.decode(bookmarkJson);
        _bookmarks = decoded.map((e) => Bookmark.fromJson(e)).toList();
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> _loadDownloadedSurahs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? downloadedJson = prefs.getString('downloaded_surahs');
    if (downloadedJson != null) {
      try {
        final List decoded = json.decode(downloadedJson);
        _downloadedSurahs = decoded.map((e) => DownloadedSurah.fromJson(e)).toList();
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> _saveDownloadedSurahs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'downloaded_surahs',
      json.encode(_downloadedSurahs.map((e) => e.toJson()).toList()),
    );
  }

  bool isDownloading(String reciterId, int surahId) =>
      _downloadingKeys.contains('${reciterId}_$surahId');

  double getDownloadProgress(String reciterId, int surahId) =>
      _downloadProgress['${reciterId}_$surahId'] ?? 0.0;

  bool isSurahDownloaded(String reciterId, int surahId) =>
      _downloadedSurahs.any((d) => d.reciterId == reciterId && d.surahId == surahId);

  DownloadedSurah? getDownloadedSurah(String reciterId, int surahId) {
    final idx = _downloadedSurahs.indexWhere((d) => d.reciterId == reciterId && d.surahId == surahId);
    return idx != -1 ? _downloadedSurahs[idx] : null;
  }

  Future<void> downloadSurah(Surah surah, Reciter reciter) async {
    if (kIsWeb) return;
    final key = '${reciter.id}_${surah.id}';
    if (isSurahDownloaded(reciter.id, surah.id) || _downloadingKeys.contains(key)) return;

    _downloadingKeys.add(key);
    _downloadProgress[key] = 0.0;
    notifyListeners();

    try {
      final url = QuranDataService.getAudioUrl(reciter, surah.id);
      final request = http.Request('GET', Uri.parse(url));
      final response = await http.Client().send(request);

      if (response.statusCode == 200) {
        final totalBytes = response.contentLength ?? 0;
        final List<int> bytes = [];
        int receivedBytes = 0;

        await for (var chunk in response.stream) {
          bytes.addAll(chunk);
          receivedBytes += chunk.length;
          if (totalBytes > 0) {
            _downloadProgress[key] = receivedBytes / totalBytes;
            notifyListeners();
          }
        }

        final dir = await getApplicationDocumentsDirectory();
        final filePath = '${dir.path}/quran_${reciter.id}_${surah.id}.mp3';
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        final item = DownloadedSurah(
          surahId: surah.id,
          surahName: surah.name,
          reciterId: reciter.id,
          reciterName: reciter.name,
          localPath: filePath,
          downloadedAt: DateTime.now(),
        );

        _downloadedSurahs.removeWhere((d) => d.key == key);
        _downloadedSurahs.add(item);
        await _saveDownloadedSurahs();
      }
    } catch (_) {
    } finally {
      _downloadingKeys.remove(key);
      _downloadProgress.remove(key);
      notifyListeners();
    }
  }

  Future<void> deleteDownloadedSurah(DownloadedSurah item) async {
    if (!kIsWeb) {
      try {
        final file = File(item.localPath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
    }
    _downloadedSurahs.removeWhere((d) => d.key == item.key);
    await _saveDownloadedSurahs();
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  void setSelectedReciter(Reciter reciter) {
    _selectedReciter = reciter;
    final available = availableSurahsForSelectedReciter;
    if (available.isNotEmpty && !available.any((s) => s.id == _selectedSurah.id)) {
      _selectedSurah = available.first;
    }
    notifyListeners();
  }

  void setSelectedSurah(Surah surah) {
    _selectedSurah = surah;
    notifyListeners();
  }

  Future<void> playCurrentSurah() async {
    _hasAudioStarted = true;
    _isBuffering = true;
    notifyListeners();
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      final downloaded = getDownloadedSurah(_selectedReciter.id, _selectedSurah.id);
      final source = !kIsWeb && downloaded != null && File(downloaded.localPath).existsSync()
          ? AudioSource.file(
              downloaded.localPath,
              tag: MediaItem(
                id: 'quran_${_selectedReciter.id}_${_selectedSurah.id}',
                title: 'سورة ${_selectedSurah.name}',
                artist: _selectedReciter.name,
                album: 'القرآن الكريم',
              ),
            )
          : AudioSource.uri(
              Uri.parse(QuranDataService.getAudioUrl(_selectedReciter, _selectedSurah.id)),
              tag: MediaItem(
                id: 'quran_${_selectedReciter.id}_${_selectedSurah.id}',
                title: 'سورة ${_selectedSurah.name}',
                artist: _selectedReciter.name,
                album: 'القرآن الكريم',
              ),
            );
      await _audioPlayer.setAudioSource(source);
      await _audioPlayer.play();
    } catch (e) {
      _isBuffering = false;
      notifyListeners();
    }
  }

  Future<void> playDownloadedSurahItem(DownloadedSurah item) async {
    final surah = QuranDataService.allSurahs.firstWhere(
      (s) => s.id == item.surahId,
      orElse: () => QuranDataService.allSurahs.first,
    );
    final reciter = _reciters.firstWhere(
      (r) => r.id == item.reciterId,
      orElse: () => Reciter(id: item.reciterId, name: item.reciterName, rewaya: 'المصحف المرتل', serverUrl: ''),
    );
    _selectedSurah = surah;
    _selectedReciter = reciter;
    _hasAudioStarted = true;
    _isBuffering = true;
    notifyListeners();

    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      final source = !kIsWeb && File(item.localPath).existsSync()
          ? AudioSource.file(
              item.localPath,
              tag: MediaItem(
                id: 'quran_${item.reciterId}_${item.surahId}',
                title: 'سورة ${item.surahName}',
                artist: item.reciterName,
                album: 'القرآن الكريم',
              ),
            )
          : AudioSource.uri(
              Uri.parse(QuranDataService.getAudioUrl(reciter, surah.id)),
              tag: MediaItem(
                id: 'quran_${item.reciterId}_${item.surahId}',
                title: 'سورة ${item.surahName}',
                artist: item.reciterName,
                album: 'القرآن الكريم',
              ),
            );
      await _audioPlayer.setAudioSource(source);
      await _audioPlayer.play();
    } catch (e) {
      _isBuffering = false;
      notifyListeners();
    }
  }

  Future<void> pauseAudio() async => await _audioPlayer.pause();
  Future<void> resumeAudio() async => await _audioPlayer.play();
  Future<void> seekAudio(Duration position) async =>
      await _audioPlayer.seek(position);

  Future<void> toggleBookmark(Bookmark bookmark) async {
    final index = _bookmarks.indexWhere((b) =>
        b.surahId == bookmark.surahId && b.verseNumber == bookmark.verseNumber);
    if (index >= 0) {
      _bookmarks.removeAt(index);
    } else {
      _bookmarks.add(bookmark);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'bookmarks', json.encode(_bookmarks.map((e) => e.toJson()).toList()));
    notifyListeners();
  }

  bool isBookmarked(int surahId, int verseNumber) =>
      _bookmarks.any((b) => b.surahId == surahId && b.verseNumber == verseNumber);

  @override
  void dispose() {
    _audioPlayer.dispose();
    _clockTimer?.cancel();
    super.dispose();
  }
}
