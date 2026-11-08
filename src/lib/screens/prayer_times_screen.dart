import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/quran_provider.dart';
import 'package:app/models/quran_models.dart';
import 'package:app/screens/main_navigation_screen.dart';

class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen({super.key});

  String _formatTo12h(String? time24) {
    if (time24 == null || time24.isEmpty) return '--:--';
    try {
      final parts = time24.split(':');
      int hour = int.parse(parts[0]);
      final minute = parts[1].split(' ')[0];
      final period = hour >= 12 ? 'م' : 'ص';
      hour = hour % 12;
      if (hour == 0) hour = 12;
      return '${hour.toString().padLeft(2, '0')}:$minute $period';
    } catch (e) {
      return time24;
    }
  }

  String _getNextPrayerName(Map<String, String> timings) {
    final now = DateTime.now();
    final prayers = [
      {'name': 'الفجر', 'key': 'Fajr'},
      {'name': 'الشروق', 'key': 'Sunrise'},
      {'name': 'الظهر', 'key': 'Dhuhr'},
      {'name': 'العصر', 'key': 'Asr'},
      {'name': 'المغرب', 'key': 'Maghrib'},
      {'name': 'العشاء', 'key': 'Isha'},
    ];

    for (var p in prayers) {
      final timeStr = timings[p['key']];
      if (timeStr != null) {
        try {
          final parts = timeStr.split(':');
          final h = int.parse(parts[0]);
          final m = int.parse(parts[1].split(' ')[0]);
          final pTime = DateTime(now.year, now.month, now.day, h, m);
          if (pTime.isAfter(now)) {
            return p['name']!;
          }
        } catch (_) {}
      }
    }
    return 'الفجر';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuranProvider>(context);
    final data = provider.prayerTimes ?? PrayerTimesData.defaultTimes('موقعي');
    final nextPrayer = _getNextPrayerName(data.timings);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLogoIcon(size: 24),
            SizedBox(width: 8),
            Text('مواقيت الصلاة'),
          ],
        ),
        actions: [
          IconButton(
            icon: provider.isLoadingPrayers
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
            tooltip: 'تحديث الموقع',
            onPressed: provider.isLoadingPrayers ? null : () => provider.initLocationAndPrayers(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.initLocationAndPrayers(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildClockHeader(context, provider, data, nextPrayer),
            const SizedBox(height: 16),
            if (provider.locationError.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.amber),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        provider.locationError,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    TextButton(
                      onPressed: () => provider.initLocationAndPrayers(),
                      child: const Text('تحديث'),
                    ),
                  ],
                ),
              ),
            _buildTimeCard('الفجر', _formatTo12h(data.timings['Fajr']), Icons.wb_twilight, nextPrayer == 'الفجر'),
            _buildTimeCard('الشروق', _formatTo12h(data.timings['Sunrise']), Icons.wb_sunny_outlined, nextPrayer == 'الشروق'),
            _buildTimeCard('الظهر', _formatTo12h(data.timings['Dhuhr']), Icons.wb_sunny, nextPrayer == 'الظهر'),
            _buildTimeCard('العصر', _formatTo12h(data.timings['Asr']), Icons.cloud_queue, nextPrayer == 'العصر'),
            _buildTimeCard('المغرب', _formatTo12h(data.timings['Maghrib']), Icons.nights_stay_outlined, nextPrayer == 'المغرب'),
            _buildTimeCard('العشاء', _formatTo12h(data.timings['Isha']), Icons.nights_stay, nextPrayer == 'العشاء'),
          ],
        ),
      ),
    );
  }

  Widget _buildClockHeader(BuildContext context, QuranProvider provider, PrayerTimesData data, String nextPrayer) {
    final timeDisplay = provider.currentTime.isEmpty ? '00:00:00' : provider.currentTime;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade700, Colors.teal.shade900],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, color: Colors.amber, size: 20),
              const SizedBox(width: 6),
              Text(
                data.cityArabic,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.5), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time_filled, color: Colors.amber, size: 28),
                const SizedBox(width: 10),
                Text(
                  timeDisplay,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'التاريخ: ${data.date}',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'الصلاة القادمة: $nextPrayer',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard(String name, String time, IconData icon, bool isNext) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: isNext ? Colors.teal.withValues(alpha: 0.15) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isNext ? const BorderSide(color: Colors.teal, width: 2) : BorderSide.none,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isNext ? Colors.teal : Colors.teal.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isNext ? Colors.white : Colors.teal, size: 22),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
            fontSize: 16,
            color: isNext ? Colors.teal : null,
          ),
        ),
        trailing: Text(
          time,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isNext ? Colors.teal : null,
          ),
        ),
      ),
    );
  }
}
