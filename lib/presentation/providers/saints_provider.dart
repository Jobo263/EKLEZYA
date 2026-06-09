import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/firebase_saints_datasource.dart';
import '../../data/repositories/saint_repository_impl.dart';
import '../../domain/entities/saint.dart';
import '../../domain/repositories/saint_repository.dart';
import '../../domain/usecases/saints/get_saint_of_day.dart';
import 'auth_provider.dart';

// ── Repository ────────────────────────────────────────────────────────────

final saintRepositoryProvider = Provider<SaintRepository>((ref) {
  return SaintRepositoryImpl(
    remote: FirebaseSaintsDatasource(ref.read(firestoreProvider)),
  );
});

// ── Use case ──────────────────────────────────────────────────────────────

final getSaintOfDayUseCaseProvider = Provider<GetSaintOfDayUseCase>((ref) {
  return GetSaintOfDayUseCase(ref.read(saintRepositoryProvider));
});

// ── Saint of today ────────────────────────────────────────────────────────

final saintOfDayProvider = FutureProvider<List<Saint>>((ref) async {
  final useCase = ref.read(getSaintOfDayUseCaseProvider);
  return useCase();
});

// ── All saints (paginated) ────────────────────────────────────────────────

final allSaintsProvider = FutureProvider<List<Saint>>((ref) async {
  final repo = ref.read(saintRepositoryProvider);
  return repo.getAllSaints();
});

// ── Saint detail ──────────────────────────────────────────────────────────

final saintDetailProvider =
    FutureProvider.family<Saint?, String>((ref, id) async {
  final repo = ref.read(saintRepositoryProvider);
  return repo.getSaintById(id);
});

// ── Search ────────────────────────────────────────────────────────────────

class SaintsSearchNotifier extends StateNotifier<AsyncValue<List<Saint>>> {
  final SaintRepository _repo;

  SaintsSearchNotifier(this._repo) : super(const AsyncData([]));

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncData([]);
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.searchSaints(query));
  }

  void clear() => state = const AsyncData([]);
}

final saintsSearchProvider =
    StateNotifierProvider<SaintsSearchNotifier, AsyncValue<List<Saint>>>((ref) {
  return SaintsSearchNotifier(ref.read(saintRepositoryProvider));
});
