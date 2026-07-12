import 'package:flutter_test/flutter_test.dart';
import 'package:startups_india_media_platform/core/utils/password_validator.dart';

void main() {
  group('validateStrongPassword', () {
    test('accepts a strong password', () {
      expect(validateStrongPassword('Abcdef1@'), isNull);
    });

    test('rejects empty', () {
      expect(validateStrongPassword(''), isNotNull);
      expect(validateStrongPassword(null), isNotNull);
    });

    test('rejects too short', () {
      expect(validateStrongPassword('Ab1@'), contains('8'));
    });

    test('requires an uppercase letter', () {
      expect(validateStrongPassword('abcdef1@'), contains('uppercase'));
    });

    test('requires a number', () {
      expect(validateStrongPassword('Abcdefg@'), contains('number'));
    });

    test('requires a special character', () {
      expect(validateStrongPassword('Abcdefg1'), contains('special'));
    });
  });
}
