import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../../../data/models/transaction.dart' as mymodel;

class GrafikPiePage extends StatelessWidget {
  const GrafikPiePage({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = Provider.of<TransactionProvider>(context).filteredTransactions;

    double totalPemasukan = transactions
        .where((tx) => tx.type == mymodel.TransactionType.income)
        .fold(0, (sum, tx) => sum + tx.amount);

    double totalPengeluaran = transactions
        .where((tx) => tx.type == mymodel.TransactionType.expense)
        .fold(0, (sum, tx) => sum + tx.amount);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: transactions.isEmpty
            ? const Text("Tidak ada data", style: TextStyle(color: Colors.white38))
            : SizedBox(
                height: 300,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        color: Colors.green,
                        value: totalPemasukan,
                        title: "Pemasukan\n${totalPemasukan.toStringAsFixed(0)}",
                        titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      PieChartSectionData(
                        color: Colors.red,
                        value: totalPengeluaran,
                        title: "Pengeluaran\n${totalPengeluaran.toStringAsFixed(0)}",
                        titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                    centerSpaceRadius: 40,
                    sectionsSpace: 4,
                  ),
                ),
              ),
      ),
    );
  }
}
