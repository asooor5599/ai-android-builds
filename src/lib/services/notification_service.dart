import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:app/services/quran_data.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'quran_daily_reminders';
  static const String _channelName = 'تذكير الآيات والأذكار';
  static const String _channelDesc = 'إشعارات دورية تتضمن آيات قرآنية وأذكار وأدعية';

  static Future<void> init() async {
    if (kIsWeb) return;
    try {
      tzdata.initializeTimeZones();
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Riyadh'));
      } catch (_) {
        tz.setLocalLocation(tz.getLocation('UTC'));
      }

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);
      await _notificationsPlugin.initialize(initSettings);

      // Request notification permissions immediately upon startup for Android and iOS
      await requestPermissions();
    } catch (e) {
      debugPrint('Notification init error: $e');
    }
  }

  static Future<void> requestPermissions() async {
    if (kIsWeb) return;
    try {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (_) {}
  }

  static Map<String, String> getRandomNotificationContent() {
    final random = Random();
    final showVerse = random.nextBool();
    if (showVerse) {
      final verse = QuranDataService.randomVerses[
          random.nextInt(QuranDataService.randomVerses.length)];
      return {
        'title': 'آية قرآنية عاطرة ✨',
        'body': '« ${verse['text']} »\n[ ${verse['surah']} ]',
      };
    } else {
      final zekr = QuranDataService.fallbackAzkar[
          random.nextInt(QuranDataService.fallbackAzkar.length)];
      return {
        'title': 'ذِكْر ودعاء 🤲',
        'body': '${zekr.zekr}\n[ ${zekr.category} - ${zekr.reference} ]',
      };
    }
  }

  static Future<void> schedulePeriodicNotifications({
    required bool enabled,
    required int intervalHours,
  }) async {
    if (kIsWeb) return;
    try {
      await _notificationsPlugin.cancel(1001);
      if (!enabled) return;

      await requestPermissions();

      final content = getRandomNotificationContent();
      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );
      const notificationDetails = NotificationDetails(android: androidDetails);

      final scheduledTime = tz.TZDateTime.now(tz.local).add(Duration(hours: intervalHours));

      await _notificationsPlugin.zonedSchedule(
        1001,
        content['title'],
        content['body'],
        scheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Schedule notifications error: $e');
    }
  }

  static Future<void> showTestNotification() async {
    if (kIsWeb) return;
    try {
      await requestPermissions();
      final content = getRandomNotificationContent();
      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );
      const notificationDetails = NotificationDetails(android: androidDetails);
      await _notificationsPlugin.show(
        999,
        content['title'],
        content['body'],
        notificationDetails,
      );
    } catch (e) {
      debugPrint('Test notification error: $e');
    }
  }
}
