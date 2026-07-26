import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Authentication controller for KC-Admin using Firebase Auth Email/Password.
class AdminAuthController extends ChangeNotifier {
  AdminAuthController({FirebaseAuth? auth}) : _auth = auth {
    _init();
  }

  final FirebaseAuth? _auth;
  User? _currentUser;
  bool _isLoading = false;
  String? _authError;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get authError => _authError;

  FirebaseAuth? get _instance {
    if (_auth != null) return _auth;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  void _init() {
    final auth = _instance;
    if (auth == null) return;

    try {
      _currentUser = auth.currentUser;
      auth.authStateChanges().listen((user) {
        _currentUser = user;
        notifyListeners();
      });
    } catch (_) {}
  }

  void clearError() {
    if (_authError != null) {
      _authError = null;
      notifyListeners();
    }
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    if (_isLoading) return false;
    final auth = _instance;
    if (auth == null) {
      _authError = 'Firebase is not initialized.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _authError = null;
    notifyListeners();

    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _currentUser = credential.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _authError = _mapFirebaseAuthError(e);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _authError = 'An unexpected login error occurred. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    final auth = _instance;
    if (auth != null) {
      try {
        await auth.signOut();
      } catch (_) {}
    }
    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    return switch (e.code) {
      'user-not-found' => 'No admin account found with this email address.',
      'wrong-password' => 'Incorrect password. Please verify and try again.',
      'invalid-email' => 'Please enter a valid email address.',
      'user-disabled' => 'This admin account has been disabled.',
      'too-many-requests' =>
        'Too many failed attempts. Please wait a moment and try again.',
      'network-request-failed' =>
        'Network error. Please check your connection.',
      'invalid-credential' =>
        'Invalid login credentials. Please check your email and password.',
      _ => e.message ?? 'Authentication failed. Please try again.',
    };
  }
}
