import '../../core/utils/liturgy_calculator.dart';
import '../../domain/entities/liturgical_day.dart';
import '../../domain/repositories/liturgy_repository.dart';
import '../datasources/firebase_liturgy_datasource.dart';
import '../models/liturgical_day_model.dart';

class LiturgyRepositoryImpl implements LiturgyRepository {
  final FirebaseLiturgyDatasource _remote;

  LiturgyRepositoryImpl({required FirebaseLiturgyDatasource remote})
      : _remote = remote;

  @override
  Future<LiturgicalDay> getLiturgicalDay(DateTime date) async {
    // Always compute the base liturgical info locally (no network needed)
    final info = LiturgyCalculator.getDayInfo(date);
    final base = LiturgicalDayModel.fromInfo(info);

    // Try to enrich with readings from Firestore
    try {
      final readings = await _remote.getReadings(date);
      if (readings.isNotEmpty) {
        return base.copyWith(readings: readings);
      }
    } catch (_) {
      // Network unavailable: return base without readings
    }

    return base;
  }

  @override
  Future<List<LiturgicalDay>> getLiturgicalDaysForMonth({
    required int year,
    required int month,
  }) async {
    // Compute all days locally
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final days = <LiturgicalDay>[];

    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(year, month, d);
      final info = LiturgyCalculator.getDayInfo(date);
      days.add(LiturgicalDayModel.fromInfo(info));
    }

    return days;
  }

  @override
  Future<List<LiturgicalReading>> getReadingsForDate(DateTime date) async {
    try {
      return await _remote.getReadings(date);
    } catch (_) {
      return [];
    }
  }
}
