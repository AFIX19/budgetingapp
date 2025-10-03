import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/transaction.dart' as mymodel;

class CategoryAggregation {
  final double amount;
  final Color? color;
  const CategoryAggregation({required this.amount, this.color});

  CategoryAggregation copyWith({double? amount, Color? color}) {
    return CategoryAggregation(
      amount: amount ?? this.amount,
      color: color ?? this.color,
    );
  }
}

class TransactionProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription<QuerySnapshot>? _txSub;

  List<mymodel.Transaction> _transactions = [];
  bool _isLoading = false;
  User? _currentUser;

  DateTime _selectedDate = DateTime.now();

  var selectedMonthName;

  List<mymodel.Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  User? get currentUser => _currentUser;
  String? get userId => _currentUser?.uid;

  int get selectedMonth => _selectedDate.month;
  int get selectedYear => _selectedDate.year;

  List<mymodel.Transaction> get filteredTransactions {
    return _transactions.where((tx) {
      return tx.date.month == selectedMonth && tx.date.year == selectedYear;
    }).toList();
  }

  double get totalIncome => filteredTransactions
      .where((tx) => tx.type == mymodel.TransactionType.income)
      .fold(0.0, (sum, tx) => sum + tx.amount);

  double get totalExpense => filteredTransactions
      .where((tx) => tx.type == mymodel.TransactionType.expense)
      .fold(0.0, (sum, tx) => sum + tx.amount);

  Map<String, CategoryAggregation> get expenseByCategory {
    final map = <String, CategoryAggregation>{};

    // Palet fallback jika categoryColor null
    const List<Color> fallbackPalette = [
      Color(0xFFFFD166), // kuning
      Color(0xFFEF476F), // pink
      Color(0xFF06D6A0), // hijau
      Color(0xFF118AB2), // biru
      Color(0xFF9B5DE5), // ungu
      Color(0xFFF4A261), // oranye
      Color(0xFF2A9D8F), // teal
      Color(0xFFE76F51), // salmon
    ];

    for (final t in filteredTransactions) {
      if (t.type != mymodel.TransactionType.expense) continue;

      final key = (t.categoryName ?? 'Lainnya').trim().isEmpty
          ? 'Lainnya'
          : (t.categoryName ?? 'Lainnya');

      final current = map[key];
      final color =
          t.categoryColor ?? fallbackPalette[map.length % fallbackPalette.length];

      if (current == null) {
        map[key] = CategoryAggregation(amount: t.amount, color: color);
      } else {
        map[key] = current.copyWith(amount: current.amount + t.amount);
      }
    }
    return map;
  }

  Map<int, double> get expensePerDay {
    final map = <int, double>{};
    for (final t in filteredTransactions) {
      if (t.type != mymodel.TransactionType.expense) continue;
      final d = t.date.day;
      map[d] = (map[d] ?? 0) + t.amount;
    }
    return map;
  }

  TransactionProvider() {
    _auth.authStateChanges().listen((User? user) {
      _currentUser = user;
      _detachTxListener();

      if (user != null) {
        _attachTxListener(user.uid);
      } else {
        _transactions = [];
        notifyListeners();
      }
    });
  }

  void _attachTxListener(String uid) {
    _isLoading = true;
    notifyListeners();

    // Realtime: ambil SEMUA transaksi user (bisa difilter lokal pakai selectedMonth/Year)
    _txSub = _db
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      final list = <mymodel.Transaction>[];
      for (final doc in snapshot.docs) {
        try {
          list.add(mymodel.Transaction.fromFirestore(doc));
        } catch (e) {
          debugPrint(' ${doc.id}: $e');
        }
      }
      _transactions = list;
      _isLoading = false;
      notifyListeners();
    }, onError: (err) {
      debugPrint('Error saat melakukan transaksi: $err');
      _isLoading = false;
      notifyListeners();
    });
  }

  void _detachTxListener() {
    _txSub?.cancel();
    _txSub = null;
  }

  @override
  void dispose() {
    _detachTxListener();
    super.dispose();
  }

  void changeMonth(int monthOffset) {
    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + monthOffset, 1);
    notifyListeners();
  }

  void setMonth(int month) {
    _selectedDate = DateTime(_selectedDate.year, month, 1);
    notifyListeners();
  }

  void setYear(int year) {
    _selectedDate = DateTime(year, _selectedDate.month, 1);
    notifyListeners();
  }

  // ===== CRUD =====
  Future<void> addTransaction(mymodel.Transaction tx) async {
    if (_currentUser == null) {
      throw Exception('User not logged in. Cannot add transaction.');
    }
    _isLoading = true;
    notifyListeners();

    try {
      final colRef = _db
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('transactions');

      // Jika id kosong, generate otomatis
      if (tx.id.isEmpty) {
        final docRef = colRef.doc();
        final toSave = tx.copyWith(id: docRef.id);
        await docRef.set(toSave.toFirestore());
      } else {
        await colRef.doc(tx.id).set(tx.toFirestore());
      }
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTransaction(mymodel.Transaction tx) async {
    if (_currentUser == null) {
      throw Exception('User not logged in. Cannot update transaction.');
    }
    if (tx.id.isEmpty) {
      throw Exception('Transaction id is empty. Cannot update.');
    }
    _isLoading = true;
    notifyListeners();

    try {
      await _db
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('transactions')
          .doc(tx.id)
          .update(tx.toFirestore());
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    if (_currentUser == null) {
      throw Exception('User not logged in. Cannot delete transaction.');
    }
    _isLoading = true;
    notifyListeners();

    try {
      await _db
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('transactions')
          .doc(transactionId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
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

  // ===== OPSIONAL: Stream by date-range (kalau mau query langsung dari Firestore) =====
  Stream<List<mymodel.Transaction>> getTransactionsByDateRange({
    required DateTime start,
    required DateTime end,
    mymodel.TransactionType? type,
  }) {
    if (_currentUser == null) {
      // Kembalikan stream kosong
      return const Stream<List<mymodel.Transaction>>.empty();
    }

    Query<Map<String, dynamic>> q = _db
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('transactions')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('date', descending: true);

    if (type != null) {
      q = q.where('type', isEqualTo: type.name);
    }

    return q.snapshots().map((snap) {
      return snap.docs.map((doc) {
        try {
          return mymodel.Transaction.fromFirestore(doc);
        } catch (e) {
          debugPrint('Transaction parse error in range ${doc.id}: $e');
          // fallback minimal agar stream tetap jalan
          return mymodel.Transaction(
            id: doc.id,
            userId: _currentUser!.uid,
            title: 'Invalid',
            amount: 0,
            date: DateTime.now(),
            type: mymodel.TransactionType.expense,
            createdAt: DateTime.now(),
          );
        }
      }).toList();
    });
  }

  void fetchTransactionsForMonth(DateTime selectedMonth) {}
}
