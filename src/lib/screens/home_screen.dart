import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:app/services/prayer_service.dart';
import 'package:app/models/app_models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;
  Duration _timeUntilNext = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final service = Provider.of<PrayerService>(context, listen: false);
      final next = service.getNextPrayer();
      if (next != null) {
        final now = DateTime.now();
        final diff = next.time.difference(now);
        if (mounted) {
          setState(() {
            _timeUntilNext = diff.isNegative ? Duration.zero : diff;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<PrayerService>(context);
    final nextPrayer = service.getNextPrayer();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'مواقيت الصلاة',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
            onPressed: () => service.fetchPrayerTimes(),
          ),
        ],
      ),
      body: service.isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('جاري تحميل مواقيت الصلاة...'),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () => service.fetchPrayerTimes(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      color: theme.colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Icon(Icons.location_on, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${service.currentLocation.name} - ${service.currentLocation.country}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                            Text(
                              '(${service.currentLocation.latitude.toStringAsFixed(2)}°, ${service.currentLocation.longitude.toStringAsFixed(2)}°)',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (nextPrayer != null) ...[
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              'الصلاة القادمة',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              nextPrayer.arabicName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                _formatDuration(_timeUntilNext),
                                style: const TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'الموعد: ${intl.DateFormat('hh:mm a').format(nextPrayer.time)}',
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (service.prayerData != null) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  const Text('التاريخ الهجري', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  const SizedBox(height: 2),
                                  Text(
                                    service.prayerData!.hijriDate,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ],
                              ),
                              Container(height: 30, width: 1, color: Colors.grey.withValues(alpha: 0.3)),
                              Column(
                                children: [
                                  const Text('التاريخ الميلادي', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  const SizedBox(height: 2),
                                  Text(
                                    service.prayerData!.gregorianDate,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    const Text(
                      'مواقيت صلاة اليوم',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...service.todayPrayers.map((prayer) {
                      final isNext = nextPrayer?.name == prayer.name;
                      final isSunrise = prayer.name == 'Sunrise';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: isNext
                            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
                            : null,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isNext
                                ? theme.colorScheme.primary
                                : theme.colorScheme.surfaceContainerHighest,
                            foregroundColor: isNext ? Colors.white : theme.colorScheme.onSurface,
                            child: Icon(_getPrayerIcon(prayer.name)),
                          ),
                          title: Text(
                            prayer.arabicName,
                            style: TextStyle(
                              fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: isSunrise ? const Text('وقت الشروق') : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                intl.DateFormat('hh:mm a').format(prayer.time),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isNext ? theme.colorScheme.primary : null,
                                ),
                              ),
                              if (!isSunrise) ...[
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(
                                    prayer.isCompleted
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: prayer.isCompleted ? Colors.green : Colors.grey,
                                  ),
                                  onPressed: () {
                                    service.togglePrayerCompleted(prayer.name);
                                  },
                                  tooltip: prayer.isCompleted ? 'تمت الصلاة' : 'تحديد كتمت',
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
    );
  }

  IconData _getPrayerIcon(String name) {
    switch (name) {
      case 'Fajr':
        return Icons.wb_twilight;
      case 'Sunrise':
        return Icons.wb_sunny_outlined;
      case 'Dhuhr':
        return Icons.wb_sunny;
      case 'Asr':
        return Icons.wb_cloudy;
      case 'Maghrib':
        return Icons.wb_twilight_sharp;
      case 'Isha':
        return Icons.nights_stay;
      default:
        return Icons.access_time;
    }
  }
}