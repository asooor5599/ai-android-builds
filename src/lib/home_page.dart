import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app/models.dart';
import 'package:app/prayer_service.dart';
import 'package:intl/intl.dart' as intl;
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PrayerService _service = PrayerService();
  PrayerTimes? _prayerTimes;
  String _cityName = 'جاري التحميل...';
  Timer? _timer;
  String _nextPrayerName = '';
  Duration _timeUntilNext = Duration.zero;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _initData();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initData() async {
    Position? pos = await _service.getCurrentLocation();
    if (pos != null) {
      final times = await _service.fetchPrayerTimes(pos);
      final city = await _service.getCityName(pos);
      if (mounted) {
        setState(() {
          _prayerTimes = times;
          _cityName = city;
        });
        _updateCountdown();
      }
    }
  }

  void _updateCountdown() {
    if (_prayerTimes == null) return;

    final now = DateTime.now();
    final timesMap = _prayerTimes!.toMap();
    DateTime? nextTime;
    String nextName = '';

    List<String> keys = timesMap.keys.toList();
    for (String key in keys) {
      final timeParts = timesMap[key]!.split(':');
      final prayerTime = DateTime(now.year, now.month, now.day, int.parse(timeParts[0]), int.parse(timeParts[1]));
      
      if (prayerTime.isAfter(now)) {
        nextTime = prayerTime;
        nextName = key;
        break;
      }
    }

    if (nextTime == null) {
      final timeParts = timesMap['الفجر']!.split(':');
      nextTime = DateTime(now.year, now.month, now.day + 1, int.parse(timeParts[0]), int.parse(timeParts[1]));
      nextName = 'الفجر';
    }

    if (mounted) {
      setState(() {
        _nextPrayerName = nextName;
        _timeUntilNext = nextTime!.difference(now);
        // Simple progress calculation (assuming 4 hours average between prayers for visual)
        _progress = 1.0 - (_timeUntilNext.inSeconds / (4 * 3600)).clamp(0.0, 1.0);
      });
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _prayerTimes == null
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
            : RefreshIndicator(
                onRefresh: _initData,
                color: const Color(0xFFD4AF37),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 30),
                        _buildCountdownCircle(),
                        const SizedBox(height: 40),
                        _buildPrayerList(),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.location_on, color: Color(0xFFD4AF37)),
            Text(_cityName, style: Theme.of(context).textTheme.titleLarge),
            const Icon(Icons.settings, color: Colors.white70),
          ],
        ),
        const SizedBox(height: 8),
        Text(_prayerTimes!.hijriDate, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 18)),
        Text(_prayerTimes!.gregorianDate, style: const TextStyle(color: Colors.white60, fontSize: 14)),
      ],
    );
  }

  Widget _buildCountdownCircle() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 220,
          height: 220,
          child: CircularProgressIndicator(
            value: _progress,
            strokeWidth: 12,
            backgroundColor: Colors.white10,
            color: const Color(0xFFD4AF37),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('الصلاة القادمة: $_nextPrayerName', style: const TextStyle(fontSize: 16, color: Colors.white70)),
            const SizedBox(height: 8),
            Text(_formatDuration(_timeUntilNext), style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ],
    );
  }

  Widget _buildPrayerList() {
    final times = _prayerTimes!.toMap();
    return Column(
      children: times.entries.map((entry) {
        bool isNext = entry.key == _nextPrayerName;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isNext ? const Color(0xFFD4AF37).withValues(alpha: 0.2) : const Color(0xFF004D40).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isNext ? const Color(0xFFD4AF37) : Colors.transparent, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(entry.key, style: TextStyle(fontSize: 18, fontWeight: isNext ? FontWeight.bold : FontWeight.normal, color: isNext ? const Color(0xFFD4AF37) : Colors.white)),
              Text(entry.value, style: TextStyle(fontSize: 18, fontWeight: isNext ? FontWeight.bold : FontWeight.normal, color: isNext ? const Color(0xFFD4AF37) : Colors.white)),
            ],
          ),
        );
      }).toList(),
    );
  }
}