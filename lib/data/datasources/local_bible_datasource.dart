import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/bible_verse_model.dart';

/// Hive-based local cache for Bible chapters and user data.
class LocalBibleDatasource {
  static const String _chapterBoxName = 'bible_chapters';
  static const String _highlightsBoxName = 'bible_highlights';
  static const String _favoritesBoxName = 'bible_favorites';
  static const String _notesBoxName = 'verse_notes';

  Future<Box> get _chapterBox async =>
      Hive.isBoxOpen(_chapterBoxName)
          ? Hive.box(_chapterBoxName)
          : await Hive.openBox(_chapterBoxName);

  Future<Box> get _highlightsBox async =>
      Hive.isBoxOpen(_highlightsBoxName)
          ? Hive.box(_highlightsBoxName)
          : await Hive.openBox(_highlightsBoxName);

  Future<Box> get _favoritesBox async =>
      Hive.isBoxOpen(_favoritesBoxName)
          ? Hive.box(_favoritesBoxName)
          : await Hive.openBox(_favoritesBoxName);

  Future<Box> get _notesBox async =>
      Hive.isBoxOpen(_notesBoxName)
          ? Hive.box(_notesBoxName)
          : await Hive.openBox(_notesBoxName);

  /// Cache key for a chapter.
  String _chapterKey(String bookId, int chapter, String translation) =>
      '${translation}_${bookId}_$chapter';

  /// Save a chapter to local cache.
  Future<void> saveChapter(BibleChapterModel chapter, String bookId) async {
    final box = await _chapterBox;
    final key = _chapterKey(bookId, chapter.chapter, chapter.translation);
    final json = chapter.toJson();
    await box.put(key, jsonEncode(json));
  }

  /// Get a cached chapter. Returns null if not cached.
  Future<BibleChapterModel?> getChapter({
    required String bookId,
    required int chapter,
    required String translation,
  }) async {
    final box = await _chapterBox;
    final key = _chapterKey(bookId, chapter, translation);
    final raw = box.get(key) as String?;
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return BibleChapterModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  /// Check if a chapter is cached.
  Future<bool> isChapterCached({
    required String bookId,
    required int chapter,
    required String translation,
  }) async {
    final box = await _chapterBox;
    final key = _chapterKey(bookId, chapter, translation);
    return box.containsKey(key);
  }

  /// Save a highlight locally.
  Future<void> saveHighlight({
    required String verseId,
    required String color,
  }) async {
    final box = await _highlightsBox;
    await box.put(verseId, {
      'verseId': verseId,
      'color': color,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  /// Remove a highlight locally.
  Future<void> removeHighlight(String verseId) async {
    final box = await _highlightsBox;
    await box.delete(verseId);
  }

  /// Get all local highlights.
  Future<Map<String, String>> getAllHighlights() async {
    final box = await _highlightsBox;
    final result = <String, String>{};
    for (final key in box.keys) {
      final data = box.get(key) as Map<dynamic, dynamic>?;
      if (data != null) {
        result[key as String] = data['color'] as String? ?? '#FFFF00';
      }
    }
    return result;
  }

  /// Save a favorite verse locally.
  Future<void> saveFavorite(String verseId) async {
    final box = await _favoritesBox;
    await box.put(verseId, {'addedAt': DateTime.now().toIso8601String()});
  }

  /// Remove a favorite verse locally.
  Future<void> removeFavorite(String verseId) async {
    final box = await _favoritesBox;
    await box.delete(verseId);
  }

  /// Check if verse is favorited.
  Future<bool> isFavorite(String verseId) async {
    final box = await _favoritesBox;
    return box.containsKey(verseId);
  }

  /// Get all favorite verse IDs.
  Future<List<String>> getAllFavoriteIds() async {
    final box = await _favoritesBox;
    return box.keys.cast<String>().toList();
  }

  /// Save a note locally.
  Future<void> saveNote({
    required String verseId,
    required String note,
  }) async {
    final box = await _notesBox;
    await box.put(verseId, {
      'note': note,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Get a note for a verse.
  Future<String?> getNote(String verseId) async {
    final box = await _notesBox;
    final data = box.get(verseId) as Map<dynamic, dynamic>?;
    return data?['note'] as String?;
  }

  /// Clear all cached chapters (e.g., when changing translation).
  Future<void> clearCache() async {
    final box = await _chapterBox;
    await box.clear();
  }

  /// Initialize all boxes.
  static Future<void> initBoxes() async {
    await Hive.openBox(_chapterBoxName);
    await Hive.openBox(_highlightsBoxName);
    await Hive.openBox(_favoritesBoxName);
    await Hive.openBox(_notesBoxName);
  }
}
