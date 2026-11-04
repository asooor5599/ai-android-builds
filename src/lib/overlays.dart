import 'package:flutter/material.dart';
import 'package:app/game.dart';

class MainMenuOverlay extends StatelessWidget {
  final RailDashGame game;
  const MainMenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('عدّاء السكة', style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text('أعلى رقم: ${game.highScore}', style: const TextStyle(color: Colors.amber, fontSize: 24)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: game.startGame,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15)),
              child: const Text('ابدأ اللعب', style: TextStyle(fontSize: 24)),
            ),
          ],
        ),
      ),
    );
  }
}

class GameOverOverlay extends StatelessWidget {
  final RailDashGame game;
  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('انتهت اللعبة', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text('النتيجة: ${game.score.toInt()}', style: const TextStyle(color: Colors.white, fontSize: 24)),
            Text('العملات: ${game.coins}', style: const TextStyle(color: Colors.amber, fontSize: 24)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: game.startGame,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

class PauseOverlay extends StatelessWidget {
  final RailDashGame game;
  const PauseOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('متوقف مؤقتاً', style: TextStyle(color: Colors.white, fontSize: 40)),
          IconButton(onPressed: game.togglePause, icon: const Icon(Icons.play_arrow, size: 80, color: Colors.white)),
        ],
      ),
    );
  }
}

class HUDOverlay extends StatelessWidget {
  final RailDashGame game;
  const HUDOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('النقاط: ${game.score.toInt()}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                Text('العملات: ${game.coins}', style: const TextStyle(color: Colors.amber, fontSize: 20)),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(onPressed: game.togglePause, icon: const Icon(Icons.pause, color: Colors.white, size: 32)),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: game.player.powerups.entries.map((e) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                padding: const EdgeInsets.all(8),
                color: Colors.black54,
                child: Text('${e.key}: ${e.value.toInt()}', style: const TextStyle(color: Colors.cyan, fontSize: 12)),
              )).toList(),
            ),
          )
        ],
      ),
    );
  }
}