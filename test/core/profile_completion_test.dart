import 'package:flutter_test/flutter_test.dart';
import 'package:startups_india_media_platform/core/config/profile_completion.dart';
import 'package:startups_india_media_platform/core/models/user_model.dart';

UserModel _base({
  String fullName = '',
  String phone = '',
  String avatarUrl = '',
  String bio = '',
  String websiteUrl = '',
  String role = 'student',
  Map<String, dynamic> roleDetails = const {},
}) {
  return UserModel(
    uid: 'u1',
    username: 'handle',
    fullName: fullName,
    email: 'a@b.com',
    phone: phone,
    displayName: fullName,
    bio: bio,
    avatarUrl: avatarUrl,
    websiteUrl: websiteUrl,
    followersCount: 0,
    followingCount: 0,
    newsCount: 0,
    role: role,
    roleDetails: roleDetails,
  );
}

void main() {
  group('computeProfileCompletion', () {
    test('empty optional fields → 0%', () {
      final c = computeProfileCompletion(_base());
      expect(c.filled, 0);
      expect(c.percent, 0);
      expect(c.isComplete, isFalse);
    });

    test('a fully filled student profile → 100%', () {
      final c = computeProfileCompletion(
        _base(
          fullName: 'Asha Rao',
          phone: '+91 9876543210',
          avatarUrl: 'https://img/x.png',
          bio: 'Building things',
          websiteUrl: 'https://asha.dev',
          role: 'student',
          roleDetails: {
            'location': 'Bengaluru, Karnataka',
            'state': 'Karnataka',
            'collegeName': 'IISc',
            'degreeCourse': 'B.Tech',
            'year': '2nd Year',
            'branch': 'CSE',
            'skills': 'Flutter',
            'lookingFor': 'Internship',
          },
        ),
      );
      expect(c.percent, 100);
      expect(c.isComplete, isTrue);
    });

    test('partial fill is between 0 and 100', () {
      final c = computeProfileCompletion(
        _base(fullName: 'Asha', bio: 'hi', role: 'mentor'),
      );
      expect(c.percent, greaterThan(0));
      expect(c.percent, lessThan(100));
    });

    test('unknown role still counts shared fields', () {
      final c = computeProfileCompletion(
        _base(fullName: 'X', role: 'weird_role'),
      );
      // 6 shared checks, 1 filled → 17%
      expect(c.total, 6);
      expect(c.filled, 1);
    });
  });
}
