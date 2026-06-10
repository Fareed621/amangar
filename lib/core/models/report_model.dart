// lib/core/models/report_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ReportModel extends Equatable {
  const ReportModel({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    required this.reportedUserId,
    required this.reportedUserName,
    required this.reasons,
    this.details,
    this.evidenceUrl,
    this.relatedBookingId,
    this.relatedChatId,
    required this.status,
    this.adminNote,
    this.resolvedAt,
    this.resolvedBy,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String reporterId;
  final String reporterName;
  final String reportedUserId;
  final String reportedUserName;
  final List<String> reasons;
  final String? details;
  final String? evidenceUrl;
  final String? relatedBookingId;
  final String? relatedChatId;
  final String status; // 'pending' | 'under_review' | 'resolved' | 'dismissed'
  final String? adminNote;
  final Timestamp? resolvedAt;
  final String? resolvedBy;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ReportModel(
      id: doc.id,
      reporterId: data['reporterId'] as String? ?? '',
      reporterName: data['reporterName'] as String? ?? '',
      reportedUserId: data['reportedUserId'] as String? ?? '',
      reportedUserName: data['reportedUserName'] as String? ?? '',
      reasons: List<String>.from(data['reasons'] as List? ?? []),
      details: data['details'] as String?,
      evidenceUrl: data['evidenceUrl'] as String?,
      relatedBookingId: data['relatedBookingId'] as String?,
      relatedChatId: data['relatedChatId'] as String?,
      status: data['status'] as String? ?? 'pending',
      adminNote: data['adminNote'] as String?,
      resolvedAt: data['resolvedAt'] as Timestamp?,
      resolvedBy: data['resolvedBy'] as String?,
      createdAt: data['createdAt'] as Timestamp?,
      updatedAt: data['updatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'reporterId': reporterId,
        'reporterName': reporterName,
        'reportedUserId': reportedUserId,
        'reportedUserName': reportedUserName,
        'reasons': reasons,
        'details': details,
        'evidenceUrl': evidenceUrl,
        'relatedBookingId': relatedBookingId,
        'relatedChatId': relatedChatId,
        'status': status,
        'adminNote': adminNote,
        'resolvedAt': resolvedAt,
        'resolvedBy': resolvedBy,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  ReportModel copyWith({
    String? id, String? reporterId, String? reporterName,
    String? reportedUserId, String? reportedUserName, List<String>? reasons,
    String? details, String? evidenceUrl, String? relatedBookingId,
    String? relatedChatId, String? status, String? adminNote,
    Timestamp? resolvedAt, String? resolvedBy,
    Timestamp? createdAt, Timestamp? updatedAt,
  }) =>
      ReportModel(
        id: id ?? this.id,
        reporterId: reporterId ?? this.reporterId,
        reporterName: reporterName ?? this.reporterName,
        reportedUserId: reportedUserId ?? this.reportedUserId,
        reportedUserName: reportedUserName ?? this.reportedUserName,
        reasons: reasons ?? this.reasons,
        details: details ?? this.details,
        evidenceUrl: evidenceUrl ?? this.evidenceUrl,
        relatedBookingId: relatedBookingId ?? this.relatedBookingId,
        relatedChatId: relatedChatId ?? this.relatedChatId,
        status: status ?? this.status,
        adminNote: adminNote ?? this.adminNote,
        resolvedAt: resolvedAt ?? this.resolvedAt,
        resolvedBy: resolvedBy ?? this.resolvedBy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  List<Object?> get props => [
        id, reporterId, reporterName, reportedUserId, reportedUserName,
        reasons, details, evidenceUrl, relatedBookingId, relatedChatId,
        status, adminNote, resolvedAt, resolvedBy, createdAt, updatedAt,
      ];
}
