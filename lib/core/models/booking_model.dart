// lib/core/models/booking_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class BookingModel extends Equatable {
  const BookingModel({
    required this.id,
    required this.hirerId,
    required this.providerId,
    required this.serviceType,
    required this.serviceCategory,
    required this.status,
    required this.dates,
    required this.isRecurring,
    required this.recurringDays,
    this.recurringStartDate,
    this.recurringEndDate,
    required this.startTime,
    required this.endTime,
    required this.totalDurationHours,
    required this.displayPrice,
    required this.priceBreakdown,
    this.notes,
    required this.hirerName,
    this.hirerPhoto,
    required this.providerName,
    this.providerPhoto,
    this.providerPhone,
    required this.hirerRated,
    required this.providerRated,
    this.hirerRatingId,
    this.providerRatingId,
    required this.ratingReminderSent,
    required this.reminderSent,
    this.lastReminderSentAt,
    this.nextServiceTimestamp,
    required this.hirerConfirmedPayment,
    required this.providerConfirmedReceipt,
    this.cancelledBy,
    this.cancelledAt,
    this.refundPolicy,
    this.refundPercentage,
    this.cancellationReason,
    this.cancellationReasonCode,
    this.completedAt,
    this.completedBy,
    this.createdAt,
    this.updatedAt,
    required this.schemaVersion,
  });

  final String id;
  final String hirerId;
  final String providerId;
  final String serviceType;
  final String serviceCategory;
  final String status;
  final List<Timestamp> dates;
  final bool isRecurring;
  final List<String> recurringDays;
  final Timestamp? recurringStartDate;
  final Timestamp? recurringEndDate;
  final String startTime;
  final String endTime;
  final double totalDurationHours;
  final int displayPrice;
  final Map<String, dynamic> priceBreakdown;
  final String? notes;
  final String hirerName;
  final String? hirerPhoto;
  final String providerName;
  final String? providerPhoto;
  final String? providerPhone;
  final bool hirerRated;
  final bool providerRated;
  final String? hirerRatingId;
  final String? providerRatingId;
  final bool ratingReminderSent;
  final bool reminderSent;
  final Timestamp? lastReminderSentAt;
  final Timestamp? nextServiceTimestamp;
  final bool hirerConfirmedPayment;
  final bool providerConfirmedReceipt;
  final String? cancelledBy;
  final Timestamp? cancelledAt;
  final String? refundPolicy;
  final int? refundPercentage;
  final String? cancellationReason;
  final String? cancellationReasonCode;
  final Timestamp? completedAt;
  final String? completedBy;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final int schemaVersion;

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return BookingModel(
      id: doc.id,
      hirerId: data['hirerId'] as String? ?? '',
      providerId: data['providerId'] as String? ?? '',
      serviceType: data['serviceType'] as String? ?? 'full_time',
      serviceCategory: data['serviceCategory'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      dates: (data['dates'] as List<dynamic>? ?? [])
          .map((e) => e as Timestamp)
          .toList(),
      isRecurring: data['isRecurring'] as bool? ?? false,
      recurringDays: List<String>.from(data['recurringDays'] as List? ?? []),
      recurringStartDate: data['recurringStartDate'] as Timestamp?,
      recurringEndDate: data['recurringEndDate'] as Timestamp?,
      startTime: data['startTime'] as String? ?? '09:00',
      endTime: data['endTime'] as String? ?? '17:00',
      totalDurationHours: (data['totalDurationHours'] as num?)?.toDouble() ?? 0.0,
      displayPrice: data['displayPrice'] as int? ?? 0,
      priceBreakdown: data['priceBreakdown'] as Map<String, dynamic>? ?? {},
      notes: data['notes'] as String?,
      hirerName: data['hirerName'] as String? ?? '',
      hirerPhoto: data['hirerPhoto'] as String?,
      providerName: data['providerName'] as String? ?? '',
      providerPhoto: data['providerPhoto'] as String?,
      providerPhone: data['providerPhone'] as String?,
      hirerRated: data['hirerRated'] as bool? ?? false,
      providerRated: data['providerRated'] as bool? ?? false,
      hirerRatingId: data['hirerRatingId'] as String?,
      providerRatingId: data['providerRatingId'] as String?,
      ratingReminderSent: data['ratingReminderSent'] as bool? ?? false,
      reminderSent: data['reminderSent'] as bool? ?? false,
      lastReminderSentAt: data['lastReminderSentAt'] as Timestamp?,
      nextServiceTimestamp: data['nextServiceTimestamp'] as Timestamp?,
      hirerConfirmedPayment: data['hirerConfirmedPayment'] as bool? ?? false,
      providerConfirmedReceipt: data['providerConfirmedReceipt'] as bool? ?? false,
      cancelledBy: data['cancelledBy'] as String?,
      cancelledAt: data['cancelledAt'] as Timestamp?,
      refundPolicy: data['refundPolicy'] as String?,
      refundPercentage: data['refundPercentage'] as int?,
      cancellationReason: data['cancellationReason'] as String?,
      cancellationReasonCode: data['cancellationReasonCode'] as String?,
      completedAt: data['completedAt'] as Timestamp?,
      completedBy: data['completedBy'] as String?,
      createdAt: data['createdAt'] as Timestamp?,
      updatedAt: data['updatedAt'] as Timestamp?,
      schemaVersion: data['schemaVersion'] as int? ?? 2,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'hirerId': hirerId,
        'providerId': providerId,
        'serviceType': serviceType,
        'serviceCategory': serviceCategory,
        'status': status,
        'dates': dates,
        'isRecurring': isRecurring,
        'recurringDays': recurringDays,
        'recurringStartDate': recurringStartDate,
        'recurringEndDate': recurringEndDate,
        'startTime': startTime,
        'endTime': endTime,
        'totalDurationHours': totalDurationHours,
        'displayPrice': displayPrice,
        'priceBreakdown': priceBreakdown,
        'notes': notes,
        'hirerName': hirerName,
        'hirerPhoto': hirerPhoto,
        'providerName': providerName,
        'providerPhoto': providerPhoto,
        'providerPhone': providerPhone,
        'hirerRated': hirerRated,
        'providerRated': providerRated,
        'hirerRatingId': hirerRatingId,
        'providerRatingId': providerRatingId,
        'ratingReminderSent': ratingReminderSent,
        'reminderSent': reminderSent,
        'lastReminderSentAt': lastReminderSentAt,
        'nextServiceTimestamp': nextServiceTimestamp,
        'hirerConfirmedPayment': hirerConfirmedPayment,
        'providerConfirmedReceipt': providerConfirmedReceipt,
        'cancelledBy': cancelledBy,
        'cancelledAt': cancelledAt,
        'refundPolicy': refundPolicy,
        'refundPercentage': refundPercentage,
        'cancellationReason': cancellationReason,
        'cancellationReasonCode': cancellationReasonCode,
        'completedAt': completedAt,
        'completedBy': completedBy,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'schemaVersion': schemaVersion,
      };

  BookingModel copyWith({
    String? id, String? hirerId, String? providerId, String? serviceType,
    String? serviceCategory, String? status, List<Timestamp>? dates,
    bool? isRecurring, List<String>? recurringDays,
    Timestamp? recurringStartDate, Timestamp? recurringEndDate,
    String? startTime, String? endTime, double? totalDurationHours,
    int? displayPrice, Map<String, dynamic>? priceBreakdown, String? notes,
    String? hirerName, String? hirerPhoto, String? providerName,
    String? providerPhoto, String? providerPhone,
    bool? hirerRated, bool? providerRated,
    String? hirerRatingId, String? providerRatingId,
    bool? ratingReminderSent, bool? reminderSent,
    Timestamp? lastReminderSentAt, Timestamp? nextServiceTimestamp,
    bool? hirerConfirmedPayment, bool? providerConfirmedReceipt,
    String? cancelledBy, Timestamp? cancelledAt,
    String? refundPolicy, int? refundPercentage,
    String? cancellationReason, String? cancellationReasonCode,
    Timestamp? completedAt, String? completedBy,
    Timestamp? createdAt, Timestamp? updatedAt, int? schemaVersion,
  }) =>
      BookingModel(
        id: id ?? this.id,
        hirerId: hirerId ?? this.hirerId,
        providerId: providerId ?? this.providerId,
        serviceType: serviceType ?? this.serviceType,
        serviceCategory: serviceCategory ?? this.serviceCategory,
        status: status ?? this.status,
        dates: dates ?? this.dates,
        isRecurring: isRecurring ?? this.isRecurring,
        recurringDays: recurringDays ?? this.recurringDays,
        recurringStartDate: recurringStartDate ?? this.recurringStartDate,
        recurringEndDate: recurringEndDate ?? this.recurringEndDate,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        totalDurationHours: totalDurationHours ?? this.totalDurationHours,
        displayPrice: displayPrice ?? this.displayPrice,
        priceBreakdown: priceBreakdown ?? this.priceBreakdown,
        notes: notes ?? this.notes,
        hirerName: hirerName ?? this.hirerName,
        hirerPhoto: hirerPhoto ?? this.hirerPhoto,
        providerName: providerName ?? this.providerName,
        providerPhoto: providerPhoto ?? this.providerPhoto,
        providerPhone: providerPhone ?? this.providerPhone,
        hirerRated: hirerRated ?? this.hirerRated,
        providerRated: providerRated ?? this.providerRated,
        hirerRatingId: hirerRatingId ?? this.hirerRatingId,
        providerRatingId: providerRatingId ?? this.providerRatingId,
        ratingReminderSent: ratingReminderSent ?? this.ratingReminderSent,
        reminderSent: reminderSent ?? this.reminderSent,
        lastReminderSentAt: lastReminderSentAt ?? this.lastReminderSentAt,
        nextServiceTimestamp: nextServiceTimestamp ?? this.nextServiceTimestamp,
        hirerConfirmedPayment: hirerConfirmedPayment ?? this.hirerConfirmedPayment,
        providerConfirmedReceipt: providerConfirmedReceipt ?? this.providerConfirmedReceipt,
        cancelledBy: cancelledBy ?? this.cancelledBy,
        cancelledAt: cancelledAt ?? this.cancelledAt,
        refundPolicy: refundPolicy ?? this.refundPolicy,
        refundPercentage: refundPercentage ?? this.refundPercentage,
        cancellationReason: cancellationReason ?? this.cancellationReason,
        cancellationReasonCode: cancellationReasonCode ?? this.cancellationReasonCode,
        completedAt: completedAt ?? this.completedAt,
        completedBy: completedBy ?? this.completedBy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        schemaVersion: schemaVersion ?? this.schemaVersion,
      );

  @override
  List<Object?> get props => [
        id, hirerId, providerId, serviceType, serviceCategory, status, dates,
        isRecurring, recurringDays, recurringStartDate, recurringEndDate,
        startTime, endTime, totalDurationHours, displayPrice, priceBreakdown,
        notes, hirerName, hirerPhoto, providerName, providerPhoto, providerPhone,
        hirerRated, providerRated, hirerRatingId, providerRatingId,
        ratingReminderSent, reminderSent, lastReminderSentAt, nextServiceTimestamp,
        hirerConfirmedPayment, providerConfirmedReceipt, cancelledBy, cancelledAt,
        refundPolicy, refundPercentage, cancellationReason, cancellationReasonCode,
        completedAt, completedBy, createdAt, updatedAt, schemaVersion,
      ];
}
