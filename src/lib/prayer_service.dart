import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/models.dart';

class PrayerService {
  static Future<PrayerTimes?> fetchPrayerTimes(double lat, double lng) async {
    final url = Uri.parse('https://api.aladhan.com/v1/timings?latitude=$lat&longitude=$lng&method=2');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return PrayerTimes.fromJson(json.decode(response.body));
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}