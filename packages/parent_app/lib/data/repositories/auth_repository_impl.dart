import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared/models/user_model.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/services/firestore_service.dart';
import 'package:shared/utils/logger.dart';
import '../../domain/repositories/auth_repository.dart';

/// Implementation of [AuthRepository] using Firebase services.
class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  AuthRepositoryImpl({
    required AuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService;

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final user = await _authService.signInWithGoogle();
      if (user == null) throw Exception('Google sign-in failed');

      // Check if user exists in Firestore, create if not
      var userModel = await _firestoreService.getUser(user.uid);
      if (userModel == null) {
        userModel = UserModel(
          id: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? 'Parent',
          photoUrl: user.photoURL,
          role: 'parent',
          createdAt: DateTime.now(),
          fcmTokens: [],
        );
        await _firestoreService.createUser(userModel);
      }
      return userModel;
    } catch (e, st) {
      AppLogger.e('AuthRepo', 'Google sign-in failed', e, st);
      rethrow;
    }
  }

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final user = await _authService.signInWithEmail(email, password);
      if (user == null) throw Exception('Email sign-in failed');

      final userModel = await _firestoreService.getUser(user.uid);
      if (userModel == null) throw Exception('User profile not found');
      return userModel;
    } catch (e, st) {
      AppLogger.e('AuthRepo', 'Email sign-in failed', e, st);
      rethrow;
    }
  }

  @override
  Future<UserModel> signUp(
      String email, String password, String displayName) async {
    try {
      final user =
          await _authService.signUpWithEmail(email, password, displayName);
      if (user == null) throw Exception('Sign-up failed');

      final userModel = UserModel(
        id: user.uid,
        email: email,
        displayName: displayName,
        photoUrl: null,
        role: 'parent',
        createdAt: DateTime.now(),
        fcmTokens: [],
      );
      await _firestoreService.createUser(userModel);
      return userModel;
    } catch (e, st) {
      AppLogger.e('AuthRepo', 'Sign-up failed', e, st);
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e, st) {
      AppLogger.e('AuthRepo', 'Sign-out failed', e, st);
      rethrow;
    }
  }

  @override
  User? getCurrentUser() => _authService.getCurrentUser();

  @override
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
    } catch (e, st) {
      AppLogger.e('AuthRepo', 'Password reset failed', e, st);
      rethrow;
    }
  }
}
