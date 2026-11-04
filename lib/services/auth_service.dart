import 'package:firebase_auth/firebase_auth.dart';

import 'user_service.dart';

/// Thin wrapper around [FirebaseAuth] so screens do not depend directly on
/// the Firebase plugin.
class AuthService {
  AuthService({FirebaseAuth? auth, UserService? userService})
    : _auth = auth ?? FirebaseAuth.instance,
      _userService = userService ?? UserService();

  final FirebaseAuth _auth;
  final UserService _userService;

  late final Stream<User?> authStateChanges = _auth.authStateChanges();

  late final Stream<User?> userChanges = _auth.userChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      return;
    }

    await user.updateDisplayName(username);
    await _userService.saveUsername(user.uid, username);
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email);
}

String authErrorMessage(FirebaseAuthException exception) {
  return switch (exception.code) {
    'invalid-email' => 'The email address is not valid.',
    'user-disabled' => 'This account has been disabled.',
    'user-not-found' ||
    'wrong-password' ||
    'invalid-credential' ||
    'invalid-login-credentials' => 'Incorrect email or password.',
    'email-already-in-use' =>
      'An account already exists with this email address.',
    'weak-password' => 'The password is too weak. Use at least 6 characters.',
    'too-many-requests' => 'Too many attempts. Please try again later.',
    'network-request-failed' =>
      'Network error. Check your connection and try again.',
    'operation-not-allowed' =>
      'Email/password sign-in is not enabled in Firebase.',
    'requires-recent-login' => 'Please sign in again to continue.',
    _ => 'Authentication failed. Please try again.',
  };
}
