// lib/models/transaction.dart (Pastikan file ini diperbarui!)
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { income, expense, transfer }

class Transaction {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String? categoryId; // <<< Tambah ini
  final String? categoryName;
  final IconData? categoryIcon;
  final Color? categoryColor;
  final String? fromAccount;
  final String? toAccount;
  final String? note; // <<< Tambah ini
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    this.categoryId, // <<< Tambah ini
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    this.fromAccount,
    this.toAccount,
    this.note, // <<< Tambah ini
    required this.createdAt,
  });

  Transaction copyWith({
    String? id,
    String? userId,
    String? title,
    double? amount,
    DateTime? date,
    TransactionType? type,
    String? categoryId, // <<< Tambah ini
    String? categoryName,
    IconData? categoryIcon,
    Color? categoryColor,
    String? fromAccount,
    String? toAccount,
    String? note, // <<< Tambah ini
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId, // <<< Tambah ini
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColor: categoryColor ?? this.categoryColor,
      fromAccount: fromAccount ?? this.fromAccount,
      toAccount: toAccount ?? this.toAccount,
      note: note ?? this.note, // <<< Tambah ini
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw StateError('Missing data for transaction ID: ${doc.id}');
    }

    DateTime parseDate(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (_) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    IconData? parseIconData(Map<String, dynamic> data) {
      final int? codePoint = data['categoryIconCode'] as int?;
      final String? fontFamily = data['categoryIconFamily'] as String?;
      final String? fontPackage = data['categoryIconPackage'] as String?;
      if (codePoint != null && fontFamily != null) {
        return IconData(
          codePoint,
          fontFamily: fontFamily,
          fontPackage: fontPackage,
        );
      }
      return null;
    }

    Color? parseColor(dynamic value) {
      if (value is int) {
        return Color(value);
      }
      return null;
    }

    return Transaction(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? 'No Title',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      date: parseDate(data['date']),
      type: TransactionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => TransactionType.expense,
      ),
      categoryId: data['categoryId'] as String?, // <<< Ambil dari Firestore
      categoryName: data['categoryName'] as String?,
      categoryIcon: parseIconData(data),
      categoryColor: parseColor(data['categoryColorValue']),
      fromAccount: data['fromAccount'] as String?,
      toAccount: data['toAccount'] as String?,
      note: data['note'] as String?, // <<< Ambil dari Firestore
      createdAt: parseDate(data['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'type': type.name,
      'categoryId': categoryId, // <<< Simpan ke Firestore
      'categoryName': categoryName,
      'categoryIconCode': categoryIcon?.codePoint,
      'categoryIconFamily': categoryIcon?.fontFamily,
      'categoryIconPackage': categoryIcon?.fontPackage,
      'categoryColorValue': categoryColor?.value,
      'fromAccount': fromAccount,
      'toAccount': toAccount,
      'note': note, // <<< Simpan ke Firestore
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}