import 'package:flutter_test/flutter_test.dart';
import 'package:startups_india_media_platform/features/notifications/data/welcome_notifications.dart';

void main() {
  group('WelcomeNotifications.build', () {
    final now = DateTime(2026, 7, 11, 10, 0, 0);
    final items = WelcomeNotifications.build(now);

    test('produces a welcome and a complete-profile notification', () {
      expect(items.length, 2);
      expect(items[0].title, contains('Welcome'));
      expect(items[1].title, contains('Complete your profile'));
    });

    test('welcome is newest so it sorts to the top', () {
      expect(items[0].createdAt.isAfter(items[1].createdAt), isTrue);
    });

    test('every item has content and no preset id', () {
      for (final n in items) {
        expect(n.id, isEmpty);
        expect(n.title.trim(), isNotEmpty);
        expect(n.subtitle.trim(), isNotEmpty);
        expect(n.avatarLabel, isNotEmpty);
      }
    });
  });
}
