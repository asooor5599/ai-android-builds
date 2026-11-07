import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/quran_provider.dart';

class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuranProvider>(context);
    final times = provider.prayerTimes?.timings ?? {};
    final labels = {'Fajr': 'الفجر', 'Sunrise': 'الشروق', 'Dhuhr': 'الظهر', 'Asr': 'العصر', 'Maghrib': 'المغرب', 'Isha': 'العشاء'};

    return Scaffold(
      appBar: AppBar(title: const Text('مواقيت الصلاة')),
      body: provider.isLoadingPrayers
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  color: Colors.teal.withOpacity(0.1),
                  child: Column(
                    children: [
                      Text(provider.currentTime, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.teal)),
                      Text(provider.prayerTimes?.date ?? '', style: const TextStyle(color: Colors.grey)),
                      if (provider.locationError.isNotEmpty) Text(provider.locationError, style: const TextStyle(color: Colors.red, fontSize: 12)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(padding: const EdgeInsets.all(16), children: labels.entries.map((e) => Card(child: ListTile(title: Text(e.value), trailing: Text(times[e.key] ?? '--:--', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))))).toList()),
                ),
              ],
            ),
    );
  }
}