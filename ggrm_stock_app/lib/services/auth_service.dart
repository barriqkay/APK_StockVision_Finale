import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream auth state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      // Check if already signed in
      if (_googleSignIn.currentUser != null) {
        await _googleSignIn.signOut();
      }

      // Trigger Google Sign In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google Sign In dibatalkan oleh pengguna');
      }

      print('Google user selected: ${googleUser.email}');

      // Get auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      print('Firebase user signed in: ${userCredential.user?.email}');
      
      // Reload user to ensure email is verified
      await userCredential.user?.reload();
      
      return _auth.currentUser;
      
    } catch (e) {
      print('Google Sign In Error: $e');
      throw _handleGoogleSignInException(e);
    }
  }

  // Handle Google Sign In specific exceptions
  String _handleGoogleSignInException(dynamic e) {
    if (e is FirebaseAuthException) {
      return _handleAuthException(e);
    }
    
    String errorMsg = e.toString();
    
    if (errorMsg.contains('cancelled') || errorMsg.contains('abort')) {
      return 'Google Sign In dibatalkan.';
    }
    if (errorMsg.contains('network')) {
      return 'Koneksi internet bermasalah. Periksa koneksi Anda.';
    }
    if (errorMsg.contains('sign_in_failed') || errorMsg.contains('10')) {
      return 'Google Sign In gagal. Pastikan:\n1. Package name sudah benar di Firebase\n2. SHA fingerprint sudah ditambahkan\n3. OAuth consent screen sudah disetujui';
    }
    
    return 'Google Sign In gagal: $errorMsg';
  }

  // Sign up with email and password
  Future<User?> signUpWithEmailPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Send email verification
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
      }
      
      print('User signed up: ${userCredential.user?.email}');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Sign Up Error: ${e.message}');
      throw _handleAuthException(e);
    }
  }

  // Sign in with email and password
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('User signed in: ${userCredential.user?.email}');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Sign In Error: ${e.message}');
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('Password reset email sent to: $email');
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Get ID Token for backend verification (with auto-refresh)
  Future<String?> getIdToken() async {
    if (currentUser == null) return null;
    try {
      // Force refresh to get valid token
      final token = await currentUser!.getIdToken(true);
      return token;
    } catch (e) {
      print('Error getting ID token: $e');
      // Fallback without forcing refresh
      try {
        return await currentUser!.getIdToken();
      } catch (e2) {
        print('Fallback token error: $e2');
        return null;
      }
    }
  }

  // Get user email
  String? getUserEmail() => currentUser?.email;

  // Get user display name
  String? getUserDisplayName() => currentUser?.displayName;

  // Get user photo URL
  String? getUserPhotoUrl() => currentUser?.photoURL;

  // Check if email is verified
  bool isEmailVerified() => currentUser?.emailVerified ?? false;

  // Reload user data
  Future<void> reloadUser() async {
    await currentUser?.reload();
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      await currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email ini sudah terdaftar. Silakan login atau gunakan email lain.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Password terlalu lemah. Minimal 6 karakter.';
      case 'user-not-found':
        return 'Akun tidak ditemukan. Silakan daftar terlebih dahulu.';
      case 'wrong-password':
        return 'Password yang Anda masukkan salah.';
      case 'user-disabled':
        return 'Akun Anda telah dinonaktifkan.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Silakan tunggu beberapa saat.';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah. Periksa koneksi Anda.';
      case 'sign_in_failed':
        return 'Sign in gagal. Periksa konfigurasi Google Sign In di Firebase console.';
      case 'sign_in_canceled':
        return 'Google Sign In dibatalkan.';
      default:
        return e.message ?? 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }
}

