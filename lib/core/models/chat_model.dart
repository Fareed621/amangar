// lib/core/models/chat_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ChatModel extends Equatable {
  const ChatModel({
    required this.id,
    required this.participants,
    required this.participantNames,
    required this.participantPhotos,
    this.lastMessage,
    this.lastMessageAt,
    this.lastMessageSenderId,
    required this.unreadCount,
    this.relatedBookingId,
    required this.isActive,
    this.blockedBy,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final List<String> participants;
  final Map<String, String> participantNames;
  final Map<String, String?> participantPhotos;
  final String? lastMessage;
  final Timestamp? lastMessageAt;
  final String? lastMessageSenderId;
  final Map<String, int> unreadCount;
  final String? relatedBookingId;
  final bool isActive;
  final String? blockedBy;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ChatModel(
      id: doc.id,
      participants: List<String>.from(data['participants'] as List? ?? []),
      participantNames: Map<String, String>.from(
          (data['participantNames'] as Map<String, dynamic>? ?? {})
              .map((k, v) => MapEntry(k, v as String? ?? ''))),
      participantPhotos: Map<String, String?>.from(
          (data['participantPhotos'] as Map<String, dynamic>? ?? {})
              .map((k, v) => MapEntry(k, v as String?))),
      lastMessage: data['lastMessage'] as String?,
      lastMessageAt: data['lastMessageAt'] as Timestamp?,
      lastMessageSenderId: data['lastMessageSenderId'] as String?,
      unreadCount: Map<String, int>.from(
          (data['unreadCount'] as Map<String, dynamic>? ?? {})
              .map((k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0))),
      relatedBookingId: data['relatedBookingId'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      blockedBy: data['blockedBy'] as String?,
      createdAt: data['createdAt'] as Timestamp?,
      updatedAt: data['updatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'participants': participants,
        'participantNames': participantNames,
        'participantPhotos': participantPhotos,
        'lastMessage': lastMessage,
        'lastMessageAt': lastMessageAt,
        'lastMessageSenderId': lastMessageSenderId,
        'unreadCount': unreadCount,
        'relatedBookingId': relatedBookingId,
        'isActive': isActive,
        'blockedBy': blockedBy,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  ChatModel copyWith({
    String? id, List<String>? participants,
    Map<String, String>? participantNames,
    Map<String, String?>? participantPhotos,
    String? lastMessage, Timestamp? lastMessageAt,
    String? lastMessageSenderId, Map<String, int>? unreadCount,
    String? relatedBookingId, bool? isActive, String? blockedBy,
    Timestamp? createdAt, Timestamp? updatedAt,
  }) =>
      ChatModel(
        id: id ?? this.id,
        participants: participants ?? this.participants,
        participantNames: participantNames ?? this.participantNames,
        participantPhotos: participantPhotos ?? this.participantPhotos,
        lastMessage: lastMessage ?? this.lastMessage,
        lastMessageAt: lastMessageAt ?? this.lastMessageAt,
        lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
        unreadCount: unreadCount ?? this.unreadCount,
        relatedBookingId: relatedBookingId ?? this.relatedBookingId,
        isActive: isActive ?? this.isActive,
        blockedBy: blockedBy ?? this.blockedBy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  List<Object?> get props => [
        id, participants, participantNames, participantPhotos,
        lastMessage, lastMessageAt, lastMessageSenderId, unreadCount,
        relatedBookingId, isActive, blockedBy, createdAt, updatedAt,
      ];
}
