import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/models/notification_model.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../data/notifications_repository_impl.dart';
import '../../domain/notifications_repository.dart';

part 'notifications_provider.g.dart';

@riverpod
NotificationsRepository notificationsRepository(
    NotificationsRepositoryRef ref) {
  return NotificationsRepositoryImpl(FirebaseFirestore.instance);
}

@riverpod
Stream<List<NotificationModel>> notifications(NotificationsRef ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return Stream.value([]);
  return ref.watch(notificationsRepositoryProvider).getNotifications(user.uid);
}

@riverpod
Stream<int> notificationUnreadCount(NotificationUnreadCountRef ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return Stream.value(0);
  return ref.watch(notificationsRepositoryProvider).getUnreadCount(user.uid);
}

@riverpod
Future<void> markNotificationRead(MarkNotificationReadRef ref, String id) {
  return ref.read(notificationsRepositoryProvider).markAsRead(id);
}

@riverpod
Stream<int> totalUnreadCount(TotalUnreadCountRef ref) {
  return ref.watch(notificationUnreadCountProvider.stream);
}
