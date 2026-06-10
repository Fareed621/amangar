// lib/core/models/withdrawal_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class WithdrawalModel extends Equatable {
  const WithdrawalModel({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.providerPhone,
    required this.amount,
    required this.method,
    required this.accountDetails,
    required this.accountHolderName,
    required this.status,
    this.adminNote,
    this.transactionReference,
    this.processedAt,
    this.processedBy,
    this.failureReason,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String providerId;
  final String providerName;
  final String providerPhone;
  final int amount;
  final String method; // 'jazzcash' | 'easypaisa' | 'bank'
  final String accountDetails;
  final String accountHolderName;
  final String status; // 'pending' | 'completed' | 'failed'
  final String? adminNote;
  final String? transactionReference;
  final Timestamp? processedAt;
  final String? processedBy;
  final String? failureReason;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  factory WithdrawalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return WithdrawalModel(
      id: doc.id,
      providerId: data['providerId'] as String? ?? '',
      providerName: data['providerName'] as String? ?? '',
      providerPhone: data['providerPhone'] as String? ?? '',
      amount: data['amount'] as int? ?? 0,
      method: data['method'] as String? ?? '',
      accountDetails: data['accountDetails'] as String? ?? '',
      accountHolderName: data['accountHolderName'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      adminNote: data['adminNote'] as String?,
      transactionReference: data['transactionReference'] as String?,
      processedAt: data['processedAt'] as Timestamp?,
      processedBy: data['processedBy'] as String?,
      failureReason: data['failureReason'] as String?,
      createdAt: data['createdAt'] as Timestamp?,
      updatedAt: data['updatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'providerId': providerId,
        'providerName': providerName,
        'providerPhone': providerPhone,
        'amount': amount,
        'method': method,
        'accountDetails': accountDetails,
        'accountHolderName': accountHolderName,
        'status': status,
        'adminNote': adminNote,
        'transactionReference': transactionReference,
        'processedAt': processedAt,
        'processedBy': processedBy,
        'failureReason': failureReason,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  WithdrawalModel copyWith({
    String? id, String? providerId, String? providerName, String? providerPhone,
    int? amount, String? method, String? accountDetails,
    String? accountHolderName, String? status, String? adminNote,
    String? transactionReference, Timestamp? processedAt, String? processedBy,
    String? failureReason, Timestamp? createdAt, Timestamp? updatedAt,
  }) =>
      WithdrawalModel(
        id: id ?? this.id,
        providerId: providerId ?? this.providerId,
        providerName: providerName ?? this.providerName,
        providerPhone: providerPhone ?? this.providerPhone,
        amount: amount ?? this.amount,
        method: method ?? this.method,
        accountDetails: accountDetails ?? this.accountDetails,
        accountHolderName: accountHolderName ?? this.accountHolderName,
        status: status ?? this.status,
        adminNote: adminNote ?? this.adminNote,
        transactionReference: transactionReference ?? this.transactionReference,
        processedAt: processedAt ?? this.processedAt,
        processedBy: processedBy ?? this.processedBy,
        failureReason: failureReason ?? this.failureReason,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  List<Object?> get props => [
        id, providerId, providerName, providerPhone, amount, method,
        accountDetails, accountHolderName, status, adminNote,
        transactionReference, processedAt, processedBy, failureReason,
        createdAt, updatedAt,
      ];
}
