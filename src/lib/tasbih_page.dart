import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TasbihPage extends StatefulWidget {
  const TasbihPage({super.key});

  @override
  State<TasbihPage> createState() => _TasbihPageState();
}

class _TasbihPageState extends State<TasbihPage> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _loadCounter();
  }

  void _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _counter = prefs.getInt('tasbih_count') ?? 0);
  }

  void _increment() async {
    HapticFeedback.mediumImpact();
    setState(() => _counter++);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tasbih_count', _counter);
  }

  void _reset() async {
    setState(() => _counter = 0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tasbih_count', 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المسبحة الإلكترونية')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('عدد التسبيحات', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _increment,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.teal.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.teal, width: 4),
                ),
                child: Center(
                  child: Text(
                    '$_counter',
                    style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة ضبط'),
              style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
            ),
            const SizedBox(height: 20),
            const Text('اضغط على الدائرة للتسبيح', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}