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
        decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.deepPurple, width: 2)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('عدّاء السكة', style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
            const Text('RAIL DASH', style: TextStyle(color: Colors.deepPurpleAccent, fontSize: 16, letterSpacing: 4)),
            const SizedBox(height: 30),
            Text('أعلى رقم: ${game.highScore}', style: const TextStyle(color: Colors.amber, fontSize: 24)),
            Text('إجمالي العملات: ${game.totalCoins}', style: const TextStyle(color: Colors.white70, fontSize: 18)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: game.startGame,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20), textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              child: const Text('ابدأ اللعب'),
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
        decoration: BoxDecoration(color: Colors.red.shade900.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('انتهت اللعبة', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text('النتيجة: ${game.score.toInt()}', style: const TextStyle(color: Colors.white, fontSize: 28)),
            Text('العملات: ${game.coins}', style: const TextStyle(color: Colors.amber, fontSize: 24)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: game.startGame,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
              child: const Text('إعادة المحاولة', style: TextStyle(fontSize: 20)),
            ),
            TextButton(
              onPressed: () => game.overlays.add('MainMenu'),
              child: const Text('القائمة الرئيسية', style: TextStyle(color: Colors.white70)),
            )
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
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('متوقف مؤقتاً', style: TextStyle(color: Colors.white, fontSize: 40)),
            const SizedBox(height: 40),
            IconButton(
              onPressed: game.togglePause,
              icon: const Icon(Icons.play_circle_fill, size: 100, color: Colors.white),
            ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('النقاط: ${game.score.toInt()}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 4, color: Colors.black)])),
                Text('العملات: ${game.coins}', style: const TextStyle(color: Colors.amber, fontSize: 22, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 4, color: Colors.black)])),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              onPressed: game.togglePause,
              icon: const Icon(Icons.pause_circle_filled, color: Colors.white, size: 48),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Wrap(
              spacing: 10,
              children: game.player.powerups.entries.map((e) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.cyan)),
                child: Text('${_translate(e.key)}: ${e.value.toInt()}ث', style: const TextStyle(color: Colors.cyan, fontSize: 14, fontWeight: FontWeight.bold)),
              )).toList(),
            ),
          )
        ],
      ),
    );
  }

  String _translate(String key) {
    switch(key) {
      case 'magnet': return 'مغناطيس';
      case 'shield': return 'درع';
      case 'jetpack': return 'نفاثة';
      case 'jump': return 'قفز عالي';
      default: return key;
    }
  }
}