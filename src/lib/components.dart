import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:app/game.dart';
import 'package:app/constants.dart';

class Player extends PositionComponent with HasGameRef<RailDashGame> {
  int lane = 0;
  double visualLane = 0;
  double yOffset = 0;
  double jumpVelocity = 0;
  bool isSliding = false;
  double slideTimer = 0;
  int stumbleCount = 0;
  double stumbleTimer = 0;
  
  Map<String, double> powerups = {};

  void reset() {
    lane = 0;
    visualLane = 0;
    yOffset = 0;
    jumpVelocity = 0;
    isSliding = false;
    stumbleCount = 0;
    stumbleTimer = 0;
    powerups.clear();
  }

  void moveLane(int dir) {
    lane = (lane + dir).clamp(-1, 1);
  }

  void jump() {
    if (yOffset == 0) {
      jumpVelocity = powerups.containsKey('jump') ? -18 : -12;
    }
  }

  void slide() {
    if (yOffset == 0) {
      isSliding = true;
      slideTimer = 0.8;
    }
  }

  void stumble() {
    stumbleCount++;
    stumbleTimer = 10.0;
    if (stumbleCount >= 2) gameRef.gameOver();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!gameRef.isPlaying) return;

    visualLane += (lane - visualLane) * dt * 12;
    
    if (powerups.containsKey('jetpack')) {
      yOffset += (-150 - yOffset) * dt * 5;
    } else {
      if (yOffset < 0 || jumpVelocity != 0) {
        yOffset += jumpVelocity;
        jumpVelocity += 0.6;
        if (yOffset > 0) {
          yOffset = 0;
          jumpVelocity = 0;
        }
      }
    }

    if (isSliding) {
      slideTimer -= dt;
      if (slideTimer <= 0) isSliding = false;
    }

    if (stumbleTimer > 0) {
      stumbleTimer -= dt;
      if (stumbleTimer <= 0) stumbleCount = 0;
    }

    final keys = powerups.keys.toList();
    for (var key in keys) {
      powerups[key] = powerups[key]! - dt;
      if (powerups[key]! <= 0) powerups.remove(key);
    }
  }

  @override
  void render(Canvas canvas) {
    final x = gameRef.size.x / 2 + visualLane * 100;
    final y = gameRef.size.y * 0.85 + yOffset;
    
    final bodyPaint = Paint()..color = GameColors.player;
    double w = 40, h = 60;
    if (isSliding) h = 30;
    
    // Shadow
    canvas.drawOval(Rect.fromCenter(center: Offset(x, gameRef.size.y * 0.85 + 5), width: 50, height: 15), Paint()..color = Colors.black26);

    // Body
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(x, y - h/2), width: w, height: h), const Radius.circular(8)), bodyPaint);
    
    // Head
    canvas.drawCircle(Offset(x, y - h - 10), 12, bodyPaint);

    // Shield
    if (powerups.containsKey('shield')) {
      canvas.drawCircle(Offset(x, y - h/2), 55, Paint()..color = Colors.blue.withValues(alpha: 0.3)..style = PaintingStyle.stroke..strokeWidth = 4);
    }
    
    // Chaser
    if (stumbleCount > 0) {
      final chaserX = x;
      final chaserY = y + 150 - (stumbleCount * 60);
      canvas.drawRect(Rect.fromCenter(center: Offset(chaserX, chaserY), width: 50, height: 80), Paint()..color = Colors.red.withValues(alpha: 0.8));
    }
  }
}

class LevelManager extends Component with HasGameRef<RailDashGame> {
  final List<LevelObject> objects = [];
  double spawnTimer = 0;
  final Random rng = Random();

  void reset() {
    objects.clear();
    spawnTimer = 0;
  }

  @override
  void update(double dt) {
    if (!gameRef.isPlaying) return;
    
    spawnTimer -= dt * gameRef.gameSpeed;
    if (spawnTimer <= 0) {
      _spawn();
      spawnTimer = 1.0 / (gameRef.gameSpeed * 0.5 + 0.5);
    }

    for (int i = objects.length - 1; i >= 0; i--) {
      final obj = objects[i];
      double speed = gameRef.gameSpeed * 0.4;
      if (obj.type == ObjectType.train) speed *= 1.8;
      
      obj.z -= dt * speed;
      
      // Magnet logic
      if (gameRef.player.powerups.containsKey('magnet') && obj.type == ObjectType.coin && obj.z < 0.5) {
        obj.lane += (gameRef.player.lane - obj.lane) * dt * 5;
      }

      if (obj.z < -0.1) {
        objects.removeAt(i);
        continue;
      }
      
      // Collision
      if (obj.z < 0.08 && obj.z > 0.01) {
        if ((obj.lane - gameRef.player.lane).abs() < 0.5) {
          _checkCollision(obj);
        }
      }
    }
  }

