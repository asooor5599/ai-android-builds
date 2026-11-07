import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/quran_provider.dart';
import 'package:app/screens/main_navigation_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
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
          locale: const Locale('ar', 'SA'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ar', 'SA')],
          themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.teal,
            brightness: Brightness.light,
            fontFamily: 'sans-serif',
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.teal,
            brightness: Brightness.dark,
            fontFamily: 'sans-serif',
          ),
          home: const MainNavigationScreen(),
        );
      },
    );
  }
}