import 'package:flutter/material.dart';
import 'package:app/calculator_screen.dart';
import 'package:app/result_screen.dart';
import 'package:app/settings_screen.dart';
import 'package:app/hawl_screen.dart';
import 'package:app/history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  final List<Widget> _screens = [
    const CalculatorScreen(),
    const ResultScreen(),
    const HawlScreen(),
    const HistoryScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24, height: 24,
              decoration: const BoxDecoration(color: Color(0xFFFFD700), shape: BoxShape.circle),
              child: Center(child: Container(width: 8, height: 14, color: const Color(0xFF1B5E20))),
            ),
            const SizedBox(width: 10),
            const Text('زكاتي بالريال'),
          ],
        ),
      ),
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.calculate), label: 'الحاسبة'),
          NavigationDestination(icon: Icon(Icons.analytics), label: 'النتيجة'),
          NavigationDestination(icon: Icon(Icons.calendar_today), label: 'الحول'),
          NavigationDestination(icon: Icon(Icons.history), label: 'السجل'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'الإعدادات'),
        ],
      ),
    );
  }
}
