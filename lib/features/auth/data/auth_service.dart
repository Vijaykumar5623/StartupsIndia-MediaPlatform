import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Sign in with Google
  /// Returns the signed-in Firebase user or throws [AuthException]
  Future<User> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Obtain the GoogleSignInAuthentication object
      if (googleUser == null) {
        throw AuthException('Google Sign-In cancelled by user');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      throw AuthException('Firebase Auth Error: ${e.message}');
    } on Exception catch (e) {
      throw AuthException('Google Sign-In Error: ${e.toString()}');
    }
  }

  /// Sign out from Google and Firebase
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      throw AuthException('Sign Out Error: ${e.toString()}');
    }
  }

  /// Get current signed-in user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Check if user is signed in
  bool get isSignedIn => _firebaseAuth.currentUser != null;

  /// Listen to authentication state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
}
