import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/firebase/firestore_paths.dart';
import '../../domain/models/shop_profile_model.dart';

/// Singleton repository for the Kapada Creation shop profile.
/// Consistently reads and updates the single shop document.
class ShopProfileRepository {
  ShopProfileRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  static ShopProfileModel _cachedProfile = ShopProfileModel.defaultProfile;

  ShopProfileModel get currentCachedProfile => _cachedProfile;

  /// Stream the single Kapada Creation shop profile.
  Stream<ShopProfileModel> watchShopProfile() {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return Stream.value(_cachedProfile);
      }
    } catch (_) {}

    return _firestore
        .collection(FirestorePaths.boutiques)
        .doc(ShopProfileModel.defaultId)
        .snapshots()
        .map((snap) {
          if (!snap.exists || snap.data() == null) {
            return _cachedProfile;
          }
          final model = ShopProfileModel.fromMap(snap.data()!, snap.id);
          _cachedProfile = model;
          return model;
        })
        .handleError((error) {
          debugPrint('[ShopProfileRepository] watchShopProfile stream error: $error');
          return _cachedProfile;
        });
  }

  /// Get current Kapada Creation shop profile.
  Future<ShopProfileModel> getShopProfile() async {
    try {
      final snap = await _firestore
          .collection(FirestorePaths.boutiques)
          .doc(ShopProfileModel.defaultId)
          .get();
      if (snap.exists && snap.data() != null) {
        _cachedProfile = ShopProfileModel.fromMap(snap.data()!, snap.id);
      }
    } catch (_) {}
    return _cachedProfile;
  }

  /// Update the single Kapada Creation shop profile.
  Future<void> updateShopProfile(ShopProfileModel profile) async {
    _cachedProfile = profile;

    final data = {
      ...profile.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      // 1. Write to central boutique document
      await _firestore
          .collection(FirestorePaths.boutiques)
          .doc(ShopProfileModel.defaultId)
          .set(data, SetOptions(merge: true));

      // 2. Also sync to user's boutique document if logged in
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.uid.isNotEmpty) {
        await _firestore
            .collection(FirestorePaths.boutiques)
            .doc(user.uid)
            .set(data, SetOptions(merge: true));
      }
    } catch (e, st) {
      debugPrint('[ShopProfileRepository] Firestore write warning/permission error: $e\n$st');
      // Local state is preserved in _cachedProfile, so app UI remains updated.
    }
  }
}
