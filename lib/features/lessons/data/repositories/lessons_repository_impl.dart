import '../../domain/repositories/lessons_repository.dart';
import '../datasources/islam_house_remote_data_source.dart';
import '../datasources/lesson_local_data_source.dart';
import '../models/lesson_model.dart';

class LessonsRepositoryImpl implements LessonsRepository {
  final IslamHouseRemoteDataSource remoteDataSource;
  final LessonLocalDataSource localDataSource = LessonLocalDataSource();

  LessonsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<LessonModel>> getLessons() async {
    try {
      final lessons = await remoteDataSource.getLessons();
      if (lessons.isNotEmpty) {
        await localDataSource.cacheLessons(lessons);
        return lessons;
      }
    } catch (e) {
      // Offline Fallback: Load cached lessons
      final cached = await localDataSource.getCachedLessons();
      if (cached.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
    return await localDataSource.getCachedLessons();
  }
}
