import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/liturgical_day_model.dart';

class FirebaseLiturgyDatasource {
  final FirebaseFirestore _firestore;

  FirebaseLiturgyDatasource(this._firestore);

  static const String _collection = 'liturgical_calendar';

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  /// Get liturgical day data from Firestore (readings, collect, etc.)
  Future<LiturgicalDayModel?> getLiturgicalDayFromFirestore(DateTime date) async {
    final doc = await _firestore
        .collection(_collection)
        .doc(_dateKey(date))
        .get();

    if (!doc.exists || doc.data() == null) return null;
    return LiturgicalDayModel.fromJson({...doc.data()!, 'date': _dateKey(date)});
  }

  /// Get readings for a specific date.
  Future<List<LiturgicalReadingModel>> getReadings(DateTime date) async {
    final snapshot = await _firestore
        .collection(_collection)
        .doc(_dateKey(date))
        .collection('readings')
        .orderBy('order')
        .get();

    return snapshot.docs
        .map((doc) => LiturgicalReadingModel.fromJson(doc.data()))
        .toList();
  }

  /// Get liturgical days for a whole month.
  Future<List<Map<String, dynamic>>> getMonthData({
    required int year,
    required int month,
  }) async {
    final startKey = '$year-${month.toString().padLeft(2, '0')}-01';
    final endMonth = month == 12 ? 1 : month + 1;
    final endYear = month == 12 ? year + 1 : year;
    final endKey = '$endYear-${endMonth.toString().padLeft(2, '0')}-01';

    final snapshot = await _firestore
        .collection(_collection)
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: startKey)
        .where(FieldPath.documentId, isLessThan: endKey)
        .get();

    return snapshot.docs
        .map((doc) => {...doc.data(), 'date': doc.id})
        .toList();
  }
}
