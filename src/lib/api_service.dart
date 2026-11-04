import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/models.dart';

class ApiService {
  static const String baseUrl = 'https://api.alquran.cloud/v1';

  Future<List<Surah>> getSurahs() async {
    final response = await http.get(Uri.parse('$baseUrl/surah'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['data'] as List).map((s) => Surah.fromJson(s)).toList();
    } else {
      throw Exception('Failed to load surahs');
    }
  }

  Future<List<Ayah>> getSurahDetails(int number) async {
    final response = await http.get(Uri.parse('$baseUrl/surah/$number'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['data']['ayahs'] as List).map((a) => Ayah.fromJson(a)).toList();
    } else {
      throw Exception('Failed to load ayahs');
    }
  }
}