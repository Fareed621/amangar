import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class DateOverrideModel extends Equatable {
  final Timestamp date;
  final bool isBlocked;
  final String? reason;
  final String? bookingId;
  final String? note;

  const DateOverrideModel({
    required this.date,
    required this.isBlocked,
    this.reason,
    this.bookingId,
    this.note,
  });

  factory DateOverrideModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return DateOverrideModel(
      date: data['date'] as Timestamp,
      isBlocked: data['isBlocked'] as bool? ?? false,
      reason: data['reason'] as String?,
      bookingId: data['bookingId'] as String?,
      note: data['note'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'date': date,
        'isBlocked': isBlocked,
        if (reason != null) 'reason': reason,
        if (bookingId != null) 'bookingId': bookingId,
        if (note != null) 'note': note,
      };

  @override
  List<Object?> get props => [date, isBlocked, reason, bookingId, note];
}
