import '../../domain/entities/prayer.dart';

class PrayerModel extends Prayer {
  const PrayerModel({
    required super.id,
    required super.title,
    required super.titleFr,
    required super.titleEn,
    required super.body,
    required super.bodyFr,
    required super.bodyEn,
    required super.category,
    super.origin,
    super.author,
    super.estimatedDurationSeconds,
    super.isFavorite,
    super.lastPrayedAt,
    super.timesCompleted,
    super.tags,
    super.audioUrl,
    super.isAvailableOffline,
  });

  factory PrayerModel.fromJson(Map<String, dynamic> json) {
    return PrayerModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? json['titleFr'] as String? ?? '',
      titleFr: json['titleFr'] as String? ?? json['title'] as String? ?? '',
      titleEn: json['titleEn'] as String? ?? json['title'] as String? ?? '',
      body: json['body'] as String? ?? json['bodyFr'] as String? ?? '',
      bodyFr: json['bodyFr'] as String? ?? json['body'] as String? ?? '',
      bodyEn: json['bodyEn'] as String? ?? json['body'] as String? ?? '',
      category: _parseCategory(json['category'] as String? ?? 'other'),
      origin: json['origin'] as String?,
      author: json['author'] as String?,
      estimatedDurationSeconds:
          (json['estimatedDurationSeconds'] as num?)?.toInt(),
      isFavorite: json['isFavorite'] as bool? ?? false,
      lastPrayedAt: json['lastPrayedAt'] != null
          ? DateTime.tryParse(json['lastPrayedAt'] as String)
          : null,
      timesCompleted: (json['timesCompleted'] as num?)?.toInt() ?? 0,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((t) => t as String)
              .toList() ??
          const [],
      audioUrl: json['audioUrl'] as String?,
      isAvailableOffline: json['isAvailableOffline'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'titleFr': titleFr,
      'titleEn': titleEn,
      'body': body,
      'bodyFr': bodyFr,
      'bodyEn': bodyEn,
      'category': category.name,
      'origin': origin,
      'author': author,
      'estimatedDurationSeconds': estimatedDurationSeconds,
      'isFavorite': isFavorite,
      'lastPrayedAt': lastPrayedAt?.toIso8601String(),
      'timesCompleted': timesCompleted,
      'tags': tags,
      'audioUrl': audioUrl,
      'isAvailableOffline': isAvailableOffline,
    };
  }

  factory PrayerModel.fromEntity(Prayer prayer) {
    return PrayerModel(
      id: prayer.id,
      title: prayer.title,
      titleFr: prayer.titleFr,
      titleEn: prayer.titleEn,
      body: prayer.body,
      bodyFr: prayer.bodyFr,
      bodyEn: prayer.bodyEn,
      category: prayer.category,
      origin: prayer.origin,
      author: prayer.author,
      estimatedDurationSeconds: prayer.estimatedDurationSeconds,
      isFavorite: prayer.isFavorite,
      lastPrayedAt: prayer.lastPrayedAt,
      timesCompleted: prayer.timesCompleted,
      tags: prayer.tags,
      audioUrl: prayer.audioUrl,
      isAvailableOffline: prayer.isAvailableOffline,
    );
  }

  static PrayerCategory _parseCategory(String s) {
    return PrayerCategory.values.firstWhere(
      (c) => c.name == s,
      orElse: () => PrayerCategory.other,
    );
  }
}
