import 'package:flutter/material.dart';
import 'package:app/tasbih_screen.dart';
import 'package:app/adhkar_screens.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const TasbihScreen(),
    const AdhkarListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.fingerprint),
            label: 'المسبحة',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book),
            label: 'الأذكار',
          ),
        ],
      ),
    );
  }
}