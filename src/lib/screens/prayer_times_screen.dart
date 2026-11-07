import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/quran_provider.dart';

class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen({super.key});

  String _formatTo12h(String? time24) {
    if (time24 == null) return '--:--';
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
    final data = provider.prayerTimes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('مواقيت الصلاة'),
        actions: [
          IconButton(icon: const Icon(Icons.my_location), onPressed: () => provider.initLocationAndPrayers()),
        ],
      ),
      body: provider.isLoadingPrayers
          ? const Center(child: CircularProgressIndicator())
          : data == null
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(provider.locationError.isEmpty ? 'يرجى تفعيل الموقع لجلب المواقيت' : provider.locationError), const SizedBox(height: 16), ElevatedButton(onPressed: () => provider.initLocationAndPrayers(), child: const Text('حاول مرة أخرى'))]))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildHeader(provider, data),
                    const SizedBox(height: 20),
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

  Widget _buildHeader(QuranProvider provider, dynamic data) {
    return Card(
      color: Colors.teal,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.location_on, color: Colors.white, size: 30),
            const SizedBox(height: 8),
            Text(data.cityArabic, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
              child: Text(provider.currentTime, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500, letterSpacing: 1.5)),
            ),
            const SizedBox(height: 8),
            Text(data.date, style: const TextStyle(color: Colors.white70)),
          ],
        ),
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
