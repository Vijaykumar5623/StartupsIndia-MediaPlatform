import '../models/user_model.dart';
import 'profile_role_fields.dart';

/// Computes how complete a user's profile is, for the progress bar shown on the
/// personal profile page.
///
/// Completion counts the optional fields a user can fill from Edit Profile:
/// shared fields (full name, phone, avatar, bio, website, location) plus the
/// role-specific detail keys (from `profile_role_fields.dart`). The mandatory
/// username/email are excluded, so the bar reflects optional completion —
/// filling everything reaches 100%.

class ProfileCompletion {
  final int filled;
  final int total;

  const ProfileCompletion(this.filled, this.total);

  double get fraction => total == 0 ? 0 : filled / total;
  int get percent => (fraction * 100).round();
  bool get isComplete => total > 0 && filled >= total;
}

/// Returns the [ProfileCompletion] for [user].
ProfileCompletion computeProfileCompletion(UserModel user) {
  bool filledValue(String value) => value.trim().isNotEmpty;
  bool filledDetail(String key) =>
      filledValue(user.roleDetails[key]?.toString() ?? '');

  final checks = <bool>[
    filledValue(user.fullName),
    filledValue(user.phone),
    filledValue(user.avatarUrl),
    filledValue(user.bio),
    filledValue(user.websiteUrl),
    filledDetail('location'),
    ...roleFieldsFor(user.role).map((field) => filledDetail(field.key)),
  ];

  final filled = checks.where((done) => done).length;
  return ProfileCompletion(filled, checks.length);
}
