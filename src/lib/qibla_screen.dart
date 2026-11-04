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
      appBar: AppBar(title: const Text('Qibla Finder')),
      body: StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Compass error'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          double? heading = snapshot.data!.heading;
          if (heading == null) return const Center(child: Text('Device sensors not supported'));

          double qibla = state.qiblaDirection;
          // The needle should point to Qibla relative to North
          // heading is degrees clockwise from North
          double needleAngle = (qibla - heading) * (pi / 180.0);

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Align the needle with the Kaaba icon',
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 60),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Compass Ring
                    Transform.rotate(
                      angle: -heading * (pi / 180.0),
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.teal.withValues(alpha: 0.2), width: 8),
                        ),
                        child: CustomPaint(painter: CompassTicksPainter()),
                      ),
                    ),
                    // Qibla Needle
                    Transform.rotate(
                      angle: needleAngle,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on, size: 48, color: Colors.amber),
                          Container(width: 4, height: 120, color: Colors.teal),
                        ],
                      ),
                    ),
                    const CircleAvatar(radius: 10, backgroundColor: Colors.teal),
                  ],
                ),
                const SizedBox(height: 60),
                Text(
                  '${qibla.toStringAsFixed(1)}° from North',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  state.currentPosition != null 
                    ? 'Lat: ${state.currentPosition!.latitude.toStringAsFixed(2)}, Lng: ${state.currentPosition!.longitude.toStringAsFixed(2)}'
                    : '',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CompassTicksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.teal.withValues(alpha: 0.5)
      ..strokeWidth = 2;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (var i = 0; i < 360; i += 30) {
      final angle = i * (pi / 180);
      final start = Offset(center.dx + (radius - 10) * cos(angle), center.dy + (radius - 10) * sin(angle));
      final end = Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle));
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}