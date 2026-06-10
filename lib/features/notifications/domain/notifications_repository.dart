import '../../../core/models/notification_model.dart';

abstract class NotificationsRepository {
  Stream<List<NotificationModel>> getNotifications(String uid);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String uid);
  Stream<int> getUnreadCount(String uid);
}
