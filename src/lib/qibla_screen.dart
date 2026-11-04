import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:provider/provider.dart';
import 'package:app/app_state.dart';

class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Qibla Direction')),
      body: StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Error reading compass'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          double? direction = snapshot.data!.heading;
          if (direction == null) return const Center(child: Text('Device does not have sensors'));

          double qibla = state.qiblaDirection;
          double needleRotation = (qibla - direction) * (pi / 180.0);

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Point your phone towards the Kaaba',
                    style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 40),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Compass Rose
                    Transform.rotate(
                      angle: -direction * (pi / 180.0),
                      child: CustomPaint(
                        size: const Size(300, 300),
                        painter: CompassPainter(),
                      ),
                    ),
                    // Qibla Needle
                    Transform.rotate(
                      angle: needleRotation,
                      child: const Icon(
                        Icons.navigation,
                        size: 120,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Text('${qibla.toStringAsFixed(1)}° from North',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(center, radius, paint);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final directions = {'N': 0, 'E': 90, 'S': 180, 'W': 270};

    for (var entry in directions.entries) {
      final angle = entry.value * (pi / 180.0);
      final offset = Offset(
        center.dx + (radius - 20) * sin(angle),
        center.dy - (radius - 20) * cos(angle),
      );

      textPainter.text = TextSpan(
        text: entry.key,
        style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, offset - Offset(textPainter.width / 2, textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}