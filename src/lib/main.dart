import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:app/home_page.dart';

void main() {
  runApp(const MoaziniApp());
}

class MoaziniApp extends StatelessWidget {
  const MoaziniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مؤذني',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [
        Locale('ar', 'SA'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF004D40),
          primary: const Color(0xFF004D40),
          secondary: const Color(0xFFD4AF37),
          surface: const Color(0xFF00332A),
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFF00251A),
        cardTheme: CardThemeData(
          color: const Color(0xFF004D40).withValues(alpha: 0.7),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      home: const HomePage(),
    );
  }
}