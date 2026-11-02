import '../repositories/ai_consultant_repository.dart';

class GetAiResponseUseCase {
  final AiConsultantRepository repository;

  GetAiResponseUseCase(this.repository);

  Future<String> call(String message) async {
    return await repository.getAiResponse(message);
  }
}
