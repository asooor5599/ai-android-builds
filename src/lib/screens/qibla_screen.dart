import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/services/prayer_service.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double _simulatedCompassHeading = 0.0;

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<PrayerService>(context);
    final qiblaAngle = service.qiblaAngle;
    final theme = Theme.of(context);
    final needleAngle = (qiblaAngle - _simulatedCompassHeading) * (pi / 180.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('اتجاه القبلة'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_city, color: Color(0xFFD4AF37)),
                        const SizedBox(width: 8),
                        Text(
                          'الموقع الحالي: ${service.currentLocation.name}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'زاوية القبلة بالنسبة للشمال: ${qiblaAngle.toStringAsFixed(1)}°',
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.surface,
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.15),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Stack(
                      children: [
                        Positioned(
                          top: 10,
                          left: 0,
                          right: 0,
                          child: Text(
                            'N',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: Text(
                            'S',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                        Positioned(
                          right: 12,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: Text('E', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          ),
                        ),
                        Positioned(
                          left: 12,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: Text('W', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Transform.rotate(
                    angle: needleAngle,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 240,
                          height: 240,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1E2621),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.mosque,
                                  color: Color(0xFFD4AF37),
                                  size: 32,
                                ),
                              ),
                              Container(
                                width: 4,
                                height: 80,
                                color: theme.colorScheme.secondary,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ], 