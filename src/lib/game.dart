import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:app/components.dart';
import 'package:app/constants.dart';

class RailDashGame extends FlameGame with PanDetector, HasCollisionDetection {
  late Player player;
  late WorldManager world;
  double score = 0;
  int coins = 0;
  int totalCoins = 0;
  int highScore = 0;
  bool isPlaying = false;
  double gameSpeed = 1.0;
  
  late SharedPreferences _prefs;

  @override
  Future<void> onLoad() async {
    _prefs = await SharedPreferences.getInstance();
    highScore = _prefs.getInt('highScore') ?? 0;
    totalCoins = _prefs.getInt('totalCoins') ?? 0;
    
    player = Player();
    world = WorldManager();
    
    add(world);
    add(player);
  }

  void startGame() {
    score = 0;
    coins = 0;
    gameSpeed = 1.0;
    isPlaying = true;
    player.reset();
    world.reset();
    overlays.remove('MainMenu');
    overlays.remove('GameOver');
    overlays.add('HUD');
  }

  void gameOver() {
    isPlaying = false;
    if (score > highScore) {
      highScore = score.toInt();
      _prefs.setInt('highScore', highScore);
    }
    totalCoins += coins;
    _prefs.setInt('totalCoins', totalCoins);
    overlays.remove('HUD');
    overlays.add('GameOver');
    Vibration.vibrate(duration: 500);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isPlaying) return;
    
    gameSpeed += dt * 0.01;
    score += dt * 10 * gameSpeed;
  }

  @override
  void onPanEnd(DragEndInfo info) {
    if (!isPlaying) return;
    final velocity = info.velocity;
    if (velocity.x.abs() > velocity.y.abs()) {
      if (velocity.x > 0) player.moveLane(1);
      else player.moveLane(-1);
    } else {
      if (velocity.y < 0) player.jump();
      else player.slide();
    }
  }

  void togglePause() {
    if (overlays.isActive('Pause')) {
      overlays.remove('Pause');
      resumeEngine();
    } else {
      overlays.add('Pause');
      pauseEngine();
    }
  }
}