import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/services/encryption_service.dart';

part 'profile_provider.g.dart';

final _log = Logger();

class ProfileState {
  final bool isUpdating;
  final bool isSuccess;
  final String? error;

  const ProfileState({
    this.isUpdating = false,
    this.isSuccess = false,
    this.error,
  });

  ProfileState copyWith({bool? isUpdating, bool? isSuccess, String? error}) =>
      ProfileState(
        isUpdating: isUpdating ?? this.isUpdating,
        isSuccess: isSuccess ?? this.isSuccess,
        error: error,
      );
}

@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // LOCAL-FIRST: FirebaseStorage removed — restore when upgrading to Blaze plan.

  @override
  ProfileState build() => const ProfileState();

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final uid = ref.read(currentUserProvider).valueOrNull?.uid;
    if (uid == null) return;
    state = state.copyWith(isUpdating: true, error: null);
    try {
      updates['updatedAt'] = Timestamp.now();
      await _firestore.doc('users/$uid').update(updates);
      state = state.copyWith(isUpdating: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isUpdating: false, error: e.toString());
    }
  }

  Future<void> updateProviderProfile(Map<String, dynamic> updates) async {
    final uid = ref.read(currentUserProvider).valueOrNull?.uid;
    if (uid == null) return;
    state = state.copyWith(isUpdating: true, error: null);
    try {
      updates['updatedAt'] = Timestamp.now();
      await _firestore
          .doc('users/$uid/providerProfile/profile')
          .update(updates);
      state = state.copyWith(isUpdating: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isUpdating: false, error: e.toString());
    }
  }

  /// LOCAL-FIRST: Generates a deterministic public avatar URL (pravatar).
  /// No bytes are uploaded. Restore putFile() when upgrading to Blaze plan.
  Future<void> uploadProfilePhoto(Object? file) async {
    final uid = ref.read(currentUserProvider).valueOrNull?.uid;
    if (uid == null) return;
    state = state.copyWith(isUpdating: true, error: null);
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      final url = 'https://i.pravatar.cc/300?u=$uid';
      await updateProfile({'profilePhoto': EncryptionService.instance.encryptData(url)});
      _log.i('[Profile] Profile photo URL encrypted and saved (local-first): $url');
    } catch (e, st) {
      _log.e('[Profile] Profile photo update failed', error: e, stackTrace: st);
      state = state.copyWith(isUpdating: false, error: e.toString());
    }
  }

  /// LOCAL-FIRST: Generates a unique seeded placeholder image URL (picsum).
  /// No bytes are uploaded. Restore putFile() when upgrading to Blaze plan.
  Future<void> uploadPortfolioPhoto(Object? file) async {
    final uid = ref.read(currentUserProvider).valueOrNull?.uid;
    if (uid == null) return;
    state = state.copyWith(isUpdating: true, error: null);
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      final seed = DateTime.now().millisecondsSinceEpoch;
      final url = 'https://picsum.photos/seed/$seed/400/300';
      final encryptedUrl = EncryptionService.instance.encryptData(url);
      await _firestore.doc('users/$uid/providerProfile/profile').update({
        'portfolioPhotos': FieldValue.arrayUnion([encryptedUrl]),
        'portfolioCount': FieldValue.increment(1),
        'updatedAt': Timestamp.now(),
      });
      _log.i('[Profile] Portfolio photo encrypted and added (local-first): $url');
      state = state.copyWith(isUpdating: false, isSuccess: true);
    } catch (e, st) {
      _log.e('[Profile] Portfolio upload failed', error: e, stackTrace: st);
      state = state.copyWith(isUpdating: false, error: e.toString());
    }
  }

  Future<void> removePortfolioPhoto(String url) async {
    final uid = ref.read(currentUserProvider).valueOrNull?.uid;
    if (uid == null) return;
    state = state.copyWith(isUpdating: true, error: null);
    try {
      await _firestore.doc('users/$uid/providerProfile/profile').update({
        'portfolioPhotos': FieldValue.arrayRemove([url]),
        'portfolioCount': FieldValue.increment(-1),
        'updatedAt': Timestamp.now(),
      });
      // LOCAL-FIRST: No Storage reference to delete.
      _log.i('[Profile] Portfolio photo removed from Firestore: $url');
      state = state.copyWith(isUpdating: false, isSuccess: true);
    } catch (e, st) {
      _log.e('[Profile] Portfolio remove failed', error: e, stackTrace: st);
      state = state.copyWith(isUpdating: false, error: e.toString());
    }
  }
}
