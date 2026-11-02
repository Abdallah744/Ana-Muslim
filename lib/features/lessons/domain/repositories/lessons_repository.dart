import '../../data/models/lesson_model.dart';

abstract class LessonsRepository {
  Future<List<LessonModel>> getLessons();
}
