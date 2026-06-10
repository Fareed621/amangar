// lib/features/auth/presentation/providers/auth_state_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/exceptions/app_exception.dart';
import 'package:amanghar_app/features/notifications/notification_service.dart';

part 'auth_state_provider.g.dart';

final _log = Logger();

class AuthState {
  const AuthState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
  });

  final bool isLoading;
  final bool isSubmitting;
  final String? error;

  AuthState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    String? error,
  }) =>
      AuthState(
        isLoading: isLoading ?? this.isLoading,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        error: error,
      );
}

@riverpod
class AuthStateNotifier extends _$AuthStateNotifier {
  @override
  AuthState build() => const AuthState();

  /// Signs in with Google and checks ban status.
  /// GoRouter redirect handles navigation automatically.
  Future<void> signInWithGoogle() async {
    state = const AuthState(isLoading: true);
    try {
      _log.i('[Auth] Starting Google Sign-In');
      // Force account selection by signing out first
      await GoogleSignIn().signOut();
      final googleUser = await GoogleSignIn().signIn();
      _log.d('[Auth] GoogleUser: $googleUser');
      if (googleUser == null) {
        // User cancelled sign-in
        _log.i('[Auth] User cancelled Google Sign-In');
        state = const AuthState();
        return;
      }

      _log.d('[Auth] Fetching Google Auth tokens');
      final googleAuth = await googleUser.authentication;
      _log.d('[Auth] ID Token present: ${googleAuth.idToken != null}');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      _log.i('[Auth] Signing into Firebase Auth (15s timeout)');
      final userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential)
          .timeout(const Duration(seconds: 15), onTimeout: () {
        throw FirebaseAuthException(
          code: 'timeout',
          message: 'The login attempt timed out. Check your internet connection or App Check settings.',
        );
      });
      final user = userCredential.user;
      _log.i('[Auth] Firebase Auth successful — UID: ${user?.uid}');
      if (user == null) {
        state = const AuthState(error: 'Sign-in failed. Please try again.');
        return;
      }

      // Check if user is banned
      _log.d('[Auth] Checking Firestore ban status');
      final snap = await FirebaseFirestore.instance
          .doc(FirestorePaths.user(user.uid))
          .get();
      _log.d('[Auth] Firestore doc exists: ${snap.exists}');

      if (snap.exists) {
        final data = snap.data() ?? {};
        
        // 1. Check if user is banned
        final isBanned = data['isBanned'] == true;
        if (isBanned) {
          await signOut();
          state = const AuthState(
            error: 'Your account has been suspended. Contact support.',
          );
          return;
        }

        // 2. SELF-HEALING: Ensure visibility fields exist (rating, totalReviews, profilePhoto)
        // If these are missing, Firestore queries with orderBy/where will hide the user.
        final missingFields = <String, dynamic>{};
        if (!data.containsKey('rating')) missingFields['rating'] = 0.0;
        if (!data.containsKey('totalReviews')) missingFields['totalReviews'] = 0;
        if (!data.containsKey('profilePhoto')) missingFields['profilePhoto'] = user.photoURL;
        if (!data.containsKey('onboardingComplete')) missingFields['onboardingComplete'] = false;
        if (!data.containsKey('isVerified')) missingFields['isVerified'] = false;
        if (!data.containsKey('isBanned')) missingFields['isBanned'] = false;
        if (!data.containsKey('isDeleted')) missingFields['isDeleted'] = false;

        if (missingFields.isNotEmpty) {
          _log.i('[Auth] Self-healing user doc — adding fields: $missingFields');
          await FirebaseFirestore.instance
              .doc(FirestorePaths.user(user.uid))
              .update(missingFields);
        }
      }

      _log.i('[Auth] Google Sign-In complete ✓');
      // Success — GoRouter redirect takes over
      state = const AuthState();
    } on FirebaseAuthException catch (e) {
      final ex = AppException.fromFirebaseCode(e.code);
      state = AuthState(error: ex.message);
    } catch (e, st) {
      _log.e('[Auth] Google Sign-In error', error: e, stackTrace: st);
      state = const AuthState(
        error: 'Sign-in failed. Please try again.',
      );
    }
  }

  Future<void> signOut() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await NotificationService.clearToken(uid);
    }
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }

  void clearError() => state = state.copyWith(error: null);
}
