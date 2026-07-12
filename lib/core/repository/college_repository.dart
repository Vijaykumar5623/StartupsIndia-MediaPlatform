import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/app_error_reporter.dart';

/// Read-only access to the bundled college list (asset built from the AISHE
/// dataset — see `scripts/build_colleges_asset.py`).
///
/// The data ships inside the app as a JSON asset grouped by state, so search is
/// fully offline with no Firestore reads/writes. Because it runs in memory it
/// can do a **substring** (contains) match rather than the prefix-only match a
/// Firestore query would allow. The asset is parsed once on first use and
/// cached for the app's lifetime.
class CollegeRepository {
  CollegeRepository({this.assetPath = 'assets/data/colleges_in.json'});

  final String assetPath;

  /// Canonical state label → alphabetically sorted college names.
  Map<String, List<String>>? _byState;
  Future<void>? _loading;

  Future<void> _ensureLoaded() => _loading ??= _load();

  Future<void> _load() async {
    try {
      final raw = await rootBundle.loadString(assetPath);
      final decoded = await compute(_decodeColleges, raw);
      _byState = decoded;
    } catch (error, stackTrace) {
      AppErrorReporter.record(
        error,
        stackTrace,
        reason: 'Failed to load colleges asset ($assetPath)',
      );
      _byState = const {};
    }
  }

  /// Returns up to [limit] college names containing [query] (case-insensitive),
  /// within [state] when it is non-empty; otherwise across all states. Results
  /// keep the asset's alphabetical order.
  ///
  /// Returns an empty list on any failure so the picker can fall back to the
  /// "Other" free-text entry.
  Future<List<String>> searchColleges({
    required String state,
    required String query,
    int limit = 30,
  }) async {
    await _ensureLoaded();
    final byState = _byState;
    if (byState == null || byState.isEmpty) return const [];

    final trimmedState = state.trim();
    final q = query.trim().toLowerCase();

    final Iterable<String> pool = trimmedState.isNotEmpty
        ? (byState[trimmedState] ?? const [])
        : byState.values.expand((names) => names);

    final results = <String>[];
    for (final name in pool) {
      if (q.isEmpty || name.toLowerCase().contains(q)) {
        results.add(name);
        if (results.length >= limit) break;
      }
    }
    return results;
  }
}

/// Runs off the UI isolate via [compute]: decodes the grouped-by-state JSON.
Map<String, List<String>> _decodeColleges(String raw) {
  final decoded = jsonDecode(raw) as Map<String, dynamic>;
  return decoded.map(
    (state, names) => MapEntry(
      state,
      (names as List).map((name) => name.toString()).toList(growable: false),
    ),
  );
}

final collegeRepositoryProvider = Provider<CollegeRepository>((ref) {
  return CollegeRepository();
});
