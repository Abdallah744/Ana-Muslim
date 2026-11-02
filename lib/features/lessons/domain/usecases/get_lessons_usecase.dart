import '../repositories/lessons_repository.dart';
import '../../data/models/lesson_model.dart';

class GetLessonsUseCase {
  final LessonsRepository repository;

  GetLessonsUseCase(this.repository);

  Future<List<LessonModel>> call() async {
    return await repository.getLessons();
  }
}
