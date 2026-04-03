class UserModel {
  final String uid;
  final String username;
  final String fullName;
  final String email;
  final String phone;
  final String displayName;
  final String bio;
  final String avatarUrl;
  final String websiteUrl;
  final int followersCount;
  final int followingCount;
  final int newsCount;

  const UserModel({
    required this.uid,
    this.username = '',
    this.fullName = '',
    this.email = '',
    this.phone = '',
    required this.displayName,
    required this.bio,
    required this.avatarUrl,
    required this.websiteUrl,
    required this.followersCount,
    required this.followingCount,
    required this.newsCount,
  });

  UserModel copyWith({
    String? uid,
    String? username,
    String? fullName,
    String? email,
    String? phone,
    String? displayName,
    String? bio,
    String? avatarUrl,
    String? websiteUrl,
    int? followersCount,
    int? followingCount,
    int? newsCount,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      newsCount: newsCount ?? this.newsCount,
    );
  }
}
