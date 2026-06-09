import 'package:flutter/foundation.dart';

enum SubscriptionTier { free, premium, premiumPlus }

@immutable
class Badge {
  final String id;
  final String name;
  final String nameFr;
  final String description;
  final String descriptionFr;
  final String iconPath;
  final DateTime earnedAt;

  const Badge({
    required this.id,
    required this.name,
    required this.nameFr,
    required this.description,
    required this.descriptionFr,
    required this.iconPath,
    required this.earnedAt,
  });
}

@immutable
class UserStats {
  final int currentStreak;
  final int longestStreak;
  final int totalPrayersCompleted;
  final int totalBibleChaptersRead;
  final int totalAiConversations;
  final DateTime? lastActivityDate;
  final int totalDaysActive;

  const UserStats({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalPrayersCompleted = 0,
    this.totalBibleChaptersRead = 0,
    this.totalAiConversations = 0,
    this.lastActivityDate,
    this.totalDaysActive = 0,
  });

  UserStats copyWith({
    int? currentStreak,
    int? longestStreak,
    int? totalPrayersCompleted,
    int? totalBibleChaptersRead,
    int? totalAiConversations,
    DateTime? lastActivityDate,
    int? totalDaysActive,
  }) {
    return UserStats(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalPrayersCompleted:
          totalPrayersCompleted ?? this.totalPrayersCompleted,
      totalBibleChaptersRead:
          totalBibleChaptersRead ?? this.totalBibleChaptersRead,
      totalAiConversations: totalAiConversations ?? this.totalAiConversations,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      totalDaysActive: totalDaysActive ?? this.totalDaysActive,
    );
  }
}

@immutable
class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? parishName;
  final String? dioceseName;
  final String? country;
  final String? city;
  final String preferredLanguage;
  final String preferredBibleTranslation;
  final SubscriptionTier subscriptionTier;
  final DateTime? subscriptionExpiresAt;
  final UserStats stats;
  final List<Badge> badges;
  final List<String> favoritePrayerIds;
  final List<String> favoriteVerseIds;
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final double bibleFontSize;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.parishName,
    this.dioceseName,
    this.country,
    this.city,
    this.preferredLanguage = 'fr',
    this.preferredBibleTranslation = 'LSG',
    this.subscriptionTier = SubscriptionTier.free,
    this.subscriptionExpiresAt,
    this.stats = const UserStats(),
    this.badges = const [],
    this.favoritePrayerIds = const [],
    this.favoriteVerseIds = const [],
    this.notificationsEnabled = true,
    this.darkModeEnabled = false,
    this.bibleFontSize = 18.0,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isPremium =>
      subscriptionTier == SubscriptionTier.premium ||
      subscriptionTier == SubscriptionTier.premiumPlus;

  String get firstName {
    final parts = displayName.split(' ');
    return parts.isNotEmpty ? parts.first : displayName;
  }

  UserProfile copyWith({
    String? displayName,
    String? photoUrl,
    String? parishName,
    String? dioceseName,
    String? country,
    String? city,
    String? preferredLanguage,
    String? preferredBibleTranslation,
    SubscriptionTier? subscriptionTier,
    DateTime? subscriptionExpiresAt,
    UserStats? stats,
    List<Badge>? badges,
    List<String>? favoritePrayerIds,
    List<String>? favoriteVerseIds,
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    double? bibleFontSize,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      parishName: parishName ?? this.parishName,
      dioceseName: dioceseName ?? this.dioceseName,
      country: country ?? this.country,
      city: city ?? this.city,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      preferredBibleTranslation:
          preferredBibleTranslation ?? this.preferredBibleTranslation,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      subscriptionExpiresAt:
          subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      stats: stats ?? this.stats,
      badges: badges ?? this.badges,
      favoritePrayerIds: favoritePrayerIds ?? this.favoritePrayerIds,
      favoriteVerseIds: favoriteVerseIds ?? this.favoriteVerseIds,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      bibleFontSize: bibleFontSize ?? this.bibleFontSize,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          uid == other.uid;

  @override
  int get hashCode => uid.hashCode;
}
