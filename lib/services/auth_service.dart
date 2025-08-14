import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Terjadi kesalahan saat login.';
    }
  }

  static Future<String?> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Terjadi kesalahan saat registrasi.';
    }
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }

  static User? get currentUser => _auth.currentUser;
}
