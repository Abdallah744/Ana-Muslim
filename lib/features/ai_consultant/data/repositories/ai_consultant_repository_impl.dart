import '../../domain/repositories/ai_consultant_repository.dart';
import '../datasources/gemini_remote_data_source.dart';

class AiConsultantRepositoryImpl implements AiConsultantRepository {
  final GeminiRemoteDataSource remoteDataSource;

  AiConsultantRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> getAiResponse(String message) async {
    return await remoteDataSource.getResponse(message);
  }
}
