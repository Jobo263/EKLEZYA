import '../../entities/ai_message.dart';
import '../../repositories/ai_repository.dart';

class SendAiMessageUseCase {
  final AiRepository _repository;

  const SendAiMessageUseCase(this._repository);

  Future<AiMessage> call({
    required List<AiMessage> history,
    required String message,
    required String language,
  }) async {
    return _repository.sendMessage(
      conversationHistory: history,
      userMessage: message,
      language: language,
    );
  }

  Stream<String> stream({
    required List<AiMessage> history,
    required String message,
    required String language,
  }) {
    return _repository.streamMessage(
      conversationHistory: history,
      userMessage: message,
      language: language,
    );
  }
}
