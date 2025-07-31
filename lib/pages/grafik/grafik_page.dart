import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:budgetting_app/utils/category_icons.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction.dart';

class GrafikPage extends StatelessWidget {
  const GrafikPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grafik Pengeluaran & Pemasukan')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: GrafikContent(),
      ),
    );
  }
}

class GrafikContent extends StatelessWidget {
  const GrafikContent({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = context.watch<TransactionProvider>().transactions;
    final expenseTransactions = transactions
        .where((t) => t.type == 'expense')

        .toList();
    final incomeTransactions = transactions
        .where((t) => t.type == 'income')
        .toList();

    return Column(
      children: [
        if (incomeTransactions.isNotEmpty) ...[
          const Text(
            'Pemasukan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
        _buildPieChart(incomeTransactions, 'income')
        ],
        const SizedBox(height: 32),
        if (expenseTransactions.isNotEmpty) ...[
          const Text(
            'Pengeluaran',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildPieChart(expenseTransactions, 'expense')
        ],
      ],
    );
  }

 Widget _buildPieChart(List<Transaction> transactions, String type) {
  final grouped = <String, double>{};

  for (final t in transactions) {
  final key = t.categoryName ?? 'Tanpa Kategori';
  grouped[key] = (grouped[key] ?? 0) + t.amount;
}


  final total = grouped.values.fold(0.0, (a, b) => a + b);

  final sections = grouped.entries.map((entry) {
    final category = entry.key;
    final amount = entry.value;
    final percentage = (amount / total) * 100;
    final color = CategoryIcons.getCategoryColor(category, type);

    return PieChartSectionData(
      value: amount,
      title: '${percentage.toStringAsFixed(1)}%',
      color: color,
      radius: 60,
      titleStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }).toList();

  return AspectRatio(
    aspectRatio: 1.3,
    child: PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    ),
  );
}
}