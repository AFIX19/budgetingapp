import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'transaction.dart' as mymodel; // Ini sudah benar, mengacu ke model transaction kita
// import 'transaction_type.dart'; // <<< HAPUS BARIS INI!

class TransactionMapper {

  // Untuk local storage (SharedPreferences)
  static mymodel.Transaction fromJson(Map<String, dynamic> json) {
    return mymodel.Transaction(
      id: json['id'] ?? '',
      title: json['title'] ?? 'No Title',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      // Ganti TransactionType menjadi mymodel.TransactionType
      type: mymodel.TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => mymodel.TransactionType.expense,
      ),
      categoryIcon: IconData(
        json['categoryIconCode'] ?? Icons.error.codePoint,
        fontFamily: 'MaterialIcons',
        fontPackage: null, // Penting: tambahkan ini jika FontAwesomeIcons tidak berfungsi tanpa itu
      ),
      categoryColor: Color(json['categoryColorValue'] ?? Colors.grey.value),
      categoryName: json['categoryName'] ?? 'Lain-lain',
      userId: json['userId'] ?? '',
      // createdAt tidak ada di fromJson (untuk local storage), mungkin perlu di tambahkan jika digunakan
      createdAt: DateTime.now(), // Tambahkan default value jika tidak ada di json
      fromAccount: json['fromAccount'], // Pastikan ini ada di JSON jika dari local
      toAccount: json['toAccount'],     // Pastikan ini ada di JSON jika dari local
    );
  }

  static Map<String, dynamic> toJson(mymodel.Transaction t) {
    return {
      'id': t.id,
      'title': t.title,
      'amount': t.amount,
      'date': t.date.toIso8601String(),
      'type': t.type.name,
      // Pastikan categoryIcon tidak null sebelum mengakses codePoint
      'categoryIconCode': t.categoryIcon?.codePoint ?? Icons.error.codePoint,
      'categoryColorValue': t.categoryColor?.value ?? Colors.grey.value,
      'categoryName': t.categoryName,
      'userId': t.userId,
      'fromAccount': t.fromAccount, // Tambahkan ini
      'toAccount': t.toAccount,     // Tambahkan ini
      'createdAt': t.createdAt.toIso8601String(), // Tambahkan ini
    };
  }

  static mymodel.Transaction fromFirestore(Map<String, dynamic> data, String id) {
    return mymodel.Transaction(
      id: id,
      title: data['title'] ?? 'No Title',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      date: (data['date'] is Timestamp)
          ? (data['date'] as Timestamp).toDate()
          : (data['date'] is String) // Handle string date if it's from old data
              ? DateTime.parse(data['date'])
              : DateTime.now(), // Fallback
      // Ganti TransactionType menjadi mymodel.TransactionType
      type: mymodel.TransactionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => mymodel.TransactionType.expense,
      ),
      categoryIcon: IconData(
        data['categoryIconCode'] ?? Icons.error.codePoint,
        fontFamily: data['categoryIconFamily'] ?? 'MaterialIcons', // Gunakan fontFamily dari data jika ada
        fontPackage: data['categoryIconPackage'], // Jika ikon dari FontAwesome dll
      ),
      categoryColor: Color(data['categoryColorValue'] ?? Colors.grey.value),
      categoryName: data['categoryName'] ?? 'Lain-lain',
      userId: data['userId'] ?? '',
      fromAccount: data['fromAccount'],
      toAccount: data['toAccount'],
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : (data['createdAt'] is String)
              ? DateTime.parse(data['createdAt'])
              : DateTime.now(),
    );
  }

  static Map<String, dynamic> toFirestore(mymodel.Transaction t) {
    return {
      'title': t.title,
      'amount': t.amount,
      'date': Timestamp.fromDate(t.date), // Simpan sebagai Timestamp
      'type': t.type.name,
      'categoryIconCode': t.categoryIcon?.codePoint,
      'categoryIconFamily': t.categoryIcon?.fontFamily,
      'categoryIconPackage': t.categoryIcon?.fontPackage, // Simpan ini jika ikon dari FontAwesome
      'categoryColorValue': t.categoryColor?.value,
      'categoryName': t.categoryName,
      'userId': t.userId,
      'fromAccount': t.fromAccount,
      'toAccount': t.toAccount,
      'createdAt': Timestamp.fromDate(t.createdAt), // Simpan sebagai Timestamp
    };
  }
}