import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 

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

  // method untuk sign in
  Future<void> signIn(String email, String password) async {
    try {
      // memanggil firebaseauth untuk sign in dengan email dan password
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    }
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
          errorMessage = e.message ?? 'Unknown error';
          break;
      }
      //melempar pesan kembali
      throw errorMessage;
    }
    // menangkap error umum lainnya , kayak masalah jaringan
    catch (e) {
      print("Error: $e"); // Untuk debugging
      throw 'Gagal login. Mohon periksa koneksi internet Anda atau coba lagi nanti.';
    }
  }

  // untuk sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Error signing out: $e");
      rethrow;
    }
  }


  //untuk mendaftar pengguna baru
  Future<void> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print("Error signing up: $e");
      rethrow; 
    }
  }
}