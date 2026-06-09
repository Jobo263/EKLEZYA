import 'package:firebase_auth/firebase_auth.dart';
import '../entities/user_profile.dart';

abstract class AuthRepository {
  /// Current Firebase user stream.
  Stream<User?> get authStateChanges;

  /// Current user (synchronous).
  User? get currentUser;

  /// Sign in with Google.
  Future<UserProfile> signInWithGoogle();

  /// Sign in with Apple.
  Future<UserProfile> signInWithApple();

  /// Sign in with email + password.
  Future<UserProfile> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Register with email + password.
  Future<UserProfile> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  });

  /// Sign out.
  Future<void> signOut();

  /// Send password reset email.
  Future<void> sendPasswordResetEmail(String email);

  /// Get or create user profile in Firestore.
  Future<UserProfile> getUserProfile(String uid);

  /// Update user profile.
  Future<void> updateUserProfile(UserProfile profile);

  /// Delete account.
  Future<void> deleteAccount();
}
