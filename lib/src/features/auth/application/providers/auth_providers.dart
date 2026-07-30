import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/firebase_providers.dart';

// ─────────────────────────────────────────────
// Auth session state
// ─────────────────────────────────────────────

enum AdminAuthStatus { initializing, unauthenticated, authenticated, error }

class AdminAuthState {
  const AdminAuthState({
    this.status = AdminAuthStatus.initializing,
    this.user,
    this.errorMessage,
    this.isSubmitting = false,
  });

  final AdminAuthStatus status;
  final User? user;
  final String? errorMessage;
  final bool isSubmitting;

  bool get isAuthenticated => status == AdminAuthStatus.authenticated;
  bool get isInitializing => status == AdminAuthStatus.initializing;
  bool get isUnauthenticated => status == AdminAuthStatus.unauthenticated;

  AdminAuthState copyWith({
    AdminAuthStatus? status,
    User? user,
    String? errorMessage,
    bool clearError = false,
    bool? isSubmitting,
  }) {
    return AdminAuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

// ─────────────────────────────────────────────
// Auth notifier (keepAlive — session-level)
// ─────────────────────────────────────────────

final adminAuthProvider = NotifierProvider<AdminAuthNotifier, AdminAuthState>(
  AdminAuthNotifier.new,
);

class AdminAuthNotifier extends Notifier<AdminAuthState> {
  @override
  AdminAuthState build() {
    final auth = ref.watch(firebaseAuthProvider);

    // Listen to auth state changes from Firebase.
    ref.listen<AsyncValue<User?>>(firebaseAuthStateProvider, (_, next) {
      next.when(
        data: (user) {
          state = AdminAuthState(
            status: user != null
                ? AdminAuthStatus.authenticated
                : AdminAuthStatus.unauthenticated,
            user: user,
          );
        },
        loading: () =>
            state = const AdminAuthState(status: AdminAuthStatus.initializing),
        error: (e, _) => state = AdminAuthState(
          status: AdminAuthStatus.error,
          errorMessage: e.toString(),
        ),
      );
    });

    // Initialize with current state.
    final currentUser = auth.currentUser;
    if (currentUser == null) {
      Future.microtask(() async {
        try {
          await auth.signInAnonymously();
        } catch (_) {}
      });
    }

    return AdminAuthState(
      status: currentUser != null
          ? AdminAuthStatus.authenticated
          : AdminAuthStatus.unauthenticated,
      user: currentUser,
    );
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(clearError: true);
    }
  }

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final credential = await ref
          .read(firebaseAuthProvider)
          .signInWithEmailAndPassword(email: email.trim(), password: password);
      state = AdminAuthState(
        status: AdminAuthStatus.authenticated,
        user: credential.user,
        isSubmitting: false,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        status: AdminAuthStatus.unauthenticated,
        errorMessage: _mapError(e),
        isSubmitting: false,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AdminAuthStatus.unauthenticated,
        errorMessage: 'An unexpected login error occurred. Please try again.',
        isSubmitting: false,
      );
      return false;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isSubmitting: true);
    try {
      await ref.read(firebaseAuthProvider).signOut();
    } catch (_) {}
    state = const AdminAuthState(status: AdminAuthStatus.unauthenticated);
  }

  String _mapError(FirebaseAuthException e) {
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
