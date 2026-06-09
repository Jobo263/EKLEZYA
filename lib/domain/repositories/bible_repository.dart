import '../entities/bible_verse.dart';

abstract class BibleRepository {
  /// Get a specific chapter with all verses.
  Future<BibleChapter> getChapter({
    required String bookId,
    required int chapter,
    required String translation,
    required String language,
  });

  /// Get a single verse.
  Future<BibleVerse> getVerse({
    required String bookId,
    required int chapter,
    required int verse,
    required String translation,
    required String language,
  });

  /// Search across all Bible books.
  Future<List<BibleVerse>> searchBible({
    required String query,
    required String translation,
    required String language,
    int limit = 20,
  });

  /// Get all Bible books metadata.
  Future<List<BibleBook>> getAllBooks({required String language});

  /// Get verse of the day (deterministic by date).
  Future<BibleVerse> getVerseOfDay({
    required DateTime date,
    required String translation,
    required String language,
  });

  /// Highlight a verse (saves to local/Firestore).
  Future<void> highlightVerse({
    required String verseId,
    required String color,
    required String userId,
  });

  /// Remove highlight.
  Future<void> removeHighlight({
    required String verseId,
    required String userId,
  });

  /// Toggle favorite.
  Future<void> toggleFavorite({
    required String verseId,
    required String userId,
  });

  /// Save a note on a verse.
  Future<void> saveVerseNote({
    required String verseId,
    required String note,
    required String userId,
  });

  /// Get all highlighted verses for user.
  Future<List<BibleVerse>> getUserHighlights({required String userId});

  /// Get all favorited verses for user.
  Future<List<BibleVerse>> getUserFavorites({required String userId});

  /// Cache chapter locally (Hive).
  Future<void> cacheChapter(BibleChapter chapter);

  /// Check if chapter is cached.
  Future<bool> isChapterCached({
    required String bookId,
    required int chapter,
    required String translation,
  });
}
