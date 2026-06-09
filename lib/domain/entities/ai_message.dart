import 'package:flutter/foundation.dart';

enum AiMessageRole { user, assistant, system }

enum AiMessageStatus { sending, sent, error, streaming }

@immutable
class AiMessage {
  final String id;
  final AiMessageRole role;
  final String content;
  final DateTime timestamp;
  final AiMessageStatus status;
  final List<String>? suggestedFollowUps;
  final String? errorMessage;
  final List<String>? bibleReferences;

  const AiMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.status = AiMessageStatus.sent,
    this.suggestedFollowUps,
    this.errorMessage,
    this.bibleReferences,
  });

  bool get isUser => role == AiMessageRole.user;
  bool get isAssistant => role == AiMessageRole.assistant;
  bool get isSystem => role == AiMessageRole.system;
  bool get isSending => status == AiMessageStatus.sending;
  bool get isError => status == AiMessageStatus.error;
  bool get isStreaming => status == AiMessageStatus.streaming;

  AiMessage copyWith({
    String? content,
    AiMessageStatus? status,
    List<String>? suggestedFollowUps,
    String? errorMessage,
    List<String>? bibleReferences,
  }) {
    return AiMessage(
      id: id,
      role: role,
      content: content ?? this.content,
      timestamp: timestamp,
      status: status ?? this.status,
      suggestedFollowUps: suggestedFollowUps ?? this.suggestedFollowUps,
      errorMessage: errorMessage ?? this.errorMessage,
      bibleReferences: bibleReferences ?? this.bibleReferences,
    );
  }

  /// Creates a user message.
  factory AiMessage.user(String content) {
    return AiMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      role: AiMessageRole.user,
      content: content,
      timestamp: DateTime.now(),
      status: AiMessageStatus.sending,
    );
  }

  /// Creates a placeholder assistant message (streaming).
  factory AiMessage.assistantStreaming() {
    return AiMessage(
      id: 'streaming-${DateTime.now().microsecondsSinceEpoch}',
      role: AiMessageRole.assistant,
      content: '',
      timestamp: DateTime.now(),
      status: AiMessageStatus.streaming,
    );
  }

  /// Creates an error message.
  factory AiMessage.error(String errorText) {
    return AiMessage(
      id: 'error-${DateTime.now().microsecondsSinceEpoch}',
      role: AiMessageRole.assistant,
      content: errorText,
      timestamp: DateTime.now(),
      status: AiMessageStatus.error,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiMessage &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Represents a complete AI conversation.
@immutable
class AiConversation {
  final String id;
  final String title;
  final List<AiMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AiConversation({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  AiConversation copyWith({
    String? title,
    List<AiMessage>? messages,
    DateTime? updatedAt,
  }) {
    return AiConversation(
      id: id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
