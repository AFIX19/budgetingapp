import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/transaction.dart' as mymodel;

class TransactionProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<mymodel.Transaction> _transactions = [];
  bool _isLoading = false;
  User? _currentUser;

  DateTime _selectedDate = DateTime.now();

  List<mymodel.Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  User? get currentUser => _currentUser;

  int get selectedMonth => _selectedDate.month;
  int get selectedYear => _selectedDate.year;

  List<mymodel.Transaction> get filteredTransactions {
    return _transactions.where((tx) {
      return tx.date.month == selectedMonth && tx.date.year == selectedYear;
    }).toList();
  }

  double get totalIncome {
    return filteredTransactions
        .where((tx) => tx.type == mymodel.TransactionType.income)
        .fold(0, (sum, tx) => sum + tx.amount);
  }

  double get totalExpense {
    return filteredTransactions
        .where((tx) => tx.type == mymodel.TransactionType.expense)
        .fold(0, (sum, tx) => sum + tx.amount);
  }

  TransactionProvider() {
    _auth.authStateChanges().listen((User? user) {
      _currentUser = user;

      if (user != null) {
        _isLoading = true;
        notifyListeners();

        // Langsung ambil transaksi setelah login
        fetchTransactionsForMonth(DateTime.now());

        _db.collection('users')
            .doc(user.uid)
            .collection('transactions')
            .orderBy('date', descending: true)
            .snapshots()
            .listen((snapshot) {
          _transactions = snapshot.docs
              .map((doc) => mymodel.Transaction.fromFirestore(doc))
              .toList();
          notifyListeners();
        }, onError: (error) {
          debugPrint("❌ Error fetching user transactions: $error");
        });
      } else {
        _transactions = [];
        notifyListeners();
      }
    });
  }

  /// 🔹 Tambahan: Ganti bulan
  void changeMonth(int monthOffset) {
    _selectedDate = DateTime(
      _selectedDate.year,
      _selectedDate.month + monthOffset,
    );
    notifyListeners();

    if (_currentUser != null) {
      fetchTransactionsForMonth(_selectedDate);
    } else {
      debugPrint("⚠️ User belum login, gak bisa fetch transaksi");
    }
  }

  Future<void> fetchTransactionsForMonth(DateTime monthYear) async {
    if (_currentUser == null) {
      debugPrint("⚠️ User belum login, skip ambil transaksi");
      _transactions = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final startOfMonth = DateTime(monthYear.year, monthYear.month, 1);
      final endOfMonth = DateTime(
        monthYear.year,
        monthYear.month + 1,
        1,
      ).subtract(const Duration(microseconds: 1));

      final snapshot = await _db
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('transactions')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .orderBy('date', descending: true)
          .get();

      _transactions = snapshot.docs
          .map((doc) => mymodel.Transaction.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching transactions for month: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(mymodel.Transaction transaction) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_currentUser == null) {
        throw Exception('User not logged in. Cannot add transaction.');
      }
      await _db
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('transactions')
          .doc(transaction.id)
          .set(transaction.toFirestore());
    } catch (e) {
      print('Error adding transaction: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTransaction(mymodel.Transaction transaction) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_currentUser == null) {
        throw Exception('User not logged in. Cannot update transaction.');
      }
      await _db
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('transactions')
          .doc(transaction.id)
          .update(transaction.toFirestore());
    } catch (e) {
      print('Error updating transaction: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_currentUser == null) {
        throw Exception('User not logged in. Cannot delete transaction.');
      }
      await _db
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('transactions')
          .doc(transactionId)
          .delete();
    } catch (e) {
      print('Error deleting transaction: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearTransactions() {
    _transactions = [];
    notifyListeners();
  }
}
