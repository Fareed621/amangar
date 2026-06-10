import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/services/encryption_service.dart';
import '../../../search/presentation/providers/search_provider.dart';

part 'verification_notifier.g.dart';

final _log = Logger();

class VerificationState {
  final String? cnicFrontUrl;
  final String? cnicBackUrl;
  final String? certUrl;
  final double? uploadProgress;
  final bool isUploading;
  final bool isSubmitting;
  final bool isSuccess;
  final String? error;

  const VerificationState({
    this.cnicFrontUrl,
    this.cnicBackUrl,
    this.certUrl,
    this.uploadProgress,
    this.isUploading = false,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.error,
  });

  bool get canSubmit => cnicFrontUrl != null && cnicBackUrl != null && !isUploading && !isSubmitting;

  VerificationState copyWith({
    String? cnicFrontUrl,
    String? cnicBackUrl,
    String? certUrl,
    double? uploadProgress,
    bool? isUploading,
    bool? isSubmitting,
    bool? isSuccess,
    String? error,
  }) =>
      VerificationState(
        cnicFrontUrl: cnicFrontUrl ?? this.cnicFrontUrl,
        cnicBackUrl: cnicBackUrl ?? this.cnicBackUrl,
        certUrl: certUrl ?? this.certUrl,
        uploadProgress: uploadProgress,
        isUploading: isUploading ?? this.isUploading,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        isSuccess: isSuccess ?? this.isSuccess,
        error: error,
      );
}

@riverpod
class VerificationNotifier extends _$VerificationNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // LOCAL-FIRST: FirebaseStorage removed — restore when upgrading to Blaze plan.

  @override
  VerificationState build() => const VerificationState();

  /// LOCAL-FIRST: Simulates a CNIC document upload with animated progress.
  /// A 2-second delay (4 × 500ms steps) mimics network latency.
  /// Restore putFile() implementation when upgrading to Blaze plan.
  Future<void> uploadCNIC(Object? file, bool isFront) async {
    final uid = ref.read(currentUserProvider).valueOrNull?.uid;
    if (uid == null) return;

    state = state.copyWith(isUploading: true, uploadProgress: 0.0, error: null);
    try {
      for (var i = 1; i <= 4; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        state = state.copyWith(uploadProgress: i / 4);
      }

      final side = isFront ? 'Front' : 'Back';
      final url = 'https://placehold.co/600x400/1a73e8/white/png?text=CNIC+$side';
      _log.i('[Verification] CNIC $side mock URL set (local-first): $url');

      if (isFront) {
        state = state.copyWith(cnicFrontUrl: url, isUploading: false, uploadProgress: null);
      } else {
        state = state.copyWith(cnicBackUrl: url, isUploading: false, uploadProgress: null);
      }
    } catch (e, st) {
      _log.e('[Verification] CNIC upload simulation failed', error: e, stackTrace: st);
      state = state.copyWith(isUploading: false, error: e.toString());
    }
  }

  /// LOCAL-FIRST: Simulates a certification document upload with animated progress.
  Future<void> uploadCertification(Object? file) async {
    final uid = ref.read(currentUserProvider).valueOrNull?.uid;
    if (uid == null) return;

    state = state.copyWith(isUploading: true, uploadProgress: 0.0, error: null);
    try {
      for (var i = 1; i <= 4; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        state = state.copyWith(uploadProgress: i / 4);
      }
      const url = 'https://placehold.co/600x400/34a853/white/png?text=Certification';
      _log.i('[Verification] Certification mock URL set (local-first): $url');
      state = state.copyWith(certUrl: url, isUploading: false, uploadProgress: null);
    } catch (e, st) {
      _log.e('[Verification] Certification upload simulation failed', error: e, stackTrace: st);
      state = state.copyWith(isUploading: false, error: e.toString());
    }
  }

  Future<void> submitForVerification() async {
    if (!state.canSubmit) return;
    final uid = ref.read(currentUserProvider).valueOrNull?.uid;
    if (uid == null) return;

    state = state.copyWith(isSubmitting: true, error: null);
    try {
      // LOCAL-FIRST: Simulate backend review with a 2-second delay, then
      // auto-approve by writing the verified state directly to Firestore.
      _log.i('[Verification] Starting client-side verification simulation for uid=$uid');
      await Future.delayed(const Duration(seconds: 2));

      final enc = EncryptionService.instance;
      final updates = <String, dynamic>{
        'isVerified': true,
        'verificationStatus': 'approved',
        'verifiedAt': Timestamp.now(),
        'verificationDocuments.cnicFront':
            state.cnicFrontUrl != null ? enc.encryptData(state.cnicFrontUrl!) : null,
        'verificationDocuments.cnicFrontUploadedAt': Timestamp.now(),
        'verificationDocuments.cnicBack':
            state.cnicBackUrl != null ? enc.encryptData(state.cnicBackUrl!) : null,
        'verificationDocuments.cnicBackUploadedAt': Timestamp.now(),
        'verificationAttempts': FieldValue.increment(1),
        'updatedAt': Timestamp.now(),
      };
      if (state.certUrl != null) {
        updates['verificationDocuments.certification'] = enc.encryptData(state.certUrl!);
        updates['verificationDocuments.certificationUploadedAt'] = Timestamp.now();
      }

      await _firestore.doc('users/$uid/providerProfile/profile').update(updates);
      _log.i('[Verification] Provider uid=$uid auto-approved (local-first) ✓');
      state = state.copyWith(isSubmitting: false, isSuccess: true);
      ref.invalidate(providerDetailProvider(uid));
    } catch (e, st) {
      _log.e('[Verification] Submission failed', error: e, stackTrace: st);
      state = state.copyWith(isSubmitting: false, error: e.toString());
    }
  }
}
