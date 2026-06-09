import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/ai_message.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/openai_datasource.dart';

class AiRepositoryImpl implements AiRepository {
  final OpenAiDatasource _openAi;
  final FirebaseFirestore _firestore;

  AiRepositoryImpl({
    required OpenAiDatasource openAi,
    required FirebaseFirestore firestore,
  })  : _openAi = openAi,
        _firestore = firestore;

  @override
  Future<AiMessage> sendMessage({
    required List<AiMessage> conversationHistory,
    required String userMessage,
    required String language,
  }) async {
    final response = await _openAi.sendMessage(
      history: conversationHistory,
      userMessage: userMessage,
      language: language,
    );

    return AiMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      role: AiMessageRole.assistant,
      content: response,
      timestamp: DateTime.now(),
      status: AiMessageStatus.sent,
    );
  }

  @override
  Stream<String> streamMessage({
    required List<AiMessage> conversationHistory,
    required String userMessage,
    required String language,
  }) {
    return _openAi.streamMessage(
      history: conversationHistory,
      userMessage: userMessage,
      language: language,
    );
  }

  @override
  Future<void> saveConversation({
    required String userId,
    required AiConversation conversation,
  }) async {
    final messagesData = conversation.messages.map((m) => {
      'id': m.id,
      'role': m.role.name,
      'content': m.content,
      'timestamp': m.timestamp.toIso8601String(),
      'status': m.status.name,
    }).toList();

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('ai_conversations')
        .doc(conversation.id)
        .set({
      'id': conversation.id,
      'title': conversation.title,
      'messages': messagesData,
      'createdAt': conversation.createdAt.toIso8601String(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<List<AiConversation>> getConversationHistory(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('ai_conversations')
        .orderBy('updatedAt', descending: true)
        .limit(20)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final messagesJson = data['messages'] as List<dynamic>? ?? [];
      final messages = messagesJson.map((m) {
        final mMap = m as Map<String, dynamic>;
        final role = AiMessageRole.values.firstWhere(
          (r) => r.name == mMap['role'],
          orElse: () => AiMessageRole.assistant,
        );
        return AiMessage(
          id: mMap['id'] as String,
          role: role,
          content: mMap['content'] as String,
          timestamp: DateTime.parse(mMap['timestamp'] as String),
          status: AiMessageStatus.sent,
        );
      }).toList();

      return AiConversation(
        id: data['id'] as String,
        title: data['title'] as String? ?? 'Conversation',
        messages: messages,
        createdAt: DateTime.parse(data['createdAt'] as String),
        updatedAt: DateTime.now(),
      );
    }).toList();
  }

  @override
  Future<void> deleteConversation({
    required String userId,
    required String conversationId,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('ai_conversations')
        .doc(conversationId)
        .delete();
  }
}
