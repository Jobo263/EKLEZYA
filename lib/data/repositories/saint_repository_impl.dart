import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/entities/saint.dart';
import '../../domain/repositories/saint_repository.dart';
import '../datasources/firebase_saints_datasource.dart';
import '../models/saint_model.dart';

class SaintRepositoryImpl implements SaintRepository {
  final FirebaseSaintsDatasource _remote;

  SaintRepositoryImpl({required FirebaseSaintsDatasource remote})
      : _remote = remote;

  @override
  Future<List<Saint>> getSaintsForToday() async {
    try {
      final saints = await _remote.getSaintsForToday();
      if (saints.isNotEmpty) return saints;
      // Fallback to seed data
      return _getSaintsFromSeedForDate(DateTime.now());
    } catch (_) {
      return _getSaintsFromSeedForDate(DateTime.now());
    }
  }

  @override
  Future<List<Saint>> getSaintsForDate(DateTime date) async {
    try {
      final saints = await _remote.getSaintsForDate(date);
      if (saints.isNotEmpty) return saints;
      return _getSaintsFromSeedForDate(date);
    } catch (_) {
      return _getSaintsFromSeedForDate(date);
    }
  }

  @override
  Future<List<Saint>> getAllSaints({int page = 0, int pageSize = 20}) async {
    try {
      return await _remote.getAllSaints(page: page, pageSize: pageSize);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Saint?> getSaintById(String id) async {
    return _remote.getSaintById(id);
  }

  @override
  Future<List<Saint>> searchSaints(String query) async {
    return _remote.searchSaints(query);
  }

  @override
  Future<List<Saint>> getSaintsByCategory(String category) async {
    return _remote.getSaintsByCategory(category);
  }

  @override
  Future<void> seedSaintsFromJson() async {
    try {
      final jsonStr =
          await rootBundle.loadString('assets/data/saints_seed.json');
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final saintsJson = data['saints'] as List<dynamic>;
      final saints = saintsJson
          .map((j) => SaintModel.fromJson(j as Map<String, dynamic>))
          .toList();
      await _remote.batchUploadSaints(saints);
    } catch (e) {
      // Seed failure is non-critical
    }
  }

  Future<List<Saint>> _getSaintsFromSeedForDate(DateTime date) async {
    try {
      final jsonStr =
          await rootBundle.loadString('assets/data/saints_seed.json');
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final saintsJson = data['saints'] as List<dynamic>;
      final saints = saintsJson
          .map((j) => SaintModel.fromJson(j as Map<String, dynamic>))
          .where((s) =>
              s.feastMonth == date.month && s.feastDayOfMonth == date.day)
          .toList();
      return saints;
    } catch (_) {
      return [];
    }
  }
}
