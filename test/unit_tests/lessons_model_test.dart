import 'package:flutter_test/flutter_test.dart';
import 'package:ana_muslim/features/lessons/data/models/lesson_model.dart';

void main() {
  group('LessonModel Unit Test', () {
    test('should parse json correctly to LessonModel', () {
      final Map<String, dynamic> json = {
        'id': 101,
        'title': 'الخشوع في الصلاة',
        'description': 'محاضرة قيمة للشيخ',
        'prepared_by': [
          {'title': 'الشيخ عمر عبد الكافي'}
        ],
        'attachments': [
          {'url': 'https://islamhouse.com/audio/101.mp3'}
        ]
      };

      final lesson = LessonModel.fromJson(json);

      expect(lesson.id, equals(101));
      expect(lesson.title, equals('الخشوع في الصلاة'));
      expect(lesson.author, equals('الشيخ عمر عبد الكافي'));
      expect(lesson.audioUrl, equals('https://islamhouse.com/audio/101.mp3'));
    });

    test('should handle missing json fields gracefully with defaults', () {
      final Map<String, dynamic> emptyJson = {};

      final lesson = LessonModel.fromJson(emptyJson);

      expect(lesson.id, equals(0));
      expect(lesson.title, equals('درس إسلامي'));
      expect(lesson.author, equals('الشيخ'));
      expect(lesson.audioUrl, equals(''));
    });
  });
}
