import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lesson_model.dart';

class LessonLocalDataSource {
  static const String _cachedLessonsKey = 'cached_islamhouse_lessons';

  /// Save fetched lessons list to local SharedPreferences
  Future<void> cacheLessons(List<LessonModel> lessons) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList = lessons.map((lesson) => {
      'id': lesson.id,
      'title': lesson.title,
      'author': lesson.author,
      'description': lesson.description,
      'audioUrl': lesson.audioUrl,
    }).toList();
    await prefs.setString(_cachedLessonsKey, jsonEncode(jsonList));
  }

  /// Retrieve cached lessons list from SharedPreferences
  Future<List<LessonModel>> getCachedLessons() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_cachedLessonsKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList.map((json) => LessonModel(
          id: json['id'] ?? 0,
          title: json['title'] ?? 'درس إسلامي',
          author: json['author'] ?? 'الشيخ',
          description: json['description'] ?? '',
          audioUrl: json['audioUrl'] ?? '',
        )).toList();
      } catch (_) {}
    }
    return [];
  }
}
