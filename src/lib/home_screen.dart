import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/app_state.dart';
import 'package:app/qibla_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Noor Prayer Times'),
        actions: [
          IconButton(
            icon: const Icon(Icons.explore),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QiblaScreen()),
            ),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => state.init(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => state.init(),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (state.prayerTimes != null) ...[
                        _DateHeader(date: state.prayerTimes!.date),
                        const SizedBox(height: 20),
                        _PrayerCard(name: 'Fajr', time: state.prayerTimes!.fajr, icon: Icons.wb_twilight),
                        _PrayerCard(name: 'Dhuhr', time: state.prayerTimes!.dhuhr, icon: Icons.wb_sunny),
                        _PrayerCard(name: 'Asr', time: state.prayerTimes!.asr, icon: Icons.wb_sunny_outlined),
                        _PrayerCard(name: 'Maghrib', time: state.prayerTimes!.maghrib, icon: Icons.dark_mode_outlined),
                        _PrayerCard(name: 'Isha', time: state.prayerTimes!.isha, icon: Icons.dark_mode),
                      ],
                    ],
                  ),
                ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  final String date;
  const _DateHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('Today\'s Prayer Times', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(date, style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.7))),
        ],
      ),
    );
  }
}

class _PrayerCard extends StatelessWidget {
  final String name;
  final String time;
  final IconData icon;

  const _PrayerCard({required this.name, required this.time, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Text(time, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}