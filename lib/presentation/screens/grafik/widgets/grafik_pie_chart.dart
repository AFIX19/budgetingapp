import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budgetting_app/providers/transaction_provider.dart';
import 'package:budgetting_app/data/models/transaction.dart' as mymodel;
import 'package:fl_chart/fl_chart.dart';

class GrafikPieChart extends StatelessWidget {
  const GrafikPieChart({super.key, required List<mymodel.Transaction> transactions});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final List<mymodel.Transaction> transactions =
            provider.filteredTransactions;

        // hitung total per kategori
        final Map<String, double> kategoriTotal = {};
        final Map<String, Color> kategoriWarna = {};

        for (var t in transactions) {
          final kategori = t.categoryName ?? "Lainnya";
          final warna = t.categoryColor ?? Colors.grey;
          kategoriTotal[kategori] = (kategoriTotal[kategori] ?? 0) + t.amount;
          kategoriWarna[kategori] = warna;
        }

        if (kategoriTotal.isEmpty) {
          return const Center(
            child: Text("Belum ada transaksi"),
          );
        }

        return PieChart(
          PieChartData(
            sections: kategoriTotal.entries.map((entry) {
              final kategori = entry.key;
              final total = entry.value;
              final warna = kategoriWarna[kategori] ?? Colors.grey;

              return PieChartSectionData(
                color: warna,
                value: total,
                title: kategori,
                radius: 60,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            }).toList(),
            sectionsSpace: 2,
            centerSpaceRadius: 40,
          ),
        );
      },
    );
  }
}
