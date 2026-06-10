// lib/core/models/notification_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class NotificationModel extends Equatable {
  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.bookingId,
    this.chatId,
    this.senderId,
    this.senderName,
    this.senderPhoto,
    required this.actionScreen,
    this.actionParams,
    required this.isRead,
    required this.fcmSent,
    this.fcmSentAt,
    this.fcmMessageId,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String type;
  final String title;
  final String body;
  final String? bookingId;
  final String? chatId;
  final String? senderId;
  final String? senderName;
  final String? senderPhoto;
  final String actionScreen;
  final Map<String, String>? actionParams;
  final bool isRead;
  final bool fcmSent;
  final Timestamp? fcmSentAt;
  final String? fcmMessageId;
  final Timestamp? createdAt;

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      type: data['type'] as String? ?? '',
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      bookingId: data['bookingId'] as String?,
      chatId: data['chatId'] as String?,
      senderId: data['senderId'] as String?,
      senderName: data['senderName'] as String?,
      senderPhoto: data['senderPhoto'] as String?,
      actionScreen: data['actionScreen'] as String? ?? '',
      actionParams: (data['actionParams'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v as String? ?? '')),
      isRead: data['isRead'] as bool? ?? false,
      fcmSent: data['fcmSent'] as bool? ?? false,
      fcmSentAt: data['fcmSentAt'] as Timestamp?,
      fcmMessageId: data['fcmMessageId'] as String?,
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'type': type,
        'title': title,
        'body': body,
        'bookingId': bookingId,
        'chatId': chatId,
        'senderId': senderId,
        'senderName': senderName,
        'senderPhoto': senderPhoto,
        'actionScreen': actionScreen,
        'actionParams': actionParams,
        'isRead': isRead,
        'fcmSent': fcmSent,
        'fcmSentAt': fcmSentAt,
        'fcmMessageId': fcmMessageId,
        'createdAt': createdAt,
      };

  NotificationModel copyWith({
    String? id, String? userId, String? type, String? title, String? body,
    String? bookingId, String? chatId, String? senderId, String? senderName,
    String? senderPhoto, String? actionScreen,
    Map<String, String>? actionParams, bool? isRead, bool? fcmSent,
    Timestamp? fcmSentAt, String? fcmMessageId, Timestamp? createdAt,
  }) =>
      NotificationModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        type: type ?? this.type,
        title: title ?? this.title,
        body: body ?? this.body,
        bookingId: bookingId ?? this.bookingId,
        chatId: chatId ?? this.chatId,
        senderId: senderId ?? this.senderId,
        senderName: senderName ?? this.senderName,
        senderPhoto: senderPhoto ?? this.senderPhoto,
        actionScreen: actionScreen ?? this.actionScreen,
        actionParams: actionParams ?? this.actionParams,
        isRead: isRead ?? this.isRead,
        fcmSent: fcmSent ?? this.fcmSent,
        fcmSentAt: fcmSentAt ?? this.fcmSentAt,
        fcmMessageId: fcmMessageId ?? this.fcmMessageId,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props => [
        id, userId, type, title, body, bookingId, chatId, senderId,
        senderName, senderPhoto, actionScreen, actionParams, isRead,
        fcmSent, fcmSentAt, fcmMessageId, createdAt,
      ];
}
