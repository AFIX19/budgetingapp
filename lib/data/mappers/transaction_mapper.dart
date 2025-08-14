import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction.dart' as mymodel;

class TransactionMapper {

  static mymodel.Transaction fromJson(Map<String, dynamic> json) {
    return mymodel.Transaction(
      id: json['id'] ?? '',
      title: json['title'] ?? 'No Title',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      type: mymodel.TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => mymodel.TransactionType.expense,
      ),
      categoryIcon: IconData(
        json['categoryIconCode'] ?? Icons.error.codePoint,
        fontFamily: 'MaterialIcons',
        fontPackage: null, 
      ),
      categoryColor: Color(json['categoryColorValue'] ?? Colors.grey.value),
      categoryName: json['categoryName'] ?? 'Lain-lain',
      userId: json['userId'] ?? '',
      createdAt: DateTime.now(), 
      fromAccount: json['fromAccount'],
      toAccount: json['toAccount'], 
    );
  }

  static Map<String, dynamic> toJson(mymodel.Transaction t) {
    return {
      'id': t.id,
      'title': t.title,
      'amount': t.amount,
      'date': t.date.toIso8601String(),
      'type': t.type.name,
      'categoryIconCode': t.categoryIcon?.codePoint ?? Icons.error.codePoint,
      'categoryColorValue': t.categoryColor?.value ?? Colors.grey.value,
      'categoryName': t.categoryName,
      'userId': t.userId,
      'fromAccount': t.fromAccount, 
      'toAccount': t.toAccount,   
      'createdAt': t.createdAt.toIso8601String(), 
    };
  }

  static mymodel.Transaction fromFirestore(Map<String, dynamic> data, String id) {
    return mymodel.Transaction(
      id: id,
      title: data['title'] ?? 'No Title',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      date: (data['date'] is Timestamp)
          ? (data['date'] as Timestamp).toDate()
          : (data['date'] is String) 
              ? DateTime.parse(data['date'])
              : DateTime.now(), 
      type: mymodel.TransactionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => mymodel.TransactionType.expense,
      ),
      categoryIcon: IconData(
        data['categoryIconCode'] ?? Icons.error.codePoint,
        fontFamily: data['categoryIconFamily'] ?? 'MaterialIcons', 
        fontPackage: data['categoryIconPackage'], 
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
      'date': Timestamp.fromDate(t.date), 
      'type': t.type.name,
      'categoryIconCode': t.categoryIcon?.codePoint,
      'categoryIconFamily': t.categoryIcon?.fontFamily,
      'categoryIconPackage': t.categoryIcon?.fontPackage, 
      'categoryColorValue': t.categoryColor?.value,
      'categoryName': t.categoryName,
      'userId': t.userId,
      'fromAccount': t.fromAccount,
      'toAccount': t.toAccount,
      'createdAt': Timestamp.fromDate(t.createdAt), 
    };
  }
}