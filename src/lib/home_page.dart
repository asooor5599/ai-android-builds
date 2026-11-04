import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:app/prayer_logic.dart';
import 'package:app/theme_provider.dart';
import 'package:app/adhkar_page.dart';
import 'package:app/tasbih_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final times = PrayerCalculator.getTimes(_now);
    final next = PrayerCalculator.getNextPrayer(times);
    final diff = next.time.difference(_now);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('مواقيت الصلاة - الرياض'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(themeProvider.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCountdownCard(next, diff),
            const SizedBox(height: 10),
            _buildPrayerList(times),
            const SizedBox(height: 20),
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownCard(PrayerTime next, Duration diff) {
    String h = diff.inHours.toString().padLeft(2, '0');
    String m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    String s = (diff.inSeconds % 60).toString().padLeft(2, '0');

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.teal.shade700, Colors.teal.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Text('الصلاة القادمة: ${next.name}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('$h:$m:$s', style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: 2)),
            const Text('متبقي على الأذان', style: TextStyle(color: Colors.white70, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerList(List<PrayerTime> times) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: times.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final p = times[index];
        final timeStr = intl.DateFormat('hh:mm a', 'ar_SA').format(p.time);
        bool isNext = PrayerCalculator.getNextPrayer(times).name == p.name;
        
        return ListTile(
          leading: Icon(Icons.access_time, color: isNext ? Colors.teal : null),
          title: Text(p.name, style: TextStyle(fontWeight: isNext ? FontWeight.bold : FontWeight.normal, fontSize: 18)),
          trailing: Text(timeStr, style: TextStyle(fontSize: 18, color: isNext ? Colors.teal : null, fontWeight: isNext ? FontWeight.bold : FontWeight.normal)),
          tileColor: isNext ? Colors.teal.withValues(alpha: 0.1) : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _actionButton(context, 'الأذكار', Icons.menu_book, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdhkarPage()))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _actionButton(context, 'المسبحة', Icons.fingerprint, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TasbihPage()))),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}