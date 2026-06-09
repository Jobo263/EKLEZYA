import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/prayer_model.dart';
import '../../domain/entities/prayer.dart';
import '../../domain/repositories/prayer_repository.dart';
import 'auth_provider.dart';

// ── Simple in-memory prayer repository ───────────────────────────────────

class PrayerRepositoryImpl implements PrayerRepository {
  final FirebaseFirestore _firestore;
  List<Prayer>? _cachedPrayers;

  PrayerRepositoryImpl(this._firestore);

  @override
  Future<List<Prayer>> getAllPrayers() async {
    if (_cachedPrayers != null) return _cachedPrayers!;
    try {
      final jsonStr = await rootBundle.loadString('assets/data/prayers_seed.json');
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final list = data['prayers'] as List<dynamic>;
      _cachedPrayers = list
          .map((j) => PrayerModel.fromJson(j as Map<String, dynamic>))
          .toList();
      return _cachedPrayers!;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<Prayer>> getPrayersByCategory(PrayerCategory category) async {
    final all = await getAllPrayers();
    return all.where((p) => p.category == category).toList();
  }

  @override
  Future<Prayer?> getPrayerById(String id) async {
    final all = await getAllPrayers();
    try {
      return all.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Prayer>> getDailyPrayers({required bool isMorning}) async {
    final cat = isMorning ? PrayerCategory.morning : PrayerCategory.evening;
    return getPrayersByCategory(cat);
  }

  @override
  Future<void> toggleFavorite({
    required String prayerId,
    required String userId,
  }) async {
    final ref = _firestore
        .collection('users')
        .doc(userId)
        .collection('favorite_prayers')
        .doc(prayerId);
    final doc = await ref.get();
    if (doc.exists) {
      await ref.delete();
    } else {
      await ref.set({'addedAt': FieldValue.serverTimestamp()});
    }
  }

  @override
  Future<List<Prayer>> getFavoritePrayers(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorite_prayers')
        .get();
    final ids = snapshot.docs.map((d) => d.id).toSet();
    final all = await getAllPrayers();
    return all.where((p) => ids.contains(p.id)).toList();
  }

  @override
  Future<void> markPrayerCompleted({
    required String prayerId,
    required String userId,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('prayer_completions')
        .add({
      'prayerId': prayerId,
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<List<Prayer>> searchPrayers({
    required String query,
    required String language,
  }) async {
    final all = await getAllPrayers();
    final q = query.toLowerCase();
    return all
        .where((p) =>
            p.getTitle(language).toLowerCase().contains(q) ||
            p.getBody(language).toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<void> seedPrayersFromJson() async {
    // Prayers are seeded locally; no remote seeding needed for prayers
  }
}

// ── Provider ──────────────────────────────────────────────────────────────

final prayerRepositoryProvider = Provider<PrayerRepository>((ref) {
  return PrayerRepositoryImpl(ref.read(firestoreProvider));
});

// ── All prayers ───────────────────────────────────────────────────────────

final allPrayersProvider = FutureProvider<List<Prayer>>((ref) async {
  return ref.read(prayerRepositoryProvider).getAllPrayers();
});

// ── By category ───────────────────────────────────────────────────────────

final prayersByCategoryProvider =
    FutureProvider.family<List<Prayer>, PrayerCategory>((ref, cat) async {
  return ref.read(prayerRepositoryProvider).getPrayersByCategory(cat);
});

// ── Prayer timer ──────────────────────────────────────────────────────────

enum TimerState { idle, running, paused, completed }

class PrayerTimerNotifier extends StateNotifier<(TimerState, int)> {
  PrayerTimerNotifier() : super((TimerState.idle, 0));

  int _targetSeconds = 0;
  int _elapsed = 0;

  void start(int seconds) {
    _targetSeconds = seconds;
    _elapsed = 0;
    state = (TimerState.running, seconds);
  }

  void tick() {
    if (state.$1 != TimerState.running) return;
    _elapsed++;
    final remaining = _targetSeconds - _elapsed;
    if (remaining <= 0) {
      state = (TimerState.completed, 0);
    } else {
      state = (TimerState.running, remaining);
    }
  }

  void pause() {
    if (state.$1 == TimerState.running) {
      state = (TimerState.paused, state.$2);
    }
  }

  void resume() {
    if (state.$1 == TimerState.paused) {
      state = (TimerState.running, state.$2);
    }
  }

  void reset() {
    _elapsed = 0;
    _targetSeconds = 0;
    state = (TimerState.idle, 0);
  }
}

final prayerTimerProvider =
    StateNotifierProvider<PrayerTimerNotifier, (TimerState, int)>((ref) {
  return PrayerTimerNotifier();
});

// ── Favorite prayers ──────────────────────────────────────────────────────

final favoritePrayersProvider = FutureProvider<List<Prayer>>((ref) async {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return [];
  return ref.read(prayerRepositoryProvider).getFavoritePrayers(uid);
});

// ── Rosary state ──────────────────────────────────────────────────────────

enum RosaryMystery { joyful, sorrowful, glorious, luminous }

class RosaryNotifier extends StateNotifier<(RosaryMystery, int, int)> {
  // State: (mystery, decade 1-5, bead 1-10)
  RosaryNotifier() : super((RosaryMystery.joyful, 1, 0));

  void setMystery(RosaryMystery mystery) {
    state = (mystery, 1, 0);
  }

  void nextBead() {
    final (mystery, decade, bead) = state;
    if (bead < 10) {
      state = (mystery, decade, bead + 1);
    } else if (decade < 5) {
      state = (mystery, decade + 1, 0);
    }
    // else rosary complete
  }

  void previousBead() {
    final (mystery, decade, bead) = state;
    if (bead > 0) {
      state = (mystery, decade, bead - 1);
    } else if (decade > 1) {
      state = (mystery, decade - 1, 10);
    }
  }

  void reset() {
    state = (state.$1, 1, 0);
  }

  bool get isComplete => state.$2 == 5 && state.$3 == 10;
}

final rosaryProvider =
    StateNotifierProvider<RosaryNotifier, (RosaryMystery, int, int)>((ref) {
  return RosaryNotifier();
});
