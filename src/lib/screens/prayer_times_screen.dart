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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuranProvider>(context);
    final data = provider.prayerTimes ?? PrayerTimesData.defaultTimes('موقعي');

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
            icon: const Icon(Icons.my_location),
            onPressed: () => provider.initLocationAndPrayers(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildClockHeader(provider, data),
          const SizedBox(height: 16),
          _buildTimeCard('الفجر', _formatTo12h(data.timings['Fajr']), Icons.wb_twilight),
          _buildTimeCard('الشروق', _formatTo12h(data.timings['Sunrise']), Icons.wb_sunny_outlined),
          _buildTimeCard('الظهر', _formatTo12h(data.timings['Dhuhr']), Icons.wb_sunny),
          _buildTimeCard('العصر', _formatTo12h(data.timings['Asr']), Icons.cloud_queue),
          _buildTimeCard('المغرب', _formatTo12h(data.timings['Maghrib']), Icons.nights_stay_outlined),
          _buildTimeCard('العشاء', _formatTo12h(data.timings['Isha']), Icons.nights_stay),
        ],
      ),
    );
  }

  Widget _buildClockHeader(QuranProvider provider, PrayerTimesData data) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade700, Colors.teal.shade900],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        children: [
          Text(data.cityArabic, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          Text(provider.currentTime, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('التاريخ: ${data.date}', style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildTimeCard(String name, String time, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(time, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
      ),
    );
  }
}
