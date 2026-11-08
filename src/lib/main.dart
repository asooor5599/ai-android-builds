import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/services/chat_service.dart';
import 'package:app/screens/chats_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final chatService = ChatService();
  await chatService.init();

  runApp(
    ChangeNotifierProvider.value(
      value: chatService,
      child: const TelegramApp(),
    ),
  );
}

class TelegramApp extends StatelessWidget {
  const TelegramApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تلغرام',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', ''),
      supportedLocales: const [
        Locale('ar', ''),
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox(),
        );
      },
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0E1621),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2AABEE),
          surface: Color(0xFF242F3D),
          onSurface: Colors.white,
          secondary: Color(0xFF64B5F6),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF242F3D),
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF17212B),
          elevation: 0,
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: Color(0xFF17212B),
          surfaceTintColor: Colors.transparent,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Color(0xFF17212B),
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: Color(0xFF17212B),
        ),
      ),
      home: const ChatsScreen(),
    );
  }
}
