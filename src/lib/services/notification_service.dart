import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:app/models/quran_models.dart';

class NotificationService {
  static const String _prefPermissionKey = 'notification_permission_enabled';
  static const String _prefSentIdsKey = 'sent_azkar_ids_v1';
  static const String _prefHistoryKey = 'azkar_notification_history_v1';
  static const String _prefLastSentDateKey = 'last_sent_notification_date';

  Timer? _dailyTimer;

  Future<bool> isPermissionGranted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefPermissionKey) ?? false;
  }

  Future<void> setPermissionGranted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefPermissionKey, value);
  }

  Future<List<String>> getSentAzkarIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_prefSentIdsKey) ?? [];
  }

  Future<List<DailyNotificationRecord>> getNotificationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefHistoryKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List decoded = json.decode(raw);
      return decoded.map((e) => DailyNotificationRecord.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<DailyNotificationRecord?> triggerDailyNotificationCheck({
    required List<ZekrItem> allAzkar,
    bool force = false,
  }) async {
    if (allAzkar.isEmpty) return null;
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool(_prefPermissionKey) ?? false;
    if (!isEnabled && !force) return null;

    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final lastSentDate = prefs.getString(_prefLastSentDateKey);

    final now = DateTime.now();
    if (!force && lastSentDate == todayStr) {
      final history = await getNotificationHistory();
      return history.isNotEmpty ? history.first : null;
    }

    if (!force && now.hour < 12) {
      return null;
    }

    List<String> sentIds = prefs.getStringList(_prefSentIdsKey) ?? [];
    List<ZekrItem> available = allAzkar.where((z) => !sentIds.contains(z.id) && z.zekr.isNotEmpty).toList();

    if (available.isEmpty) {
      sentIds = [];
      available = allAzkar.where((z) => z.zekr.isNotEmpty).toList();
    }

    final random = Random();
    final selectedZekr = available[random.nextInt(available.length)];

    sentIds.add(selectedZekr.id);
    await prefs.setStringList(_prefSentIdsKey, sentIds);
    await prefs.setString(_prefLastSentDateKey, todayStr);

    final record = DailyNotificationRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'ذِكْرُ ودُعاء اليوم (الساعة 12:00 مساءً)',
      zekrText: selectedZekr.zekr,
      category: selectedZekr.category,
      dateFormatted: DateFormat('yyyy/MM/dd - hh:mm a', 'ar').format(DateTime.now()),
    );

    List<DailyNotificationRecord> history = await getNotificationHistory();
    history.insert(0, record);
    if (history.length > 50) history = history.sublist(0, 50);

    await prefs.setString(_prefHistoryKey, json.encode(history.map((e) => e.toJson()).toList()));
    return record;
  }

  void startDaily12PMAnticipator(VoidCallback onTrigger) {
    _dailyTimer?.cancel();
    _dailyTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      final now = DateTime.now();
      if (now.hour == 12) {
        onTrigger();
      }
    });
  }

  void dispose() {
    _dailyTimer?.cancel();
  }
}
