import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/tasbih_provider.dart';
import 'package:app/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final provider = TasbihProvider();
  await provider.loadData();
  runApp(
    ChangeNotifierProvider(
      create: (_) => provider,
      child: const TasbihApp(),
    ),
  );
}

class TasbihApp extends StatelessWidget {
  const TasbihApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TasbihProvider>(
      builder: (context, provider, child) {
        return MaterialApp(
          title: 'المسبحة الإلكترونية',
          debugShowCheckedModeBanner: false,
          themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFF1B5E20),
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFF1B5E20),
            brightness: Brightness.dark,
          ),
          home: const Directionality(
            textDirection: TextDirection.rtl,
            child: HomePage(),
          ),
        );
      },
    );
  }
}