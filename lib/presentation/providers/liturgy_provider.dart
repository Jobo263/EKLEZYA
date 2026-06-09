import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/firebase_liturgy_datasource.dart';
import '../../data/repositories/liturgy_repository_impl.dart';
import '../../domain/entities/liturgical_day.dart';
import '../../domain/repositories/liturgy_repository.dart';
import '../../domain/usecases/liturgy/get_liturgical_day.dart';
import 'auth_provider.dart';

// ── Repository ────────────────────────────────────────────────────────────

final liturgyRepositoryProvider = Provider<LiturgyRepository>((ref) {
  return LiturgyRepositoryImpl(
    remote: FirebaseLiturgyDatasource(ref.read(firestoreProvider)),
  );
});

// ── Use Case ──────────────────────────────────────────────────────────────

final getLiturgicalDayUseCaseProvider = Provider<GetLiturgicalDayUseCase>((ref) {
  return GetLiturgicalDayUseCase(ref.read(liturgyRepositoryProvider));
});

// ── Today's liturgical day ────────────────────────────────────────────────

final todayLiturgicalDayProvider = FutureProvider<LiturgicalDay>((ref) async {
  final useCase = ref.read(getLiturgicalDayUseCaseProvider);
  return useCase.today();
});

// ── Selected date for calendar ────────────────────────────────────────────

final selectedLiturgicalDateProvider =
    StateProvider<DateTime>((ref) => DateTime.now());

final selectedDayInfoProvider =
    FutureProvider<LiturgicalDay>((ref) async {
  final date = ref.watch(selectedLiturgicalDateProvider);
  final useCase = ref.read(getLiturgicalDayUseCaseProvider);
  return useCase(date);
});

// ── Month calendar data ───────────────────────────────────────────────────

final liturgicalMonthProvider =
    FutureProvider.family<List<LiturgicalDay>, (int, int)>((ref, args) async {
  final (year, month) = args;
  final useCase = ref.read(getLiturgicalDayUseCaseProvider);
  return useCase.forMonth(year: year, month: month);
});

/// Map of date -> LiturgicalDay for the current month (for calendar coloring).
final liturgicalMonthMapProvider =
    FutureProvider.family<Map<DateTime, LiturgicalDay>, (int, int)>(
        (ref, args) async {
  final days = await ref.watch(liturgicalMonthProvider(args).future);
  return {for (final d in days) d.date: d};
});
