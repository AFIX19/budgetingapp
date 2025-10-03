import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeSummary extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  final double totalBalance;

  const HomeSummary({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.totalBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // rata tengah
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Pengeluaran",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text(
                  NumberFormat.compactCurrency(
                    locale: 'id_ID',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  ).format(totalExpense),
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Pemasukan",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text(
                  NumberFormat.compactCurrency(
                    locale: 'id_ID',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  ).format(totalIncome),
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Saldo",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text(
                  NumberFormat.compactCurrency(
                    locale: 'id_ID',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  ).format(totalBalance),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
