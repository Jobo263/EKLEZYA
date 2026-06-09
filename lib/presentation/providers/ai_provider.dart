import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/openai_datasource.dart';
import '../../data/repositories/ai_repository_impl.dart';
import '../../domain/entities/ai_message.dart';
import '../../domain/repositories/ai_repository.dart';
import '../../domain/usecases/ai/send_ai_message.dart';
import 'auth_provider.dart';

// ── OpenAI API key (must be set in env / flavor config) ───────────────────
// In production, use flutter_dotenv or --dart-define
const String _openAiApiKey = String.fromEnvironment(
  'OPENAI_API_KEY',
  defaultValue: 'YOUR_OPENAI_API_KEY_HERE',
);

// ── Datasource & repository ────────────────────────────────────────────────

final openAiDatasourceProvider = Provider<OpenAiDatasource>((ref) {
  return OpenAiDatasource(apiKey: _openAiApiKey);
});

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepositoryImpl(
    openAi: ref.read(openAiDatasourceProvider),
    firestore: ref.read(firestoreProvider),
  );
});

final sendAiMessageUseCaseProvider = Provider<SendAiMessageUseCase>((ref) {
  return SendAiMessageUseCase(ref.read(aiRepositoryProvider));
});

// ── Language preference ────────────────────────────────────────────────────

final aiLanguageProvider = StateProvider<String>((ref) => 'fr');

// ── Chat state ────────────────────────────────────────────────────────────

class AiChatState {
  final List<AiMessage> messages;
  final bool isLoading;
  final String? error;

  const AiChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  AiChatState copyWith({
    List<AiMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AiChatNotifier extends StateNotifier<AiChatState> {
  final SendAiMessageUseCase _useCase;
  final AiRepository _repository;
  final String _userId;
  late AiConversation _conversation;

  AiChatNotifier({
    required SendAiMessageUseCase useCase,
    required AiRepository repository,
    required String userId,
    required String language,
  })  : _useCase = useCase,
        _repository = repository,
        _userId = userId,
        super(const AiChatState()) {
    _conversation = AiConversation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Nouvelle conversation',
      messages: const [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<void> sendMessage(String userText, {String language = 'fr'}) async {
    if (userText.trim().isEmpty) return;

    // Add user message
    final userMsg = AiMessage.user(userText.trim());
    final updatedMessages = [...state.messages, userMsg];
    state = state.copyWith(messages: updatedMessages, isLoading: true);

    // Add streaming placeholder
    final streamingMsg = AiMessage.assistantStreaming();
    final messagesWithStreaming = [...updatedMessages, streamingMsg];
    state = state.copyWith(messages: messagesWithStreaming);

    try {
      final StringBuffer buffer = StringBuffer();

      await for (final token in _useCase.stream(
        history: state.messages
            .where((m) => m.role != AiMessageRole.system)
            .toList(),
        message: userText,
        language: language,
      )) {
        buffer.write(token);
        // Update streaming message in place
        final newMessages = List<AiMessage>.from(state.messages);
        final idx = newMessages.indexWhere((m) => m.id == streamingMsg.id);
        if (idx != -1) {
          newMessages[idx] = streamingMsg.copyWith(
            content: buffer.toString(),
            status: AiMessageStatus.streaming,
          );
          state = state.copyWith(messages: newMessages);
        }
      }

      // Finalize the streaming message
      final finalMessages = List<AiMessage>.from(state.messages);
      final idx = finalMessages.indexWhere((m) => m.id == streamingMsg.id);
      if (idx != -1) {
        finalMessages[idx] = finalMessages[idx].copyWith(
          status: AiMessageStatus.sent,
        );
      }

      // Update conversation title from first user message
      if (_conversation.messages.isEmpty && userText.length > 5) {
        final title = userText.length > 50
            ? '${userText.substring(0, 50)}...'
            : userText;
        _conversation = _conversation.copyWith(
          title: title,
          messages: finalMessages,
          updatedAt: DateTime.now(),
        );
      } else {
        _conversation = _conversation.copyWith(
          messages: finalMessages,
          updatedAt: DateTime.now(),
        );
      }

      state = state.copyWith(messages: finalMessages, isLoading: false);

      // Save to Firestore
      if (_userId.isNotEmpty) {
        await _repository.saveConversation(
          userId: _userId,
          conversation: _conversation,
        );
      }
    } catch (e) {
      final errorMsg = AiMessage.error(
        'Désolé, une erreur s\'est produite : ${e.toString().replaceAll('Exception:', '').trim()}',
      );
      final finalMessages = List<AiMessage>.from(state.messages);
      final idx = finalMessages.indexWhere((m) => m.id == streamingMsg.id);
      if (idx != -1) {
        finalMessages[idx] = errorMsg;
      } else {
        finalMessages.add(errorMsg);
      }
      state = state.copyWith(
        messages: finalMessages,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearConversation() {
    state = const AiChatState();
    _conversation = AiConversation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Nouvelle conversation',
      messages: const [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

final aiChatProvider =
    StateNotifierProvider<AiChatNotifier, AiChatState>((ref) {
  final uid = ref.watch(currentUidProvider) ?? '';
  final language = ref.watch(aiLanguageProvider);
  return AiChatNotifier(
    useCase: ref.read(sendAiMessageUseCaseProvider),
    repository: ref.read(aiRepositoryProvider),
    userId: uid,
    language: language,
  );
});

// ── Conversation history ──────────────────────────────────────────────────

final aiConversationHistoryProvider =
    FutureProvider<List<AiConversation>>((ref) async {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return [];
  return ref.read(aiRepositoryProvider).getConversationHistory(uid);
});