  void _spawn() {
    int lane = rng.nextInt(3) - 1;
    int r = rng.nextInt(100);
    if (r < 40) objects.add(LevelObject(lane.toDouble(), 1.2, ObjectType.coin));
    else if (r < 60) objects.add(LevelObject(lane.toDouble(), 1.2, ObjectType.barrierLow));
    else if (r < 80) objects.add(LevelObject(lane.toDouble(), 1.2, ObjectType.barrierHigh));
    else if (r < 90) objects.add(LevelObject(lane.toDouble(), 1.2, ObjectType.train));
    else objects.add(LevelObject(lane.toDouble(), 1.2, ObjectType.powerup));
  }

  void _checkCollision(LevelObject obj) {
    if (obj.type == ObjectType.coin) {
      gameRef.coins++;
      objects.remove(obj);
    } else if (obj.type == ObjectType.powerup) {
      final p = ['magnet', 'shield', 'jetpack', 'jump'][rng.nextInt(4)];
      gameRef.player.powerups[p] = 10.0;
      objects.remove(obj);
    } else if (obj.type == ObjectType.barrierLow) {
      if (gameRef.player.yOffset > -20) {
        if (gameRef.player.powerups.containsKey('shield')) {
          gameRef.player.powerups.remove('shield');
        } else {
          gameRef.player.stumble();
        }
        objects.remove(obj);
      }
    } else if (obj.type == ObjectType.barrierHigh) {
      if (!gameRef.player.isSliding && !gameRef.player.powerups.containsKey('jetpack')) {
        if (gameRef.player.powerups.containsKey('shield')) {
          gameRef.player.powerups.remove('shield');
          objects.remove(obj);
        } else {
          gameRef.gameOver();
        }
      }
    } else if (obj.type == ObjectType.train) {
      if (!gameRef.player.powerups.containsKey('jetpack')) {
        if (gameRef.player.powerups.containsKey('shield')) {
          gameRef.player.powerups.remove('shield');
          objects.remove(obj);
        } else {
          gameRef.gameOver();
        }
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final size = gameRef.size;
    final horizonY = size.y * 0.4;
    
    // Sky
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, horizonY), Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.blue.shade900, Colors.lightBlue]).createShader(Rect.fromLTWH(0, 0, size.x, horizonY)));
    
    // Ground
    canvas.drawRect(Rect.fromLTWH(0, horizonY, size.x, size.y - horizonY), Paint()..color = Colors.grey.shade800);

    // Rails
    final railPaint = Paint()..color = Colors.white24..strokeWidth = 3;
    for (int i = -1; i <= 1; i++) {
      canvas.drawLine(Offset(size.x/2 + i*10, horizonY), Offset(size.x/2 + i*300, size.y), railPaint);
    }

    // Sort objects by Z for correct depth rendering
    final sorted = List<LevelObject>.from(objects)..sort((a, b) => b.z.compareTo(a.z));

    for (var obj in sorted) {
      double scale = 1.0 / (1.0 + obj.z * 8.0);
      double x = size.x / 2 + (obj.lane * 250 * scale);
      double y = horizonY + (size.y - horizonY) * scale;
      double objSize = 100 * scale;

      Paint p = Paint();
      switch (obj.type) {
        case ObjectType.barrierLow:
          p.color = Colors.orange;
          canvas.drawRect(Rect.fromCenter(center: Offset(x, y - objSize/4), width: objSize * 1.2, height: objSize/2), p);
          break;
        case ObjectType.barrierHigh:
          p.color = Colors.red;
          canvas.drawRect(Rect.fromCenter(center: Offset(x, y - objSize * 1.5), width: objSize * 1.5, height: objSize/3), p);
          break;
        case ObjectType.coin:
          p.color = Colors.amber;
          canvas.drawCircle(Offset(x, y - objSize/2), objSize/2, p);
          break;
        case ObjectType.powerup:
          p.color = Colors.cyan;
          canvas.drawRect(Rect.fromCenter(center: Offset(x, y - objSize/2), width: objSize, height: objSize), p);
          break;
        case ObjectType.train:
          p.color = Colors.indigo;
          canvas.drawRect(Rect.fromCenter(center: Offset(x, y - objSize), width: objSize * 1.5, height: objSize * 2), p);
          // Windows
          canvas.drawRect(Rect.fromCenter(center: Offset(x, y - objSize * 1.2), width: objSize, height: objSize * 0.4), Paint()..color = Colors.white38);
          break;
      }
    }
  }
}

enum ObjectType { barrierLow, barrierHigh, coin, powerup, train }

class LevelObject {
  double lane;
  double z;
  ObjectType type;
  LevelObject(this.lane, this.z, this.type);
}