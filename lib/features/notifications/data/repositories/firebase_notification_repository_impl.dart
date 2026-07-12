import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';

class FirebaseNotificationRepositoryImpl implements NotificationRepository {
  final FirebaseFirestore _firestore;

  FirebaseNotificationRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _userNotifications(String userId) =>
      _firestore.collection('users').doc(userId).collection('notifications');

  @override
  Stream<List<AppNotification>> watchUserNotifications(String userId) {
    return _userNotifications(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppNotification.fromFirestore(doc))
            .toList());
  }

  @override
  Future<void> addNotification(
    String userId,
    AppNotification notification,
  ) async {
    await _userNotifications(userId).add(notification.toFirestore());
  }

  @override
  Future<void> markAsRead(String userId, String notificationId) async {
    await _userNotifications(userId).doc(notificationId).update({'isRead': true});
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    final batch = _firestore.batch();
    final snapshot = await _userNotifications(userId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  @override
  Future<void> deleteNotification(String userId, String notificationId) async {
    await _userNotifications(userId).doc(notificationId).delete();
  }

  @override
  Future<void> deleteAllNotifications(String userId) async {
    final snapshot = await _userNotifications(userId).get();
    if (snapshot.docs.isEmpty) return;
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  @override
  Future<void> saveFcmToken(String userId, String token) async {
    await _firestore.collection('users').doc(userId).set({
      'fcmTokens': FieldValue.arrayUnion([token]),
    }, SetOptions(merge: true));
  }
}
