import 'package:flutter_test/flutter_test.dart';
import 'package:startups_india_media_platform/core/repository/college_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CollegeRepository (bundled asset)', () {
    final repo = CollegeRepository();

    test('substring search within a state returns matches', () async {
      final results = await repo.searchColleges(
        state: 'Karnataka',
        query: 'college',
        limit: 5,
      );
      expect(results, isNotEmpty);
      expect(results.length, lessThanOrEqualTo(5));
      expect(
        results.every((name) => name.toLowerCase().contains('college')),
        isTrue,
      );
    });

    test('empty query within a state browses that state', () async {
      final results = await repo.searchColleges(
        state: 'Maharashtra',
        query: '',
        limit: 10,
      );
      expect(results, isNotEmpty);
      expect(results.length, lessThanOrEqualTo(10));
    });

    test('unknown state yields no results', () async {
      final results = await repo.searchColleges(
        state: 'Atlantis',
        query: 'x',
      );
      expect(results, isEmpty);
    });
  });
}
