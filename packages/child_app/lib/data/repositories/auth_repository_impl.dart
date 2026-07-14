import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared/models/user_model.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/services/firestore_service.dart';
import 'package:shared/utils/logger.dart';
import '../../domain/repositories/auth_repository.dart';

/// Implementation of [AuthRepository] using Firebase services.
///
/// Registers users with role='child' (unlike the parent app which uses 'parent').
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
      final credential = await _authService.signInWithGoogle();
      if (credential == null) throw Exception('Google sign-in cancelled');

      final user = credential.user;
      if (user == null) throw Exception('Google sign-in returned null user');

      // Check if user exists in Firestore, create if not
      var userModel = await _firestoreService.getUser(user.uid);
      if (userModel == null) {
        userModel = UserModel(
          id: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? 'Child',
          photoUrl: user.photoURL,
          role: 'child',
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
      final credential = await _authService.signInWithEmail(email, password);
      final userModel = await _firestoreService.getUser(credential.user!.uid);
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
      final credential =
          await _authService.signUpWithEmail(email, password, displayName);

      final userModel = UserModel(
        id: credential.user!.uid,
        email: email,
        displayName: displayName,
        photoUrl: null,
        role: 'child',
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
}
