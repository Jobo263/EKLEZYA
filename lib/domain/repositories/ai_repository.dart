import '../entities/ai_message.dart';

abstract class AiRepository {
  /// Send a message and get a response.
  Future<AiMessage> sendMessage({
    required List<AiMessage> conversationHistory,
    required String userMessage,
    required String language,
  });

  /// Stream a response token by token.
  Stream<String> streamMessage({
    required List<AiMessage> conversationHistory,
    required String userMessage,
    required String language,
  });

  /// Save conversation to Firestore.
  Future<void> saveConversation({
    required String userId,
    required AiConversation conversation,
  });

  /// Get conversation history for user.
  Future<List<AiConversation>> getConversationHistory(String userId);

  /// Delete a conversation.
  Future<void> deleteConversation({
    required String userId,
    required String conversationId,
  });
}
