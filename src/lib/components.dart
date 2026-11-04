import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:app/game.dart';
import 'package:app/constants.dart';

class Player extends PositionComponent with HasGameRef<RailDashGame> {
  int lane = 0; // -1, 0, 1
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
    powerups.clear();
  }

  void moveLane(int dir) {
    lane = (lane + dir).clamp(-1, 1);
  }

  void jump() {
    if (yOffset == 0) {
      jumpVelocity = powerups.containsKey('jump') ? -15 : -10;
    }
  }

  void slide() {
    if (yOffset == 0) {
      isSliding = true;
      slideTimer = 0.7;
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
    visualLane += (lane - visualLane) * dt * 10;
    
    if (yOffset < 0 || jumpVelocity != 0) {
      yOffset += jumpVelocity;
      jumpVelocity += 0.5;
      if (yOffset > 0) {
        yOffset = 0;
        jumpVelocity = 0;
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

    powerups.forEach((key, value) {
      powerups[key] = value - dt;
    });
    powerups.removeWhere((key, value) => value <= 0);
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.deepPurple;
    final x = gameRef.size.x / 2 + visualLane * 80;
    final y = gameRef.size.y * 0.85 + yOffset;
    
    double w = 40, h = 60;
    if (isSliding) h = 30;
    
    canvas.drawRect(Rect.fromCenter(center: Offset(x, y - h/2), width: w, height: h), paint);
    
    // Head
    canvas.drawCircle(Offset(x, y - h - 10), 10, paint);

    // Shield effect
    if (powerups.containsKey('shield')) {
      canvas.drawCircle(Offset(x, y - h/2), 50, Paint()..color = Colors.blue.withValues(alpha: 0.3)..style = PaintingStyle.stroke..strokeWidth = 3);
    }
    
    // Chaser
    if (stumbleCount > 0) {
      final chaserPaint = Paint()..color = Colors.red.withValues(alpha: 0.7);
      canvas.drawRect(Rect.fromCenter(center: Offset(x, y + 100 - (stumbleCount * 40)), width: 50, height: 70), chaserPaint);
    }
  }
}

class WorldManager extends Component with HasGameRef<RailDashGame> {
  List<WorldObject> objects = [];
  double spawnTimer = 0;

  void reset() {
    objects.clear();
    spawnTimer = 0;
  }

  @override
  void update(double dt) {
    if (!gameRef.isPlaying) return;
    
    spawnTimer -= dt * gameRef.gameSpeed;
    if (spawnTimer <= 0) {
      spawnTimer = 1.5 + Random().nextDouble() * 2;
      _spawnRandom();
    }

    for (var i = objects.length - 1; i >= 0; i--) {
      objects[i].z -= dt * 0.5 * gameRef.gameSpeed;
      if (objects[i].z < -0.1) {
        objects.removeAt(i);
        continue;
      }
      
      // Collision check
      if (objects[i].z < 0.05 && objects[i].z > -0.05 && objects[i].lane == gameRef.player.lane) {
        _handleCollision(objects[i]);
      }
    }
  }

  void _spawnRandom() {
    int lane = Random().nextInt(3) - 1;
    int type = Random().nextInt(10);
    if (type < 4) objects.add(WorldObject(lane, 1.0, ObjectType.barrierLow));
    else if (type < 6) objects.add(WorldObject(lane, 1.0, ObjectType.barrierHigh));
    else if (type < 8) objects.add(WorldObject(lane, 1.0, ObjectType.coin));
    else objects.add(WorldObject(lane, 1.0, ObjectType.powerup));
  }

  void _handleCollision(WorldObject obj) {
    if (obj.type == ObjectType.coin) {
      gameRef.coins++;
      objects.remove(obj);
    } else if (obj.type == ObjectType.powerup) {
      final p = ['magnet', 'shield', 'jetpack', 'jump'][Random().nextInt(4)];
      gameRef.player.powerups[p] = 10.0;
      objects.remove(obj);
    } else if (obj.type == ObjectType.barrierLow) {
      if (gameRef.player.yOffset >= -10) {
        if (gameRef.player.powerups.containsKey('shield')) {
          gameRef.player.powerups.remove('shield');
          objects.remove(obj);
        } else {
          gameRef.player.stumble();
          objects.remove(obj);
        }
      }
    } else if (obj.type == ObjectType.barrierHigh) {
      if (!gameRef.player.isSliding) {
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
    final horizonY = size.y * 0.3;
    final groundY = size.y;
    
    // Draw Rails
    final railPaint = Paint()..color = Colors.grey.withValues(alpha: 0.5)..strokeWidth = 2;
    for (int i = -1; i <= 1; i++) {
      canvas.drawLine(Offset(size.x/2 + i*20, horizonY), Offset(size.x/2 + i*150, groundY), railPaint);
    }

    for (var obj in objects) {
      final scale = 1.0 - obj.z;
      final x = size.x / 2 + (obj.lane * 120) * scale;
      final y = horizonY + (size.y * 0.6) * scale;
      final objSize = 40 * scale;

      Paint p = Paint();
      switch (obj.type) {
        case ObjectType.barrierLow:
          p.color = Colors.orange;
          canvas.drawRect(Rect.fromCenter(center: Offset(x, y), width: objSize * 1.5, height: objSize), p);
          break;
        case ObjectType.barrierHigh:
          p.color = Colors.red;
          canvas.drawRect(Rect.fromCenter(center: Offset(x, y - objSize * 2), width: objSize * 1.5, height: objSize), p);
          break;
        case ObjectType.coin:
          p.color = Colors.amber;
          canvas.drawCircle(Offset(x, y), objSize * 0.5, p);
          break;
        case ObjectType.powerup:
          p.color = Colors.cyan;
          canvas.drawRect(Rect.fromCenter(center: Offset(x, y), width: objSize, height: objSize), p);
          break;
      }
    }
  }
}

enum ObjectType { barrierLow, barrierHigh, coin, powerup }

class WorldObject {
  int lane;
  double z;
  ObjectType type;
  WorldObject(this.lane, this.z, this.type);
}