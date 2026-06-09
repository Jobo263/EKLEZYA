import 'package:flutter/foundation.dart';

enum PrayerCategory {
  morning,
  evening,
  rosary,
  litany,
  novena,
  chaplet,
  traditional,
  marian,
  liturgical,
  reconciliation,
  thanksgiving,
  intercession,
  other,
}

@immutable
class Prayer {
  final String id;
  final String title;
  final String titleFr;
  final String titleEn;
  final String body;
  final String bodyFr;
  final String bodyEn;
  final PrayerCategory category;
  final String? origin;
  final String? author;
  final int? estimatedDurationSeconds;
  final bool isFavorite;
  final DateTime? lastPrayedAt;
  final int timesCompleted;
  final List<String> tags;
  final String? audioUrl;
  final bool isAvailableOffline;

  const Prayer({
    required this.id,
    required this.title,
    required this.titleFr,
    required this.titleEn,
    required this.body,
    required this.bodyFr,
    required this.bodyEn,
    required this.category,
    this.origin,
    this.author,
    this.estimatedDurationSeconds,
    this.isFavorite = false,
    this.lastPrayedAt,
    this.timesCompleted = 0,
    this.tags = const [],
    this.audioUrl,
    this.isAvailableOffline = false,
  });

  String getTitle(String languageCode) =>
      languageCode == 'fr' ? titleFr : titleEn;

  String getBody(String languageCode) =>
      languageCode == 'fr' ? bodyFr : bodyEn;

  Prayer copyWith({
    String? id,
    String? title,
    String? titleFr,
    String? titleEn,
    String? body,
    String? bodyFr,
    String? bodyEn,
    PrayerCategory? category,
    String? origin,
    String? author,
    int? estimatedDurationSeconds,
    bool? isFavorite,
    DateTime? lastPrayedAt,
    int? timesCompleted,
    List<String>? tags,
    String? audioUrl,
    bool? isAvailableOffline,
  }) {
    return Prayer(
      id: id ?? this.id,
      title: title ?? this.title,
      titleFr: titleFr ?? this.titleFr,
      titleEn: titleEn ?? this.titleEn,
      body: body ?? this.body,
      bodyFr: bodyFr ?? this.bodyFr,
      bodyEn: bodyEn ?? this.bodyEn,
      category: category ?? this.category,
      origin: origin ?? this.origin,
      author: author ?? this.author,
      estimatedDurationSeconds:
          estimatedDurationSeconds ?? this.estimatedDurationSeconds,
      isFavorite: isFavorite ?? this.isFavorite,
      lastPrayedAt: lastPrayedAt ?? this.lastPrayedAt,
      timesCompleted: timesCompleted ?? this.timesCompleted,
      tags: tags ?? this.tags,
      audioUrl: audioUrl ?? this.audioUrl,
      isAvailableOffline: isAvailableOffline ?? this.isAvailableOffline,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Prayer && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
