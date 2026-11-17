import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/notifications_service.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  bool _morningActive = false;
  TimeOfDay _morningTime = const TimeOfDay(hour: 6, minute: 0);
  bool _eveningActive = false;
  TimeOfDay _eveningTime = const TimeOfDay(hour: 17, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _morningActive = prefs.getBool('morningActive') ?? false;
      _morningTime = TimeOfDay(hour: prefs.getInt('morningH') ?? 6, minute: prefs.getInt('morningM') ?? 0);
      _eveningActive = prefs.getBool('eveningActive') ?? false;
      _eveningTime = TimeOfDay(hour: prefs.getInt('eveningH') ?? 17, minute: prefs.getInt('eveningM') ?? 0);
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('morningActive', _morningActive);
    await prefs.setInt('morningH', _morningTime.hour);
    await prefs.setInt('morningM', _morningTime.minute);
    await prefs.setBool('eveningActive', _eveningActive);
    await prefs.setInt('eveningH', _eveningTime.hour);
    await prefs.setInt('eveningM', _eveningTime.minute);

    if (_morningActive) {
      await NotificationService.scheduleReminder(1, 'أذكار الصباح', 'حان وقت أذكار الصباح', _morningTime.hour, _morningTime.minute);
    } else {
      await NotificationService.cancel(1);
    }

    if (_eveningActive) {
      await NotificationService.scheduleReminder(2, 'أذكار المساء', 'حان وقت أذكار المساء', _eveningTime.hour, _eveningTime.minute);
    } else {
      await NotificationService.cancel(2);
    }
  }

  Future<void> _pickTime(bool isMorning) async {
    final initial = isMorning ? _morningTime : _eveningTime;
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      setState(() {
        if (isMorning) _morningTime = picked; else _eveningTime = picked;
      });
      _saveSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تذكيرات الأذكار')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildReminderCard('أذكار الصباح', _morningActive, _morningTime, (v) {
            setState(() => _morningActive = v);
            _saveSettings();
          }, () => _pickTime(true)),
          const SizedBox(height: 16),
          _buildReminderCard('أذكار المساء', _eveningActive, _eveningTime, (v) {
            setState(() => _eveningActive = v);
            _saveSettings();
          }, () => _pickTime(false)),
        ],
      ),
    );
  }

  Widget _buildReminderCard(String title, bool active, TimeOfDay time, ValueChanged<bool> onToggle, VoidCallback onTimeTap) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Switch(value: active, onChanged: onToggle),
              ],
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('وقت التنبيه'),
              trailing: Text(time.format(context), style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold, fontSize: 16)),
              onTap: onTimeTap,
            ),
          ],
        ),
      ),
    );
  }
}