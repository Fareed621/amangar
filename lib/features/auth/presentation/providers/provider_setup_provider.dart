// lib/features/auth/presentation/providers/provider_setup_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/exceptions/app_exception.dart';

part 'provider_setup_provider.g.dart';

class ProviderSetupState {
  const ProviderSetupState({
    this.isSubmitting = false,
    this.error,
  });

  final bool isSubmitting;
  final String? error;

  ProviderSetupState copyWith({bool? isSubmitting, String? error}) =>
      ProviderSetupState(
        isSubmitting: isSubmitting ?? this.isSubmitting,
        error: error,
      );
}

@riverpod
class ProviderSetupNotifier extends _$ProviderSetupNotifier {
  @override
  ProviderSetupState build() => const ProviderSetupState();

  /// Batch write: creates providerProfile doc + updates user doc.
  /// Matches api-contracts.md Section 3.1 exactly.
  Future<bool> submit({
    required String serviceCategory,
    required List<String> skills,
    required List<String> languages,
    required int fullTimeRate,
    required int partTimeRate,
    required int experienceYears,
    required String experienceLevel,
    String? bio,
  }) async {
    state = const ProviderSetupState(isSubmitting: true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw const AppException('Not authenticated.');

      final profileData = {
        'uid': user.uid,
        'services': [serviceCategory],
        'serviceCategory': serviceCategory,
        'skills': skills,
        'languages': languages,
        'fullTimeRate': fullTimeRate,
        'partTimeRate': partTimeRate,
        'experienceYears': experienceYears,
        'experienceLevel': experienceLevel,
        'bio': bio?.trim().isEmpty == true ? null : bio?.trim(),
        'portfolioPhotos': <String>[],
        'portfolioCount': 0,
        'isVerified': false,
        'verificationStatus': 'not_started',
        'verifiedAt': null,
        'verificationDocuments': <String, dynamic>{},
        'verificationRejectionReason': null,
        'verificationAttempts': 0,
        'rating': 0.0,
        'totalReviews': 0,
        'totalCompletedBookings': 0,
        'currentMonthBookings': 0,
        'currentMonthEarnings': 0,
        'totalEarningsTracked': 0,
        'totalCancellationsByProvider': 0,
        'lastCancelledAt': null,
        'availabilitySummary': null,
        'nextAvailableDate': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'schemaVersion': 2,
      };

      final batch = FirebaseFirestore.instance.batch();
      batch.set(
        FirebaseFirestore.instance
            .doc(FirestorePaths.providerProfile(user.uid)),
        profileData,
      );
      batch.update(
        FirebaseFirestore.instance.doc(FirestorePaths.user(user.uid)),
        {
          'serviceCategory': serviceCategory,
          'onboardingComplete': true,
          'rating': 0.0,
          'totalReviews': 0,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
      await batch.commit();

      state = const ProviderSetupState();
      return true;
    } on FirebaseException catch (e) {
      final ex = AppException.fromFirebaseCode(e.code);
      state = ProviderSetupState(error: ex.message);
      return false;
    } on AppException catch (e) {
      state = ProviderSetupState(error: e.message);
      return false;
    } catch (_) {
      state = const ProviderSetupState(
        error: 'Something went wrong. Please try again.',
      );
      return false;
    }
  }

  void clearError() => state = state.copyWith(error: null);
}
