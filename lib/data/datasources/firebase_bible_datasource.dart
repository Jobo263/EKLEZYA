import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bible_verse_model.dart';

class FirebaseBibleDatasource {
  final FirebaseFirestore _firestore;

  FirebaseBibleDatasource(this._firestore);

  static const String _collection = 'bible';
  static const String _highlightsCollection = 'highlights';
  static const String _notesCollection = 'verse_notes';

  /// Fetch all verses for a chapter.
  Future<BibleChapterModel> getChapter({
    required String bookId,
    required int chapter,
    required String translation,
    required String language,
  }) async {
    final querySnapshot = await _firestore
        .collection(_collection)
        .doc(translation)
        .collection('books')
        .doc(bookId)
        .collection('chapters')
        .doc('$chapter')
        .collection('verses')
        .orderBy('verse')
        .get();

    final verses = querySnapshot.docs
        .map((doc) => BibleVerseModel.fromJson({
              ...doc.data(),
              'id': doc.id,
              'bookId': bookId,
              'translation': translation,
              'language': language,
            }))
        .toList();

    // Get book name from first verse or book metadata
    final bookMeta = await _firestore
        .collection(_collection)
        .doc(translation)
        .collection('books')
        .doc(bookId)
        .get();

    final bookName = bookMeta.data()?['name'] as String? ?? bookId;

    return BibleChapterModel(
      book: bookName,
      chapter: chapter,
      verses: verses,
      translation: translation,
    );
  }

  /// Search verses by text.
  Future<List<BibleVerseModel>> searchVerses({
    required String query,
    required String translation,
    required String language,
    int limit = 20,
  }) async {
    // Firestore doesn't support full-text search natively.
    // In production, use Algolia or Firebase Extensions (Search).
    // This implementation does a simple prefix search on text.
    final queryLower = query.toLowerCase();
    final snapshot = await _firestore
        .collection(_collection)
        .doc(translation)
        .collection('search_index')
        .where('keywords', arrayContains: queryLower)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => BibleVerseModel.fromJson({
              ...doc.data(),
              'id': doc.id,
              'translation': translation,
              'language': language,
            }))
        .toList();
  }

  /// Get verse of the day (stored in Firestore by date).
  Future<BibleVerseModel?> getVerseOfDay({
    required DateTime date,
    required String translation,
    required String language,
  }) async {
    final dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final doc = await _firestore
        .collection('verse_of_day')
        .doc(dateKey)
        .get();

    if (!doc.exists || doc.data() == null) return null;

    return BibleVerseModel.fromJson({
      ...doc.data()!,
      'translation': translation,
      'language': language,
    });
  }

  /// Save a highlight for a user.
  Future<void> saveHighlight({
    required String userId,
    required String verseId,
    required String color,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection(_highlightsCollection)
        .doc(verseId)
        .set({
      'verseId': verseId,
      'color': color,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Remove a highlight.
  Future<void> removeHighlight({
    required String userId,
    required String verseId,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection(_highlightsCollection)
        .doc(verseId)
        .delete();
  }

  /// Get all highlights for a user.
  Future<List<Map<String, dynamic>>> getUserHighlights(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection(_highlightsCollection)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Save a verse note.
  Future<void> saveNote({
    required String userId,
    required String verseId,
    required String note,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection(_notesCollection)
        .doc(verseId)
        .set({
      'verseId': verseId,
      'note': note,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Toggle favorite.
  Future<void> toggleFavorite({
    required String userId,
    required String verseId,
  }) async {
    final ref = _firestore
        .collection('users')
        .doc(userId)
        .collection('favorite_verses')
        .doc(verseId);
    final doc = await ref.get();
    if (doc.exists) {
      await ref.delete();
    } else {
      await ref.set({
        'verseId': verseId,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
