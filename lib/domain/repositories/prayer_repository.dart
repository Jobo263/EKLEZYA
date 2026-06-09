import '../entities/prayer.dart';

abstract class PrayerRepository {
  /// Get all prayers.
  Future<List<Prayer>> getAllPrayers();

  /// Get prayers by category.
  Future<List<Prayer>> getPrayersByCategory(PrayerCategory category);

  /// Get a single prayer by ID.
  Future<Prayer?> getPrayerById(String id);

  /// Get daily prayers (morning or evening).
  Future<List<Prayer>> getDailyPrayers({required bool isMorning});

  /// Toggle favorite prayer.
  Future<void> toggleFavorite({
    required String prayerId,
    required String userId,
  });

  /// Get user's favorite prayers.
  Future<List<Prayer>> getFavoritePrayers(String userId);

  /// Mark prayer as completed.
  Future<void> markPrayerCompleted({
    required String prayerId,
    required String userId,
  });

  /// Search prayers.
  Future<List<Prayer>> searchPrayers({
    required String query,
    required String language,
  });

  /// Seed prayers from local JSON (first launch).
  Future<void> seedPrayersFromJson();
}
