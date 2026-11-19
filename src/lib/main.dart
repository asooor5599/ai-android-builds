import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:app/providers/quran_provider.dart';
import 'package:app/screens/splash_verse_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryan.quran.channel.audio',
    androidNotificationChannelName: 'Quran Audio Playback',
    androidNotificationOngoing: true,
  );
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
          title: 'تطبيق القرآن الكريم',
          debugShowCheckedModeBanner: false,
          locale: const Locale('ar', 'SA'),
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: child!,
            );
          },
          themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.teal,
            fontFamily: 'Tajawal',
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF8F9FA),
            cardTheme: CardThemeData(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.teal,
            fontFamily: 'Tajawal',
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121816),
            cardTheme: CardThemeData(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            appBarTheme: AppBarTheme(
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.teal.shade900,
              foregroundColor: Colors.white,
            ),
          ),
          home: const SplashVerseScreen(),
        );
      },
    );
  }
}
