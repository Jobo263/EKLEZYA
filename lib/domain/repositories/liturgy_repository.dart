import '../entities/liturgical_day.dart';

abstract class LiturgyRepository {
  /// Get liturgical day info for a given date.
  Future<LiturgicalDay> getLiturgicalDay(DateTime date);

  /// Get liturgical days for a range (for calendar display).
  Future<List<LiturgicalDay>> getLiturgicalDaysForMonth({
    required int year,
    required int month,
  });

  /// Get readings for a specific date from Firestore.
  Future<List<LiturgicalReading>> getReadingsForDate(DateTime date);
}
