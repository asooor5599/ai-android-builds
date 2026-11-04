import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:app/game.dart';
import 'package:app/overlays.dart';

void main() {
  runApp(const RailDashApp());
}

class RailDashApp extends StatelessWidget {
  const RailDashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rail Dash',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: GameScreen(),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final RailDashGame _game;

  @override
  void initState() {
    super.initState();
    _game = RailDashGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: _game,
        overlayBuilderMap: {
          'MainMenu': (context, RailDashGame game) => MainMenuOverlay(game: game),
          'GameOver': (context, RailDashGame game) => GameOverOverlay(game: game),
          'Pause': (context, RailDashGame game) => PauseOverlay(game: game),
          'HUD': (context, RailDashGame game) => HUDOverlay(game: game),
        },
        initialActiveOverlays: const ['MainMenu'],
      ),
    );
  }
}