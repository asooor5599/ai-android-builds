import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:app/player_screen.dart';
import 'package:app/notifications_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (!kIsWeb) {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.shuraim.quran.audio',
      androidNotificationChannelName: 'Audio Playback',
      androidNotificationOngoing: true,
    );
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Riyadh'));
    await NotificationService.init();
  }

  runApp(const ShuraimApp());
}

class ShuraimApp extends StatelessWidget {
  const ShuraimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مصحف الشريم',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          primary: Colors.green[800],
          secondary: Colors.green[600],
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [Locale('ar', 'SA')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const PlayerScreen(),
    );
  }
}