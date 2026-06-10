// lib/core/models/rating_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class RatingModel extends Equatable {
  const RatingModel({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.fromUserName,
    this.fromUserPhoto,
    this.bookingId,
    required this.rating,
    this.comment,
    this.createdAt,
  });

  final String id;
  final String fromUserId;
  final String toUserId;
  final String fromUserName;
  final String? fromUserPhoto;
  final String? bookingId;
  final int rating; // 1–5 integer only
  final String? comment;
  final Timestamp? createdAt;

  factory RatingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return RatingModel(
      id: doc.id,
      fromUserId: data['fromUserId'] as String? ?? '',
      toUserId: data['toUserId'] as String? ?? '',
      fromUserName: data['fromUserName'] as String? ?? '',
      fromUserPhoto: data['fromUserPhoto'] as String?,
      bookingId: data['bookingId'] as String?,
      rating: data['rating'] as int? ?? 0,
      comment: data['comment'] as String?,
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'fromUserName': fromUserName,
        'fromUserPhoto': fromUserPhoto,
        'bookingId': bookingId,
        'rating': rating,
        'comment': comment,
        'createdAt': createdAt,
      };

  RatingModel copyWith({
    String? id, String? fromUserId, String? toUserId, String? fromUserName,
    String? fromUserPhoto, String? bookingId, int? rating,
    String? comment, Timestamp? createdAt,
  }) =>
      RatingModel(
        id: id ?? this.id,
        fromUserId: fromUserId ?? this.fromUserId,
        toUserId: toUserId ?? this.toUserId,
        fromUserName: fromUserName ?? this.fromUserName,
        fromUserPhoto: fromUserPhoto ?? this.fromUserPhoto,
        bookingId: bookingId ?? this.bookingId,
        rating: rating ?? this.rating,
        comment: comment ?? this.comment,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props =>
      [id, fromUserId, toUserId, fromUserName, fromUserPhoto, bookingId, rating, comment, createdAt];
}
