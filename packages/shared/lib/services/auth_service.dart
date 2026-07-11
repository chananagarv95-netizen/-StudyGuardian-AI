/// Authentication service for StudyGuardian AI.
///
/// Wraps Firebase Authentication and Google Sign-In to provide a
/// unified authentication API with comprehensive error handling.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../utils/logger.dart';

/// Service that manages all authentication operations.
///
/// Supports Google Sign-In, email/password authentication,
/// password reset, and auth state observation.
class AuthService {
  /// Firebase Authentication instance.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Google Sign-In instance.
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ---------------------------------------------------------------------------
  // Google Sign-In
  // ---------------------------------------------------------------------------

  /// Signs in the user with their Google account.
  ///
  /// Returns the [UserCredential] on success, or `null` if the user
  /// cancels the sign-in flow.
  ///
  /// Throws [FirebaseAuthException] if the Firebase credential exchange
  /// fails after a successful Google sign-in.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        AppLogger.info('Google sign-in cancelled by user.');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      AppLogger.info(
        'Google sign-in successful for user: ${userCredential.user?.uid}',
      );

      return userCredential;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Google sign-in failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Email / Password
  // ---------------------------------------------------------------------------

  /// Signs in a user with [email] and [password].
  ///
  /// Returns the [UserCredential] on success.
  ///
  /// Throws [FirebaseAuthException] on invalid credentials or other errors.
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      AppLogger.info(
        'Email sign-in successful for user: ${credential.user?.uid}',
      );

      return credential;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Email sign-in failed for $email',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Creates a new user account with [email], [password], and [displayName].
  ///
  /// After successful creation, the user's display name is updated.
  /// Returns the [UserCredential] for the newly created account.
  Future<UserCredential> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update the display name on the newly created user profile.
      await credential.user?.updateDisplayName(displayName);
      // Reload user data so subsequent reads reflect the new display name.
      await credential.user?.reload();

      AppLogger.info(
        'Email sign-up successful for user: ${credential.user?.uid} '
        '(displayName: $displayName)',
      );

      return credential;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Email sign-up failed for $email',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Sign Out
  // ---------------------------------------------------------------------------

  /// Signs the current user out of both Google and Firebase Auth.
  Future<void> signOut() async {
    try {
      // Sign out from Google (no-op if not signed in with Google).
      await _googleSignIn.signOut();
      // Sign out from Firebase Auth.
      await _auth.signOut();

      AppLogger.info('User signed out successfully.');
    } catch (e, stackTrace) {
      AppLogger.error('Sign-out failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Current User & Auth State
  // ---------------------------------------------------------------------------

  /// Returns the currently authenticated [User], or `null` if no user
  /// is signed in.
  User? getCurrentUser() => _auth.currentUser;

  /// A stream that emits the current [User] (or `null`) whenever the
  /// authentication state changes (sign-in, sign-out, token refresh).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ---------------------------------------------------------------------------
  // Password Reset
  // ---------------------------------------------------------------------------

  /// Sends a password-reset email to the given [email] address.
  ///
  /// Throws [FirebaseAuthException] if the email is not registered or
  /// if there is a network error.
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      AppLogger.info('Password reset email sent to $email.');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Password reset failed for $email',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
