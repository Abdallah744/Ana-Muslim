import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class QuranLocalDataSource {
  static const String _quranJsonPath = 'assets/json/Quran.json';
  static const String _hadithJsonPath = 'assets/json/40-hadith-nawawi.json';
  static const String _azkarJsonPath = 'assets/json/husn_en.json';

  Future<List<dynamic>> getQuranData() async {
    try {
      final String response = await rootBundle.loadString(_quranJsonPath);
      final data = await json.decode(response);
      return data; // يعود بقائمة السور/الآيات
    } catch (e) {
      throw Exception('Failed to load Quran data: $e');
    }
  }

  Future<List<dynamic>> getHadithData() async {
    try {
      final String response = await rootBundle.loadString(_hadithJsonPath);
      final data = await json.decode(response);
      return data;
    } catch (e) {
      throw Exception('Failed to load Hadith data: $e');
    }
  }

  Future<dynamic> getAzkarData() async {
    try {
      final String response = await rootBundle.loadString(_azkarJsonPath);
      final data = await json.decode(response);
      return data;
    } catch (e) {
      throw Exception('Failed to load Azkar data: $e');
    }
  }
}
