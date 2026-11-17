import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProvider extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _morningEnabled = true;
  bool _eveningEnabled = true;
  TimeOfDay _morningTime = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay _eveningTime = const TimeOfDay(hour: 17, minute: 0);

  NotificationProvider() {
    _init();
  }

  bool get morningEnabled => _morningEnabled;
  bool get eveningEnabled => _eveningEnabled;
  TimeOfDay get morningTime => _morningTime;
  TimeOfDay get eveningTime => _eveningTime;

  Future<void> _init() async {
    if (kIsWeb) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _notifications.initialize(initSettings);

    final prefs = await SharedPreferences.getInstance();
    _morningEnabled = prefs.getBool('morningEnabled') ?? true;
    _eveningEnabled = prefs.getBool('eveningEnabled') ?? true;
    _morningTime = TimeOfDay(hour: prefs.getInt('morningH') ?? 6, minute: prefs.getInt('morningM') ?? 0);
    _eveningTime = TimeOfDay(hour: prefs.getInt('eveningH') ?? 17, minute: prefs.getInt('eveningM') ?? 0);

    await _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    _scheduleAll();
    notifyListeners();
  }

  Future<void> updateMorning(bool enabled, TimeOfDay time) async {
    _morningEnabled = enabled;
    _morningTime = time;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('morningEnabled', enabled);
    prefs.setInt('morningH', time.hour);
    prefs.setInt('morningM', time.minute);
    _scheduleAll();
    notifyListeners();
  }

  Future<void> updateEvening(bool enabled, TimeOfDay time) async {
    _eveningEnabled = enabled;
    _eveningTime = time;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('eveningEnabled', enabled);
    prefs.setInt('eveningH', time.hour);
    prefs.setInt('eveningM', time.minute);
    _scheduleAll();
    notifyListeners();
  }

  void _scheduleAll() async {
    if (kIsWeb) return;
    await _notifications.cancelAll();

    if (_morningEnabled) {
      await _schedule(1, 'أذكار الصباح', 'حان وقت أذكار الصباح، حفظكم الله.', _morningTime);
    }
    if (_eveningEnabled) {
      await _schedule(2, 'أذكار المساء', 'حان وقت أذكار المساء، تقبل الله طاعتكم.', _eveningTime);
    }
  }

  Future<void> _schedule(int id, String title, String body, TimeOfDay time) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders_channel',
          'Daily Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}