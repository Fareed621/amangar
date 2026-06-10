// lib/core/models/message_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class MessageModel extends Equatable {
  const MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.type,
    this.mediaUrl,
    this.timestamp,
    required this.isRead,
    this.readAt,
  });

  final String id;
  final String senderId;
  final String text;
  final String type; // 'text' | 'image'
  final String? mediaUrl;
  final Timestamp? timestamp;
  final bool isRead;
  final Timestamp? readAt;

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return MessageModel(
      id: doc.id,
      senderId: data['senderId'] as String? ?? '',
      text: data['text'] as String? ?? '',
      type: data['type'] as String? ?? 'text',
      mediaUrl: data['mediaUrl'] as String?,
      timestamp: data['timestamp'] as Timestamp?,
      isRead: data['isRead'] as bool? ?? false,
      readAt: data['readAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'senderId': senderId,
        'text': text,
        'type': type,
        'mediaUrl': mediaUrl,
        'timestamp': timestamp,
        'isRead': isRead,
        'readAt': readAt,
      };

  MessageModel copyWith({
    String? id, String? senderId, String? text, String? type,
    String? mediaUrl, Timestamp? timestamp, bool? isRead, Timestamp? readAt,
  }) =>
      MessageModel(
        id: id ?? this.id,
        senderId: senderId ?? this.senderId,
        text: text ?? this.text,
        type: type ?? this.type,
        mediaUrl: mediaUrl ?? this.mediaUrl,
        timestamp: timestamp ?? this.timestamp,
        isRead: isRead ?? this.isRead,
        readAt: readAt ?? this.readAt,
      );

  @override
  List<Object?> get props =>
      [id, senderId, text, type, mediaUrl, timestamp, isRead, readAt];
}
