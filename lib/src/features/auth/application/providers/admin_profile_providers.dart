import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/media/image_upload_service.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../shop_profile/application/providers/shop_profile_providers.dart';
import '../../../shop_profile/domain/models/shop_profile_model.dart';

// ─────────────────────────────────────────────
// Current admin user (from FirebaseAuth)
// ─────────────────────────────────────────────

/// State notifier to track admin user updates
final adminProfileUpdateProvider =
    StateNotifierProvider<AdminProfileNotifier, AsyncValue<void>>((ref) {
  return AdminProfileNotifier(ref);
});

class AdminProfileNotifier extends StateNotifier<AsyncValue<void>> {
  AdminProfileNotifier(this.ref) : super(const AsyncValue.data(null));

  final Ref ref;

  Future<void> updateProfile({
    required String displayName,
    File? avatarFile,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(firebaseAuthProvider).currentUser;
      if (user == null) {
        throw Exception('No authenticated admin user found. Please sign in.');
      }

      String? photoUrl = user.photoURL;

      // 1. Upload new avatar to Firebase Storage if provided
      if (avatarFile != null) {
        try {
          final uploadService = ImageUploadService();
          final result = await uploadService.uploadImage(
            file: avatarFile,
            storagePath: 'admin_avatars/${user.uid}.jpg',
          );
          photoUrl = result.downloadUrl;
        } catch (e) {
          debugPrint('[AdminProfileNotifier] Avatar upload warning: $e');
        }
      }

      // 2. Update Firebase Auth Profile (guaranteed for logged in user)
      if (displayName.trim() != user.displayName) {
        await user.updateDisplayName(displayName.trim());
      }
      if (photoUrl != null && photoUrl != user.photoURL) {
        await user.updatePhotoURL(photoUrl);
      }

      // 3. Sync to Firestore `admins/{uid}` and `users/{uid}` collections
      try {
        final firestore = ref.read(firebaseFirestoreProvider);
        final payload = {
          'uid': user.uid,
          'displayName': displayName.trim(),
          'email': user.email,
          'photoURL': photoUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        await firestore.collection('admins').doc(user.uid).set(
          payload,
          SetOptions(merge: true),
        );
        await firestore.collection('users').doc(user.uid).set(
          payload,
          SetOptions(merge: true),
        );
      } catch (e) {
        debugPrint('[AdminProfileNotifier] Firestore sync permission notice: $e');
      }

      // 4. Reload user & refresh Riverpod providers
      await user.reload();
      ref.invalidate(firebaseAuthProvider);
      ref.invalidate(adminCurrentUserProvider);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

/// Returns the current authenticated admin [User].
final adminCurrentUserProvider = Provider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).currentUser;
});

/// Returns the display name of the current admin.
final adminDisplayNameProvider = Provider<String>((ref) {
  final user = ref.watch(adminCurrentUserProvider);
  if (user == null) return 'Admin';
  if (user.displayName != null && user.displayName!.isNotEmpty) {
    return user.displayName!;
  }
  // Fallback: first part of email
  final email = user.email ?? '';
  final localPart = email.split('@').first;
  return localPart.isNotEmpty
      ? '${localPart[0].toUpperCase()}${localPart.substring(1)}'
      : 'Admin';
});

/// Returns the email of the current admin.
final adminEmailProvider = Provider<String>((ref) {
  return ref.watch(adminCurrentUserProvider)?.email ?? '';
});

/// Returns the photoURL of the current admin.
final adminPhotoUrlProvider = Provider<String?>((ref) {
  return ref.watch(adminCurrentUserProvider)?.photoURL;
});

// ─────────────────────────────────────────────
// Shop profile (Kapada Creation profile)
// ─────────────────────────────────────────────

/// Provides the single Kapada Creation shop profile.
final adminShopProfileProvider = Provider<ShopProfileModel>((ref) {
  return ref.watch(shopProfileProvider);
});
