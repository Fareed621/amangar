// lib/core/models/earnings_ledger_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class EarningsLedgerModel extends Equatable {
  const EarningsLedgerModel({
    required this.id,
    required this.bookingId,
    this.hirerName,
    required this.serviceCategory,
    required this.serviceType,
    required this.amount,
    required this.entryType,
    this.bookingDate,
    this.createdAt,
  });

  final String id;
  final String bookingId;
  final String? hirerName;
  final String serviceCategory;
  final String serviceType;
  final int amount;
  final String entryType; // 'credit' | 'debit'
  final Timestamp? bookingDate;
  final Timestamp? createdAt;

  factory EarningsLedgerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return EarningsLedgerModel(
      id: doc.id,
      bookingId: data['bookingId'] as String? ?? '',
      hirerName: data['hirerName'] as String?,
      serviceCategory: data['serviceCategory'] as String? ?? '',
      serviceType: data['serviceType'] as String? ?? '',
      amount: data['amount'] as int? ?? 0,
      entryType: data['entryType'] as String? ?? 'credit',
      bookingDate: data['bookingDate'] as Timestamp?,
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'bookingId': bookingId,
        'hirerName': hirerName,
        'serviceCategory': serviceCategory,
        'serviceType': serviceType,
        'amount': amount,
        'entryType': entryType,
        'bookingDate': bookingDate,
        'createdAt': createdAt,
      };

  EarningsLedgerModel copyWith({
    String? id, String? bookingId, String? hirerName,
    String? serviceCategory, String? serviceType, int? amount,
    String? entryType, Timestamp? bookingDate, Timestamp? createdAt,
  }) =>
      EarningsLedgerModel(
        id: id ?? this.id,
        bookingId: bookingId ?? this.bookingId,
        hirerName: hirerName ?? this.hirerName,
        serviceCategory: serviceCategory ?? this.serviceCategory,
        serviceType: serviceType ?? this.serviceType,
        amount: amount ?? this.amount,
        entryType: entryType ?? this.entryType,
        bookingDate: bookingDate ?? this.bookingDate,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props => [
        id, bookingId, hirerName, serviceCategory, serviceType,
        amount, entryType, bookingDate, createdAt,
      ];
}
