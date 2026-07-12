import 'package:flutter_test/flutter_test.dart';
import 'package:startups_india_media_platform/core/config/profile_role_fields.dart';

void main() {
  const roles = [
    'student',
    'founder',
    'mentor',
    'investor',
    'college',
    'startup_enthusiast',
  ];

  group('roleFieldsFor', () {
    test('every known role has fields with complete, unique keys', () {
      for (final role in roles) {
        final fields = roleFieldsFor(role);
        expect(fields, isNotEmpty, reason: '$role should have fields');
        final keys = fields.map((f) => f.key).toList();
        expect(
          keys.toSet().length,
          keys.length,
          reason: '$role has duplicate keys',
        );
        for (final f in fields) {
          expect(f.key.trim(), isNotEmpty);
          expect(f.label.trim(), isNotEmpty);
          expect(f.displayLabel.trim(), isNotEmpty);
        }
      }
    });

    test('unknown/empty role returns no fields', () {
      expect(roleFieldsFor('mystery'), isEmpty);
      expect(roleFieldsFor(''), isEmpty);
    });

    test('roleSectionLabel is defined for every role and has a fallback', () {
      for (final role in roles) {
        expect(roleSectionLabel(role).trim(), isNotEmpty);
      }
      expect(roleSectionLabel('mystery'), 'Profile Details');
    });
  });
}
