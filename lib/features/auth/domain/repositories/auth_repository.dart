import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

/// Abstract contract for authentication operations.
/// The UI layer depends on this, not on [FirebaseAuthRepositoryImpl].
abstract class AuthRepository {
  /// Returns the currently signed-in [User], or null if not authenticated.
  User? get currentUser;

  /// Stream of auth state changes.
  Stream<User?> get authStateChanges;

  /// Sign in with email and password.
  /// Throws [FirebaseAuthException] on failure.
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Create a new account with email and password.
  /// Throws [FirebaseAuthException] on failure.
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Sign in with Google OAuth.
  /// Returns null if the user cancels the flow.
  Future<UserCredential?> signInWithGoogle();

  /// Provider ids linked to the current account (e.g. `password`, `google.com`).
  List<String> get linkedProviderIds;

  /// Link a Google account to the current account as an alternate login.
  /// Returns null if the user cancels. Throws [FirebaseAuthException]
  /// (e.g. `credential-already-in-use`, `provider-already-linked`).
  Future<UserCredential?> linkGoogle();

  /// Link an email/password credential to the current account, so the user can
  /// also sign in with email + password. Throws [FirebaseAuthException].
  Future<void> linkEmailPassword({
    required String email,
    required String password,
  });

  /// Unlink a provider from the current account. The caller must ensure at
  /// least one sign-in method remains. Throws [FirebaseAuthException].
  Future<void> unlinkProvider(String providerId);

  /// Sign out from Firebase (and Google if applicable).
  Future<void> signOut();

  /// Returns the active user data for profile UI.
  Future<UserModel?> getCurrentUserModel();

  /// Persists user profile information into Firestore users/{uid}.
  Future<void> saveUserData(UserModel user);

  /// Updates user profile fields from edit-profile form.
  Future<void> updateUserData(UserModel updatedUser);

  /// Sends a Firebase password-reset email to [email].
  /// Throws [FirebaseAuthException] on failure.
  Future<void> sendPasswordResetEmail(String email);
}
