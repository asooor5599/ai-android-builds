import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/quran_provider.dart';
import 'package:app/services/notification_service.dart';

class NotificationSettingsDialog extends StatelessWidget {
  const NotificationSettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuranProvider>(context);

    final intervals = [
      {'label': 'كل ساعة', 'value': 1},
      {'label': 'كل 4 ساعات', 'value': 4},
      {'label': 'يومياً (كل 24 ساعة)', 'value': 24},
    ];

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.notifications_active, color: Colors.teal),
          SizedBox(width: 8),
          Text('إعدادات الإشعارات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('تفعيل إشعارات الآيات والأذكار'),
              subtitle: const Text('إرسال تذكير دوري بآيات وأذكار عشوائية'),
              value: provider.notificationsEnabled,
              activeColor: Colors.teal,
              onChanged: (val) => provider.setNotificationsEnabled(val),
            ),
            const Divider(),
            if (provider.notificationsEnabled) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'معدل التكرار:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              ...intervals.map((item) {
                final val = item['value'] as int;
                return RadioListTile<int>(
                  title: Text(item['label'] as String),
                  value: val,
                  groupValue: provider.notificationIntervalHours,
                  activeColor: Colors.teal,
                  onChanged: (newVal) {
                    if (newVal != null) {
                      provider.setNotificationIntervalHours(newVal);
                    }
                  },
                );
              }),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  await NotificationService.showTestNotification();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم إرسال إشعار تجريبي بنجاح!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text('تجربة إرسال إشعار الآن'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.teal,
                  side: const BorderSide(color: Colors.teal),
                ),
              ),
            ] else
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'تم تعطيل التذكير الدوري.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('تم', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
