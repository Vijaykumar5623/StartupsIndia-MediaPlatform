import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/firebase_providers.dart';
import '../utils/app_error_reporter.dart';

/// Upper-bound sentinel for Firestore prefix queries: a very high Private-Use
/// code point so that `[query, query + sentinel)` captures every string that
/// starts with `query`.
const String _prefixSentinel = '\u{f8ff}';

/// Read-only access to the `colleges` reference collection (seeded from the
/// AISHE dataset — see `scripts/seed_colleges.py`).
///
/// Search is a case-insensitive **prefix** match on `nameLower`, optionally
/// scoped to a [state]. Prefix (not substring) search is a Firestore
/// constraint; it is the standard, index-friendly approach for autocomplete.
class CollegeRepository {
  CollegeRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _colleges =>
      _firestore.collection('colleges');

  /// Returns up to [limit] college names whose lowercase name starts with
  /// [query], within [state] when it is non-empty. Ordered alphabetically.
  ///
  /// Requires the composite index (state ASC, nameLower ASC) declared in
  /// `firestore.indexes.json`. Returns an empty list on error so the picker can
  /// fall back to the "Other" free-text entry.
  Future<List<String>> searchColleges({
    required String state,
    required String query,
    int limit = 30,
  }) async {
    final trimmedState = state.trim();
    final q = query.trim().toLowerCase();

    try {
      Query<Map<String, dynamic>> ref = _colleges;
      if (trimmedState.isNotEmpty) {
        ref = ref.where('state', isEqualTo: trimmedState);
      }
      ref = ref.orderBy('nameLower');
      if (q.isNotEmpty) {
        ref = ref.startAt([q]).endAt(['$q$_prefixSentinel']);
      }
      ref = ref.limit(limit);

      final snapshot = await ref.get();
      return snapshot.docs
          .map((doc) => (doc.data()['name'] ?? '').toString())
          .where((name) => name.isNotEmpty)
          .toList();
    } catch (error, stackTrace) {
      AppErrorReporter.record(
        error,
        stackTrace,
        reason: 'College search failed (state="$state", query="$query")',
      );
      return const [];
    }
  }
}

final collegeRepositoryProvider = Provider<CollegeRepository>((ref) {
  return CollegeRepository(ref.watch(firebaseFirestoreProvider));
});
