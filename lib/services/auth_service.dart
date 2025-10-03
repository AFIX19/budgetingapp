import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
        );
      return null;
    } on FirebaseAuthException catch (e) {
    //   if (e.code == 'user-not-found') {
    //     return 'Email belum terdaftar';
    //   } else if (e.code == 'wrong-password') {
    //     return 'password yang anda masukkan salah';
    //   } else if (e.code == 'invalid-email') {
    //     return 'Format email tidak valid';
    //   } else if (e.code == 'user-disabled') {
    //     return 'Akun ini telah dinonaktifkan';
    //   } else {
    //     return 'Terjadi kesalahan saat login';
    //   }
    // } catch (e) {
    //   return "Terjadi kesalahan saat login";
    // }
      return _mapLoginError(e);
    }
  }

   static Future<String?> register(
      String email, String password, String confirmPassword) async {
    // cek manual dulu
    final error = validateRegister(email, password, confirmPassword);
    if (error != null) return error;

    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // sukses
    } on FirebaseAuthException catch (e) {
      return _mapRegisterError(e);
    }
  }
  //untuk mapping error login
   static String _mapLoginError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Email tersebut belum terdaftar.';
      case 'wrong-password':
        return 'Password yang kamu masukkan salah.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan.';
      case 'invalid-credential':
      case'invalid-login-credential':
        return 'Email atau password yang anda masukkan salah.';
      default:
        return 'Terjadi kesalahan saat login. (${e.code})';
    }
  }

  // untuk mapping error register
  static String _mapRegisterError(FirebaseAuthException e) {
    switch (e.code)  {
      case 'email-already-in-use':
        return 'Email sudah digunakan. Silakan gunakan email lain.';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'operation-not-allowed':
        return 'Register dengan email dan password tidak diizinkan.';
      case 'weak-password':
        return ' ';
      case 'password-mismatch':
        return 'Password terlalu lemah, minimal 8 karakter';
      default:
        return 'Terjadi Kesalahan saat registrasi. (${e.code})';
    }
  }

  // validasi email dan password
  static String? validateLogin(String email, String password) {
    if (email.isEmpty) return "Email tidak boleh kosong";
    if (!email.contains('@')) return "Format email tidak valid";
    if (password.isEmpty) return "Password tidak boleh kosong";
    if (password.length < 8) return "Password minimal 8 karakter";
    return null;
  }

  //validasi email, password, confirm
  static String? validateRegister(
      String email, String password, String confirmPassword) {
    if (email.isEmpty) return "Email tidak boleh kosong";
    if (!email.contains('@')) return "Format email tidak valid";

    if (password.isEmpty) return "Password tidak boleh kosong";
    if (password.length < 8) return "Password minimal 8 karakter";

    if (confirmPassword.isEmpty) return "Konfirmasi password tidak boleh kosong";
    if (password != confirmPassword) return "Password tidak sama";

    return null;
  }

  //register
  // email
  static String? validateEmail(String email) {
    if (email.isEmpty) return "Email tidak boleh kosong";
    if (!email.contains('@')) return "Format email tidak valid";
    return null;
  }

  // password
  static String? validatePassword(String password) {
    if (password.isEmpty) return "Password tidak boleh kosong";
    if (password.length < 8) return "Password minimal 8 karakter";
    return null;
  }

  // confirm password
  static String? validateConfirmPassword(String confirm, String password) {
    if (confirm.isEmpty) return "Konfirmasi password tidak boleh kosong";
    if (confirm != password) return "Password tidak sama";
    return null;
  }

  // logout
  static Future<void> logout() async {
    await _auth.signOut();
  }

  // user aktif
  static User? get currentUser => _auth.currentUser;
}
