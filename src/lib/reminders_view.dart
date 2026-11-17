import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;
import 'package:app/notification_provider.dart';

class RemindersView extends StatelessWidget {
  const RemindersView({super.key});

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return intl.DateFormat.jm('ar_SA').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final notify = context.watch<NotificationProvider>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تنبيهات الأذكار اليومية',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildReminderTile(
            context,
            'أذكار الصباح',
            notify.morningEnabled,
            notify.morningTime,
            (val) => notify.updateMorning(val, notify.morningTime),
            () async {
              final picked = await showTimePicker(context: context, initialTime: notify.morningTime);
              if (picked != null) notify.updateMorning(notify.morningEnabled, picked);
            },
          ),
          const SizedBox(height: 12),
          _buildReminderTile(
            context,
            'أذكار المساء',
            notify.eveningEnabled,
            notify.eveningTime,
            (val) => notify.updateEvening(val, notify.eveningTime),
            () async {
              final picked = await showTimePicker(context: context, initialTime: notify.eveningTime);
              if (picked != null) notify.updateEvening(notify.eveningEnabled, picked);
            },
          ),
          const Spacer(),
          const Center(
            child: Text(
              'سيصلك تنبيه في الوقت المحدد حتى لو كان التطبيق مغلقاً',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderTile(
    BuildContext context,
    String title,
    bool enabled,
    TimeOfDay time,
    Function(bool) onToggle,
    VoidCallback onTimeTap,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: InkWell(
            onTap: onTimeTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                _formatTime(time),
                style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
          trailing: Switch(
            value: enabled,
            onChanged: onToggle,
          ),
        ),
      ),
    );
  }
}