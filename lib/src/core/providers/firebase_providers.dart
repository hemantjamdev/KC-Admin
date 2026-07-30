import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the singleton [FirebaseFirestore] instance.
/// All repositories must consume this provider instead of calling
/// [FirebaseFirestore.instance] directly.
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provides the singleton [FirebaseAuth] instance.
/// All auth-related code must consume this provider.
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Provides the singleton [FirebaseStorage] instance.
/// Image upload and file storage must consume this provider.
final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

/// Provides a stream of [User?] changes from FirebaseAuth.
/// Use this to react to auth state changes in the router and session providers.
final firebaseAuthStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});
