import '../entities/saint.dart';

abstract class SaintRepository {
  /// Get saint(s) for today's feast day.
  Future<List<Saint>> getSaintsForToday();

  /// Get saint(s) for a specific date.
  Future<List<Saint>> getSaintsForDate(DateTime date);

  /// Get all saints (paginated).
  Future<List<Saint>> getAllSaints({int page = 0, int pageSize = 20});

  /// Get a saint by ID.
  Future<Saint?> getSaintById(String id);

  /// Search saints by name.
  Future<List<Saint>> searchSaints(String query);

  /// Get saints by category.
  Future<List<Saint>> getSaintsByCategory(String category);

  /// Seed saints from local JSON (first launch).
  Future<void> seedSaintsFromJson();
}
