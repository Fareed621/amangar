import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/models/report_model.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../data/reports_repository_impl.dart';
import '../../domain/reports_repository.dart';

part 'report_provider.g.dart';

@riverpod
ReportsRepository reportsRepository(ReportsRepositoryRef ref) {
  return ReportsRepositoryImpl(FirebaseFirestore.instance);
}

class ReportState {
  final List<String> selectedReasons;
  final String details;
  final bool alsoBlock;
  final bool isSubmitting;
  final String? error;

  ReportState({
    this.selectedReasons = const [],
    this.details = '',
    this.alsoBlock = false,
    this.isSubmitting = false,
    this.error,
  });

  ReportState copyWith({
    List<String>? selectedReasons,
    String? details,
    bool? alsoBlock,
    bool? isSubmitting,
    String? error,
  }) {
    return ReportState(
      selectedReasons: selectedReasons ?? this.selectedReasons,
      details: details ?? this.details,
      alsoBlock: alsoBlock ?? this.alsoBlock,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }
}

@riverpod
class ReportNotifier extends _$ReportNotifier {
  @override
  ReportState build() => ReportState();

  void toggleReason(String reason) {
    final reasons = List<String>.from(state.selectedReasons);
    if (reasons.contains(reason)) {
      reasons.remove(reason);
    } else {
      reasons.add(reason);
    }
    state = state.copyWith(selectedReasons: reasons);
  }

  void setDetails(String details) {
    state = state.copyWith(details: details);
  }

  void setAlsoBlock(bool block) {
    state = state.copyWith(alsoBlock: block);
  }

  Future<bool> submit({
    required UserModel targetUser,
    String? bookingId,
    String? chatId,
  }) async {
    final currentUser = ref.read(currentUserProvider).valueOrNull;
    if (currentUser == null) return false;

    state = state.copyWith(isSubmitting: true);
    try {
      final report = ReportModel(
        id: '',
        reporterId: currentUser.uid,
        reporterName: currentUser.name,
        reportedUserId: targetUser.uid,
        reportedUserName: targetUser.name,
        relatedBookingId: bookingId,
        relatedChatId: chatId,
        reasons: state.selectedReasons,
        details: state.details,
        status: 'pending',
        createdAt: Timestamp.now(),
      );

      await ref.read(reportsRepositoryProvider).submitReport(report);

      if (state.alsoBlock) {
        await ref.read(reportsRepositoryProvider).blockUser(
          myUid: currentUser.uid,
          targetUid: targetUser.uid,
          targetName: targetUser.name,
        );
      }

      state = ReportState(); // Reset
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: 'Failed to submit report');
      return false;
    }
  }
}
