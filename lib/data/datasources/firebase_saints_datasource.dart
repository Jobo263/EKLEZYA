import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/saint_model.dart';

class FirebaseSaintsDatasource {
  final FirebaseFirestore _firestore;

  FirebaseSaintsDatasource(this._firestore);

  static const String _collection = 'saints';

  /// Get saints for a specific month and day.
  Future<List<SaintModel>> getSaintsForDate(DateTime date) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('feastMonth', isEqualTo: date.month)
        .where('feastDayOfMonth', isEqualTo: date.day)
        .get();

    return snapshot.docs
        .map((doc) => SaintModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  /// Get saints for today.
  Future<List<SaintModel>> getSaintsForToday() async {
    return getSaintsForDate(DateTime.now());
  }

  /// Get all saints (paginated).
  Future<List<SaintModel>> getAllSaints({
    int page = 0,
    int pageSize = 20,
    DocumentSnapshot? lastDoc,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection(_collection)
        .orderBy('nameFr')
        .limit(pageSize);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => SaintModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  /// Get a saint by ID.
  Future<SaintModel?> getSaintById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return SaintModel.fromJson({...doc.data()!, 'id': doc.id});
  }

  /// Search saints by name.
  Future<List<SaintModel>> searchSaints(String query) async {
    final queryUpper = query.substring(0, 1).toUpperCase() +
        query.substring(1).toLowerCase();

    final snapshot = await _firestore
        .collection(_collection)
        .where('nameFr', isGreaterThanOrEqualTo: queryUpper)
        .where('nameFr', isLessThan: '${queryUpper}z')
        .limit(20)
        .get();

    return snapshot.docs
        .map((doc) => SaintModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  /// Get saints by category.
  Future<List<SaintModel>> getSaintsByCategory(String category) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('categories', arrayContains: category)
        .get();

    return snapshot.docs
        .map((doc) => SaintModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  /// Upload a saint (admin use).
  Future<void> uploadSaint(SaintModel saint) async {
    await _firestore
        .collection(_collection)
        .doc(saint.id)
        .set(saint.toJson(), SetOptions(merge: true));
  }

  /// Batch upload saints.
  Future<void> batchUploadSaints(List<SaintModel> saints) async {
    final batches = <WriteBatch>[];
    var batch = _firestore.batch();
    var count = 0;

    for (final saint in saints) {
      batch.set(
        _firestore.collection(_collection).doc(saint.id),
        saint.toJson(),
        SetOptions(merge: true),
      );
      count++;
      if (count == 500) {
        batches.add(batch);
        batch = _firestore.batch();
        count = 0;
      }
    }
    if (count > 0) batches.add(batch);

    for (final b in batches) {
      await b.commit();
    }
  }
}
