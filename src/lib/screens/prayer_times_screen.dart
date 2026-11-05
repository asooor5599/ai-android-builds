import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/quran_provider.dart';

class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen({super.key});

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
                    _buildHeader(data),
                    const SizedBox(height: 20),
                    _buildTimeCard('الفجر', data.timings['Fajr']!, Icons.wb_twilight),
                    _buildTimeCard('الشروق', data.timings['Sunrise']!, Icons.wb_sunny_outlined),
                    _buildTimeCard('الظهر', data.timings['Dhuhr']!, Icons.wb_sunny),
                    _buildTimeCard('العصر', data.timings['Asr']!, Icons.cloud_queue),
                    _buildTimeCard('المغرب', data.timings['Maghrib']!, Icons.nights_stay_outlined),
                    _buildTimeCard('العشاء', data.timings['Isha']!, Icons.nights_stay),
                  ],
                ),
    );
  }

  Widget _buildHeader(dynamic data) {
    return Card(
      color: Colors.teal,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.location_on, color: Colors.white, size: 30),
            const SizedBox(height: 8),
            Text(data.city, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
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
