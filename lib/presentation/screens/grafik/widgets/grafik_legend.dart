import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budgetting_app/providers/transaction_provider.dart';
import 'package:budgetting_app/data/models/transaction.dart' as mymodel;

class GrafikLegend extends StatelessWidget {
  const GrafikLegend({super.key, required List<mymodel.Transaction> transactions});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final List<mymodel.Transaction> transactions =
            provider.filteredTransactions;

        // ambil kategori unik
        final Map<String, Color> kategoriWarna = {};
        final Map<String, double> kategoriTotal = {};

        for (var t in transactions) {
          final kategori = t.categoryName ?? "Lainnya";
          final warna = t.categoryColor ?? Colors.grey;
          kategoriWarna[kategori] = warna;
          kategoriTotal[kategori] = (kategoriTotal[kategori] ?? 0) + t.amount;
        }

        if (kategoriWarna.isEmpty) {
          return const Center(child: Text("Belum ada data kategori"));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: kategoriWarna.entries.map((entry) {
            final kategori = entry.key;
            final warna = entry.value;
            final total = kategoriTotal[kategori] ?? 0;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: warna,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      kategori,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Text(
                    "Rp ${total.toStringAsFixed(0)}",
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
