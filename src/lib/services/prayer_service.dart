import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/models/app_models.dart';

class PrayerService extends ChangeNotifier {
  CityLocation _currentLocation = CityLocation.presets[0];
  CalculationMethod _method = CalculationMethod.ummAlQura;
  PrayerData? _prayerData;
  List<PrayerTiming> _todayPrayers = [];
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, bool> _completedPrayers = {};

  CityLocation get currentLocation => _currentLocation;
  CalculationMethod get method => _method;
  PrayerData? get prayerData => _prayerData;
  List<PrayerTiming> get todayPrayers => _todayPrayers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get qiblaAngle => CalculationUtils.calculateQiblaDegree(
        _currentLocation.latitude,
        _currentLocation.longitude,
      );

  Future<void> init() async {
    await _loadPreferences();
    await fetchPrayerTimes();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('lat');
    final lng = prefs.getDouble('lng');
    final name = prefs.getString('location_name');
    final country = prefs.getString('location_country');
    final methodId = prefs.getInt('method_id') ?? 4;

    if (lat != null && lng != null && name != null) {
      _currentLocation = CityLocation(
        name: name,
        country: country ?? '',
        latitude: lat,
        longitude: lng,
      );
    }

    _method = CalculationMethod.fromId(methodId);

    final todayStr = DateTime.now().toString().split(' ')[0];
    final savedCompleted = prefs.getStringList('completed_$todayStr') ?? [];
    _completedPrayers = {for (var p in savedCompleted) p: true};
  }

  Future<void> updateLocation(CityLocation location) async {
    _currentLocation = location;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('lat', location.latitude);
    await prefs.setDouble('lng', location.longitude);
    await prefs.setString('location_name', location.name);
    await prefs.setString('location_country', location.country);

    notifyListeners();
    await fetchPrayerTimes();
  }

  Future<void> setMethod(CalculationMethod method) async {
    _method = method;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('method_id', method.id);
    notifyListeners();
    await fetchPrayerTimes();
  }

  Future<void> fetchPrayerTimes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final now = DateTime.now();
    final dateStr = "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";

    final url = Uri.parse(
      'https://api.aladhan.com/v1/timings/$dateStr?latitude=${_currentLocation.latitude}&longitude=${_currentLocation.longitude}&method=${_method.id}',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final timings = Map<String, String>.from(data['data']['timings']);
        final hijri = data['data']['date']['hijri'];
        final hijriFormatted = "${hijri['day']} ${hijri['month']['ar']} ${hijri['year']} هـ";
        final gregorianFormatted = data['data']['date']['readable'];

        _prayerData = PrayerData(
          rawTimings: timings,
          hijriDate: hijriFormatted,
          gregorianDate: gregorianFormatted,
        );

        _parsePrayerList(timings);
        _errorMessage = null;
      } else {
        _fallbackOfflineTimes();
      }
    } catch (e) {
      _fallbackOfflineTimes();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _fallbackOfflineTimes() {
    final now = DateTime.now();
    final dateStr = "${now.day}/${now.month}/${now.year}";
    
    final fallbackTimings = {
      'Fajr': '04:45',
      'Sunrise': '06:10',
      'Dhuhr': '12:15',
      'Asr': '15:30',
      'Maghrib': '18:10',
      'Isha': '19:40',
    };

    _prayerData = PrayerData(
      rawTimings: fallbackTimings,
      hijriDate: 'تاريخ هجري (غير متصل)',
      gregorianDate: dateStr,
    );

    _parsePrayerList(fallbackTimings);
  }

  void _parsePrayerList(Map<String, String> timings) {
    final now = DateTime.now();
    final prayers = [
      {'key': 'Fajr', 'ar': 'الفجر'},
      {'key': 'Sunrise', 'ar': 'الشروق'},
      {'key': 'Dhuhr', 'ar': 'الظهر'},
      {'key': 'Asr', 'ar': 'العصر'},
      {'key': 'Maghrib', 'ar': 'المغرب'},
      {'key': 'Isha', 'ar': 'العشاء'},
    ];

    _todayPrayers = prayers.map((p) {
      final key = p['key']!;
      final timeStr = timings[key] ?? '00:00';
      final parts = timeStr.split(' ')[0].split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final prayerDateTime = DateTime(now.year, now.month, now.day, hour, minute);
      final isDone = _completedPrayers[key] ?? false;

      return PrayerTiming(
        name: key,
        arabicName: p['ar']!,
        time: prayerDateTime,
        isCompleted: isDone,
      );
    }).toList();
  }

  Future<void> togglePrayerCompleted(String prayerKey) async {
    final index = _todayPrayers.indexWhere((p) => p.name == prayerKey);
    if (index != -1) {
      final newStatus = !_todayPrayers[index].isCompleted;
      _todayPrayers[index] = _todayPrayers[index].copyWith(isCompleted: newStatus);
      _completedPrayers[prayerKey] = newStatus;

      final prefs = await SharedPreferences.getInstance();
      final todayStr = DateTime.now().toString().split(' ')[0];
      final activeList = _completedPrayers.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

      await prefs.setStringList('completed_$todayStr', activeList);
      notifyListeners();
    }
  }

  PrayerTiming? getNextPrayer() {
    if (_todayPrayers.isEmpty) return null;
    final now = DateTime.now();

    for (var prayer in _todayPrayers) {
      if (prayer.name != 'Sunrise' && prayer.time.isAfter(now)) {
        return prayer;
      }
    }

    final fajr = _todayPrayers.firstWhere((p) => p.name == 'Fajr', orElse: () => _todayPrayers.first);
    final tomorrowFajr = fajr.time.add(const Duration(days: 1));
    return PrayerTiming(
      name: fajr.name,
      arabicName: fajr.arabicName,
      time: tomorrowFajr,
      isCompleted: false,
    );
  }
}

class CalculationMethod {
  final int id;
  final String name;

  const CalculationMethod(this.id, this.name);

  static const ummAlQura = CalculationMethod(4, 'جامعة أم القرى (مكة)');
  static const mwl = CalculationMethod(3, 'رابطة العالم الإسلامي');
  static const egyptian = CalculationMethod(5, 'الهيئة المصرية العامة للمساحة');
  static const karachi = CalculationMethod(1, 'جامعة العلوم الإسلامية بكراتشي');
  static const isna = CalculationMethod(2, 'الجمعية الإسلامية لشمال أمريكا');

  static const List<CalculationMethod> all = [
    ummAlQura,
    mwl,
    egyptian,
    karachi,
    isna,
  ];

  static CalculationMethod fromId(int id) {
    return all.firstWhere((m) => m.id == id, orElse: () => ummAlQura);
  }
}