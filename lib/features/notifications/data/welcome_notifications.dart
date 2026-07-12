import '../../../core/services/local_notification_service.dart';
import '../../../core/utils/app_error_reporter.dart';
import '../domain/models/app_notification.dart';
import '../domain/repositories/notification_repository.dart';

/// Default notifications sent to a user the moment they sign up: a welcome and
/// a nudge to complete their profile. They are written to the in-app
/// notifications list and also surfaced as system-tray notifications.
class WelcomeNotifications {
  const WelcomeNotifications._();

  /// Builds the notification list (pure — no side effects), newest first.
  static List<AppNotification> build(DateTime now) {
    return [
      AppNotification(
        id: '',
        type: NotificationType.news,
        title: 'Welcome to StartupsIndia 🎉',
        subtitle:
            'Explore startup news, communities and events curated for you.',
        // Newest so it sits at the top of the list.
        createdAt: now,
        avatarLabel: 'SI',
      ),
      AppNotification(
        id: '',
        type: NotificationType.news,
        title: 'Complete your profile',
        subtitle:
            'Add your details to get personalised recommendations and connect '
            'with founders, mentors and investors.',
        createdAt: now.subtract(const Duration(seconds: 1)),
        avatarLabel: 'SI',
      ),
    ];
  }

  /// Writes the welcome notifications for [userId] and shows them locally.
  /// Best-effort: never throws, so it can't block onboarding.
  static Future<void> sendFor(
    String userId,
    NotificationRepository repository, {
    bool showLocal = true,
  }) async {
    try {
      final items = build(DateTime.now());
      for (var i = 0; i < items.length; i++) {
        await repository.addNotification(userId, items[i]);
        if (showLocal) {
          await LocalNotificationService.instance.show(
            id: 900000 + i,
            title: items[i].title,
            body: items[i].subtitle,
          );
        }
      }
    } catch (error, stackTrace) {
      AppErrorReporter.record(
        error,
        stackTrace,
        reason: 'Failed to send welcome notifications',
      );
    }
  }
}
