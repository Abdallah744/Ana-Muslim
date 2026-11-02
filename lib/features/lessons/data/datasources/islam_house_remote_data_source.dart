import 'package:dio/dio.dart';
import '../../../../core/utils/error_handler.dart';
import '../models/lesson_model.dart';

class IslamHouseRemoteDataSource {
  final Dio _dio = Dio();
  static const String _baseUrl = 'https://api3.islamhouse.com/v3/paV29H2gm56kvLP/main/audios/ar/ar/1/25/json';

  Future<List<LessonModel>> getLessons() async {
    try {
      final response = await _dio.get(
        _baseUrl,
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => LessonModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception(AppErrorHandler.parseError(e));
    }
  }
}
