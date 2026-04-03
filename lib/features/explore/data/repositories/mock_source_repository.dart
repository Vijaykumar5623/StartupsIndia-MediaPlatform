import '../../domain/repositories/source_repository.dart';

class MockSourceRepository implements SourceRepository {
  final Map<String, bool> _followStateBySourceId = <String, bool>{};

  @override
  Future<bool> toggleFollowSource({
    required String sourceId,
    required bool isFollowing,
  }) async {
    _followStateBySourceId[sourceId] = isFollowing;
    return _followStateBySourceId[sourceId] ?? isFollowing;
  }
}
