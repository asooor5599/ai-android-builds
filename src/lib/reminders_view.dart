import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;
import 'package:app/notification_provider.dart';

class RemindersView extends StatelessWidget {
  const RemindersView({super.key});

  String _formatTime(BuildContext context, TimeOfDay time) {
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
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
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
          const SizedBox(height: 16),
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.green),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'ستصلك التنبيهات يومياً في الوقت المحدد حتى لو كان التطبيق مغلقاً.',
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),
              ],
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
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: ListTile(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: InkWell(
            onTap: onTimeTap,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _formatTime(context, time),
                style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500),
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