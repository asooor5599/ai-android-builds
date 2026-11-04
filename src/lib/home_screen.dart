import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/app_state.dart';
import 'package:app/qibla_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AppState>().init());
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Noor Prayer', style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: const Icon(Icons.explore_outlined),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QiblaScreen()),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => state.init(),
              ),
            ],
          ),
          if (state.isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (state.errorMessage != null)
            SliverFillRemaining(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                    const SizedBox(height: 16),
                    Text(state.errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    FilledButton(onPressed: () => state.init(), child: const Text('Retry')),
                  ],
                ),
              ),
            )
          else if (state.prayerTimes != null)
            SliverList(
              delegate: SliverChildListDelegate([
                _NextPrayerCard(state: state),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text('Daily Timings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                _PrayerTile(name: 'Fajr', time: state.prayerTimes!.fajr, icon: Icons.wb_twilight),
                _PrayerTile(name: 'Dhuhr', time: state.prayerTimes!.dhuhr, icon: Icons.wb_sunny),
                _PrayerTile(name: 'Asr', time: state.prayerTimes!.asr, icon: Icons.wb_sunny_outlined),
                _PrayerTile(name: 'Maghrib', time: state.prayerTimes!.maghrib, icon: Icons.dark_mode_outlined),
                _PrayerTile(name: 'Isha', time: state.prayerTimes!.isha, icon: Icons.dark_mode),
                const SizedBox(height: 40),
              ]),
            ),
        ],
      ),
    );
  }
}

class _NextPrayerCard extends StatelessWidget {
  final AppState state;
  const _NextPrayerCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final next = state.getNextPrayer();
    if (next == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal, Colors.teal.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Next Prayer', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 16)),
          const SizedBox(height: 4),
          Text(next['name'], style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Text(
                DateFormat('hh:mm a').format(next['time']),
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrayerTile extends StatelessWidget {
  final String name;
  final String time;
  final IconData icon;

  const _PrayerTile({required this.name, required this.time, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          ),
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
          trailing: Text(time, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}