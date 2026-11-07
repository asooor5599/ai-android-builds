import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/quran_provider.dart';
import 'package:app/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => QuranProvider()..init(),
      child: const QuranApp(),
    ),
  );
}

class QuranApp extends StatelessWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QuranProvider>(
      builder: (context, provider, child) {
        return MaterialApp(
          title: 'القرآن الكريم',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.teal,
            brightness: provider.isDarkMode ? Brightness.dark : Brightness.light,
            fontFamily: 'sans-serif',
          ),
          locale: const Locale('ar', 'SA'),
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: child!,
            );
          },
          home: const HomeScreen(),
        );
      },
    );
  }
}