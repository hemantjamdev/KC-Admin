import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/firebase/firestore_paths.dart';

/// Repository managing FCM device tokens in Firestore for Admin users.
class AdminDeviceTokenRepository {
  AdminDeviceTokenRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> registerToken({
    required String uid,
    required String role, // 'admin'
    required String appId, // 'kc_admin'
    required String token,
  }) async {
    if (uid.isEmpty || token.isEmpty) return;

    final rawKey = '${role}_${appId}_${uid}_$token';
    final docId = sha256.convert(utf8.encode(rawKey)).toString();
    final platform = kIsWeb
        ? 'web'
        : (Platform.isAndroid
              ? 'android'
              : (Platform.isIOS ? 'ios' : 'unknown'));

    final docRef = _firestore
        .collection(FirestorePaths.deviceTokens)
        .doc(docId);
    final snapshot = await docRef.get();

    final data = <String, dynamic>{
      'id': docId,
      'uid': uid,
      'role': role,
      'appId': appId,
      'token': token,
      'platform': platform,
      'isActive': true,
      'updatedAt': FieldValue.serverTimestamp(),
      'lastSeenAt': FieldValue.serverTimestamp(),
    };

    if (!snapshot.exists) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    await docRef.set(data, SetOptions(merge: true));
  }

  Future<void> deactivateToken(String token) async {
    if (token.isEmpty) return;

    final query = await _firestore
        .collection(FirestorePaths.deviceTokens)
        .where('token', isEqualTo: token)
        .get();

    final batch = _firestore.batch();
    for (final doc in query.docs) {
      batch.update(doc.reference, {
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }
}
