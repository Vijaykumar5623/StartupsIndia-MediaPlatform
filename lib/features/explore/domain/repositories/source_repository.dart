abstract class SourceRepository {
  Future<bool> toggleFollowSource({
    required String sourceId,
    required bool isFollowing,
  });
}
