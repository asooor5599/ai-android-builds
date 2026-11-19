import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/quran_provider.dart';
import 'package:app/screens/main_navigation_screen.dart';

class SplashVerseScreen extends StatefulWidget {
  const SplashVerseScreen({super.key});

  @override
  State<SplashVerseScreen> createState() => _SplashVerseScreenState();
}

class _SplashVerseScreenState extends State<SplashVerseScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainNavigationScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuranProvider>(context, listen: false);
    final verse = provider.dailyVerse;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.teal.shade800, Colors.teal.shade400], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_stories, color: Colors.white70, size: 60),
                const SizedBox(height: 30),
                Text('« ${verse['text']} »', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.6, fontFamily: 'Amiri')),
                const SizedBox(height: 20),
                Text('[ ${verse['surah']} ]', style: const TextStyle(color: Colors.white70, fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
