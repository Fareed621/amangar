// lib/core/providers/auth_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../constants/firestore_paths.dart';
import '../models/user_model.dart';

part 'auth_provider.g.dart';

/// Stream of the raw Firebase Auth user (null = not signed in).
@riverpod
Stream<User?> authState(AuthStateRef ref) {
  return FirebaseAuth.instance.authStateChanges();
}

/// Real-time stream of the current user's Firestore document.
/// Returns null if not signed in or document doesn't exist yet.
@riverpod
Stream<UserModel?> currentUser(CurrentUserRef ref) {
  final authUser = ref.watch(authStateProvider).valueOrNull;
  if (authUser == null) return Stream.value(null);
  return FirebaseFirestore.instance
      .doc(FirestorePaths.user(authUser.uid))
      .snapshots()
      .map((snap) => snap.exists ? UserModel.fromFirestore(snap) : null);
}

/// Checks if the current user has the 'admin' custom claim on their ID token.
/// Uses ID token claims — NOT the Firestore isAdmin field.
@riverpod
Future<bool> isAdmin(IsAdminRef ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;
  final result = await user.getIdTokenResult(true); // force refresh
  return result.claims?['admin'] == true;
}
