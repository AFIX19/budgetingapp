import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../data/models/transaction.dart' as mymodel;

class HomeWidgets {
  static Widget headerSection(BuildContext context, TransactionProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () => provider.changeMonth(-1),
        ),
        Text(
          '${provider.selectedMonth} / ${provider.selectedYear}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: Icon(Icons.chevron_right),
          onPressed: () => provider.changeMonth(1),
        ),
      ],
    );
  }

  static Widget barChartSection(BuildContext context, TransactionProvider provider) {
    final incomeData = provider.filteredTransactions
        .where((tx) => tx.type == mymodel.TransactionType.income)
        .fold<Map<int, double>>({}, (map, tx) {
      map[tx.date.day] = (map[tx.date.day] ?? 0) + tx.amount;
      return map;
    });

    final expenseData = provider.filteredTransactions
        .where((tx) => tx.type == mymodel.TransactionType.expense)
        .fold<Map<int, double>>({}, (map, tx) {
      map[tx.date.day] = (map[tx.date.day] ?? 0) + tx.amount;
      return map;
    });

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          barGroups: List.generate(31, (day) {
            return BarChartGroupData(
              x: day + 1,
              barRods: [
                BarChartRodData(
                  toY: incomeData[day + 1] ?? 0,
                  color: Colors.green,
                  width: 6,
                ),
                BarChartRodData(
                  toY: expenseData[day + 1] ?? 0,
                  color: Colors.red,
                  width: 6,
                ),
              ],
            );
          }),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(show: false),
        ),
      ),
    );
  }

  static Widget summarySection(BuildContext context, TransactionProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _summaryCard('Income', provider.totalIncome, Colors.green),
        _summaryCard('Expense', provider.totalExpense, Colors.red),
      ],
    );
  }

  static Widget transactionList(BuildContext context, TransactionProvider provider) {
    final transactions = provider.filteredTransactions;
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (ctx, i) {
        final tx = transactions[i];
        return Dismissible(
          key: Key(tx.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) {
            provider.deleteTransaction(tx.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Transaction deleted")),
            );
          },
          background: Container(color: Colors.red),
          child: ListTile(
            title: Text(tx.note ?? ''),
            subtitle: Text(tx.date.toString()),
            trailing: Text('${tx.amount}'),
          ),
        );
      },
    );
  }

  static Widget _summaryCard(String title, double amount, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: color)),
            SizedBox(height: 5),
            Text(amount.toStringAsFixed(2),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
