import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:budgetting_app/data/models/transaction.dart' as mymodel;

class GrafikBarChart extends StatelessWidget {
  final List<mymodel.Transaction> transactions;
  const GrafikBarChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    Map<int, double> dailyExpense = {};
    for (var t in transactions) {
      if (t.type == mymodel.TransactionType.expense) {
        final day = t.date.day;
        dailyExpense[day] = (dailyExpense[day] ?? 0) + t.amount;
      }
    }

    final spots = dailyExpense.entries.map((e) {
      return BarChartGroupData(
        x: e.key,
        barRods: [BarChartRodData(toY: e.value, color: Colors.red)],
      );
    }).toList();

    return BarChart(
      BarChartData(
        barGroups: spots,
        titlesData: FlTitlesData(show: true),
      ),
    );
  }
}
