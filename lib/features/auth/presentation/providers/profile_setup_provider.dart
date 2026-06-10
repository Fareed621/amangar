// lib/features/auth/presentation/providers/profile_setup_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/services/encryption_service.dart';
import '../../../../core/utils/validators.dart';

part 'profile_setup_provider.g.dart';

final _log = Logger();

class ProfileSetupState {
  const ProfileSetupState({
    this.isSubmitting = false,
    this.isUploadingPhoto = false,
    this.uploadProgress = 0.0,
    this.error,
  });

  final bool isSubmitting;
  final bool isUploadingPhoto;
  final double uploadProgress;
  final String? error;

  ProfileSetupState copyWith({
    bool? isSubmitting,
    bool? isUploadingPhoto,
    double? uploadProgress,
    String? error,
  }) =>
      ProfileSetupState(
        isSubmitting: isSubmitting ?? this.isSubmitting,
        isUploadingPhoto: isUploadingPhoto ?? this.isUploadingPhoto,
        uploadProgress: uploadProgress ?? this.uploadProgress,
        error: error,
      );
}

@riverpod
class ProfileSetupNotifier extends _$ProfileSetupNotifier {
  @override
  ProfileSetupState build() => const ProfileSetupState();

  /// LOCAL-FIRST: Returns a deterministic public avatar URL based on the user's
  /// UID. No bytes are uploaded to Firebase Storage.
  /// Restore the original putFile() implementation when upgrading to Blaze plan.
  Future<String?> uploadPhoto(Object? file) async {
    state = state.copyWith(isUploadingPhoto: true, uploadProgress: 0.0);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw const AppException('Not authenticated.');

      // Simulate brief processing so the loading overlay is visible.
      await Future.delayed(const Duration(milliseconds: 800));
      state = state.copyWith(uploadProgress: 1.0);

      final url = 'https://i.pravatar.cc/300?u=${user.uid}';
      _log.i('[ProfileSetup] Avatar URL generated (local-first): $url');

      state = state.copyWith(isUploadingPhoto: false, uploadProgress: 0.0);
      return url;
    } catch (e, st) {
      _log.e('[ProfileSetup] Avatar generation failed', error: e, stackTrace: st);
      state = state.copyWith(isUploadingPhoto: false, error: 'Photo setup failed.');
      return null;
    }
  }

  Future<bool> submit({
    required String role,
    required String name,
    required String phone,
    required String city,
    String? photoUrl,
  }) async {
    state = const ProfileSetupState(isSubmitting: true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      _log.i('[ProfileSetup] Submitting profile — role=$role');
      if (user == null) throw const AppException('Not authenticated.');

      final storedPhone = Validators.toStoredPhone(phone.trim());
      final _enc = EncryptionService.instance;

      final data = {
        'name': name.trim(),
        'phone': _enc.encryptData(storedPhone),
        'city': city,
        'profilePhoto': _enc.encryptData(
          photoUrl ?? 'https://i.pravatar.cc/300?u=${user.uid}',
        ),
        'onboardingComplete': role == 'hirer' ? true : false,
        'rating': 0.0,
        'totalReviews': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .doc(FirestorePaths.user(user.uid))
          .set(data, SetOptions(merge: true));

      _log.i('[ProfileSetup] Profile written to Firestore ✓');
      state = const ProfileSetupState();
      return true;
    } on FirebaseException catch (e) {
      final ex = AppException.fromFirebaseCode(e.code);
      state = ProfileSetupState(error: ex.message);
      return false;
    } on AppException catch (e) {
      state = ProfileSetupState(error: e.message);
      return false;
    } catch (e, st) {
      _log.e('[ProfileSetup] Submit failed', error: e, stackTrace: st);
      state = const ProfileSetupState(
        error: 'Something went wrong. Please try again.',
      );
      return false;
    }
  }

  void clearError() => state = state.copyWith(error: null);
}
