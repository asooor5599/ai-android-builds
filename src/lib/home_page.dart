import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:app/prayer_logic.dart';
import 'package:app/theme_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Timer _timer;
  DateTime _now = DateTime.now();
  List<PrayerTime> _times = [];

  @override
  void initState() {
    super.initState();
    _times = PrayerCalculator.getTimes(_now);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
          if (_now.hour == 0 && _now.minute == 0 && _now.second == 0) {
            _times = PrayerCalculator.getTimes(_now);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  PrayerTime getNextPrayer() {
    for (var pt in _times) {
      if (pt.time.isAfter(_now)) return pt;
    }
    // If all passed, next is tomorrow's Fajr
    return PrayerCalculator.getTimes(_now.add(const Duration(days: 1)))[0];
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    final next = getNextPrayer();
    final diff = next.time.difference(_now);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('مواقيت الصلاة - الرياض'),
        actions: [
          IconButton(
            icon: Icon(themeProvider.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Column(
              children: [
                Text('الصلاة القادمة: ${next.name}', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  _formatDuration(diff),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  intl.DateFormat('EEEE, d MMMM', 'ar_SA').format(_now),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _times.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final pt = _times[index];
                final isNext = pt.name == next.name && pt.time.day == next.time.day;
                return ListTile(
                  leading: Icon(isNext ? Icons.notifications_active : Icons.notifications_none, 
                    color: isNext ? Theme.of(context).colorScheme.primary : null),
                  title: Text(pt.name, style: TextStyle(fontWeight: isNext ? FontWeight.bold : FontWeight.normal)),
                  trailing: Text(
                    intl.DateFormat.jm('ar_SA').format(pt.time),
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
                      color: isNext ? Theme.of(context).colorScheme.primary : null
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}