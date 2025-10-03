import 'package:flutter/material.dart';
import 'package:budgetting_app/data/models/transaction.dart' as mymodel;

class GrafikSummary extends StatelessWidget {
  final List<mymodel.Transaction> transactions;
  const GrafikSummary({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    double totalIncome = transactions
        .where((t) => t.type == mymodel.TransactionType.income)
        .fold(0, (sum, t) => sum + t.amount);

    double totalExpense = transactions
        .where((t) => t.type == mymodel.TransactionType.expense)
        .fold(0, (sum, t) => sum + t.amount);

    double balance = totalIncome - totalExpense;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildItem("Pemasukan", totalIncome, Colors.green),
          _buildItem("Pengeluaran", totalExpense, Colors.red),
          _buildItem("Saldo", balance, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildItem(String title, double value, Color color) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        Text(
          "Rp ${value.toStringAsFixed(0)}",
          style: TextStyle(color: color, fontSize: 16),
        ),
      ],
    );
  }
}
