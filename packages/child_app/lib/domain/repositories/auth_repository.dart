import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared/models/user_model.dart';

/// Abstract repository for authentication operations in the child app.
abstract class AuthRepository {
  /// Signs in with Google account (child registers as role='child').
  Future<UserModel> signInWithGoogle();

  /// Signs in with email and password.
  Future<UserModel> signInWithEmail(String email, String password);

  /// Creates a new child account with email, password, and display name.
  Future<UserModel> signUp(String email, String password, String displayName);

  /// Signs the current user out and stops monitoring services.
  Future<void> signOut();

  /// Returns the currently authenticated Firebase user.
  User? getCurrentUser();

  /// Stream of auth state changes.
  Stream<User?> get authStateChanges;
}
