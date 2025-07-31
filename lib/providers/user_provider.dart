import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Pastikan ini diimport

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;

  User? get currentUser => _currentUser;

  UserProvider() {
    _auth.authStateChanges().listen((User? user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  // Method untuk sign in
  Future<void> signIn(String email, String password) async {
    try {
      // Panggil Firebase Auth untuk sign in dengan email dan password
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Jika berhasil, authStateChanges listener akan otomatis mengupdate _currentUser
      // dan notifyListeners() akan dipanggil.
    }
    // Tangkap error spesifik dari Firebase Authentication
    on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Tidak ada pengguna dengan email ini.';
          break;
        case 'wrong-password':
          errorMessage = 'Password salah. Mohon periksa kembali.';
          break;
        case 'invalid-email':
          errorMessage = 'Format email tidak valid.';
          break;
        case 'user-disabled':
          errorMessage = 'Akun Anda telah dinonaktifkan.';
          break;
        default:
          errorMessage = 'Terjadi kesalahan saat login: ${e.message ?? 'Unknown error'}';
          break;
      }
      // Lempar kembali pesan error yang sudah di-format agar bisa ditangkap oleh UI (LoginPage)
      throw errorMessage;
    }
    // Tangkap error umum lainnya (misalnya masalah jaringan)
    catch (e) {
      print("Error signing in (general): $e"); // Untuk debugging
      throw 'Gagal login. Mohon periksa koneksi internet Anda atau coba lagi nanti.';
    }
  }

  // Method untuk sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Error signing out: $e");
      rethrow;
    }
  }


  // Method untuk mendaftar pengguna baru
  Future<void> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print("Error signing up: $e");
      rethrow; // Penting untuk melempar error agar bisa ditangani di UI
    }
  }
}