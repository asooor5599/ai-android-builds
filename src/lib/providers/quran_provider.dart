import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
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
  double _fontSize = 22.0;
  bool _isDarkMode = false;
  List<Bookmark> _bookmarks = [];
  List<DownloadedSurah> _downloadedSurahs = [];
  int _activeTabIndex = 0;

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
    _updateTime();
    _startClock();
    _loadSettings();
    _setupAudioListeners();
    fetchReciters();
    initLocationAndPrayers();
    fetchAzkarData();
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
            desiredAccuracy: LocationAccuracy.high);
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
    _audioPlayer.onPositionChanged.listen((p) {
      _position = p;
      if (_isBuffering && p > Duration.zero) _isBuffering = false;
      notifyListeners();
    });
    _audioPlayer.onDurationChanged.listen((d) {
      _duration = d;
      notifyListeners();
    });
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      if (state == PlayerState.completed) {
        _isPlaying = false;
        _position = Duration.zero;
      }
      notifyListeners();
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _fontSize = prefs.getDouble('fontSize') ?? 22.0;
    final String? bookmarkJson = prefs.getString('bookmarks');
    if (bookmarkJson != null) {
      try {
        final List decoded = json.decode(bookmarkJson);
        _bookmarks = decoded.map((e) => Bookmark.fromJson(e)).toList();
      } catch (_) {}
    }
    final String? downloadedJson = prefs.getString('downloaded_surahs');
    if (downloadedJson != null) {
      try {
        final List decoded = json.decode(downloadedJson);
        _downloadedSurahs = decoded.map((e) => DownloadedSurah.fromJson(e)).toList();
      } catch (_) {}
    }
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

  DownloadedSurah? getDownloadedSurah(int surahId, String reciterId) {
    final index = _downloadedSurahs.indexWhere(
      (item) => item.surahId == surahId && item.reciterId == reciterId,
    );
    if (index >= 0) {
      final item = _downloadedSurahs[index];
      if (File(item.localPath).existsSync()) {
        return item;
      }
    }
    return null;
  }

  bool isSurahDownloaded(int surahId, String reciterId) {
    return getDownloadedSurah(surahId, reciterId) != null;
  }

  Future<void> playCurrentSurah() async {
    _hasAudioStarted = true;
    _isBuffering = true;
    _isPlaying = false;
    notifyListeners();
    try {
      await _audioPlayer.stop();
      final downloaded = getDownloadedSurah(_selectedSurah.id, _selectedReciter.id);
      if (downloaded != null && File(downloaded.localPath).existsSync()) {
        await _audioPlayer.play(DeviceFileSource(downloaded.localPath));
      } else {
        final url =
            QuranDataService.getAudioUrl(_selectedReciter, _selectedSurah.id);
        await _audioPlayer.play(UrlSource(url));
      }
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
      orElse: () => Reciter(id: item.reciterId, name: item.reciterName, rewaya: '', serverUrl: ''),
    );
    _selectedSurah = surah;
    if (reciter.serverUrl.isNotEmpty) {
      _selectedReciter = reciter;
    }
    _hasAudioStarted = true;
    _isBuffering = true;
    _isPlaying = false;
    notifyListeners();
    try {
      await _audioPlayer.stop();
      if (File(item.localPath).existsSync()) {
        await _audioPlayer.play(DeviceFileSource(item.localPath));
      } else {
        final url = QuranDataService.getAudioUrl(_selectedReciter, _selectedSurah.id);
        await _audioPlayer.play(UrlSource(url));
      }
    } catch (e) {
      _isBuffering = false;
      notifyListeners();
    }
  }

  Future<void> downloadSurah(
    Surah surah,
    Reciter reciter,
    void Function(double progress, String status) onProgress,
  ) async {
    try {
      final url = QuranDataService.getAudioUrl(reciter, surah.id);
      final request = http.Request('GET', Uri.parse(url));
      final response = await http.Client().send(request);

      if (response.statusCode == 200) {
        final totalBytes = response.contentLength ?? 0;
        int receivedBytes = 0;
        final dir = await getApplicationDocumentsDirectory();
        final filePath = '${dir.path}/surah_${reciter.id}_${surah.id}.mp3';
        final file = File(filePath);
        final sink = file.openWrite();

        await for (final chunk in response.stream) {
          receivedBytes += chunk.length;
          sink.add(chunk);
          if (totalBytes > 0) {
            onProgress(
              receivedBytes / totalBytes,
              'جاري تحميل سورة ${surah.name}... ${(receivedBytes / totalBytes * 100).toStringAsFixed(0)}%',
            );
          } else {
            onProgress(0.5, 'جاري تحميل سورة ${surah.name}...');
          }
        }
        await sink.close();

        final newItem = DownloadedSurah(
          surahId: surah.id,
          surahName: surah.name,
          reciterId: reciter.id,
          reciterName: reciter.name,
          localPath: filePath,
          fileSizeMB: (receivedBytes / (1024 * 1024)).toStringAsFixed(1),
        );

        _downloadedSurahs.removeWhere(
          (item) => item.surahId == surah.id && item.reciterId == reciter.id,
        );
        _downloadedSurahs.add(newItem);
        await _saveDownloadedSurahsToPrefs();
        onProgress(1.0, 'تم تحميل سورة ${surah.name} بنجاح!');
        notifyListeners();
      } else {
        onProgress(-1, 'فشل التحميل: خطأ في الاستجابة من السيرفر');
      }
    } catch (e) {
      onProgress(-1, 'تعذر التحميل، يرجى التأكد من اتصال الإنترنت');
    }
  }

  Future<void> deleteDownloadedSurah(DownloadedSurah item) async {
    try {
      final file = File(item.localPath);
      if (file.existsSync()) {
        await file.delete();
      }
    } catch (_) {}
    _downloadedSurahs.removeWhere(
      (e) => e.surahId == item.surahId && e.reciterId == item.reciterId,
    );
    await _saveDownloadedSurahsToPrefs();
    notifyListeners();
  }

  Future<void> _saveDownloadedSurahsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _downloadedSurahs.map((e) => e.toJson()).toList();
    await prefs.setString('downloaded_surahs', json.encode(data));
  }

  Future<void> pauseAudio() async => await _audioPlayer.pause();
  Future<void> resumeAudio() async => await _audioPlayer.resume();
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
