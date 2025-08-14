import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/transaction_provider.dart';

class HomeSummaryWidget extends StatelessWidget {
  const HomeSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final totalIncome = provider.totalIncome;
    final totalExpense = provider.totalExpense;
    final balance = totalIncome - totalExpense;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saldo Anda',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rp ${balance.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(
                title: 'Pemasukan',
                amount: totalIncome,
                color: Colors.green,
              ),
              _buildSummaryItem(
                title: 'Pengeluaran',
                amount: totalExpense,
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String title,
    required double amount,
    required Color color,
  }) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: color)),
        const SizedBox(height: 4),
        Text(
          'Rp ${amount.toStringAsFixed(0)}',
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}

class MonthSelectorWidget extends StatelessWidget {
  const MonthSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final selectedMonth = provider.selectedMonth;
    final selectedYear = provider.selectedYear;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_left, color: Colors.white),
            onPressed: () => provider.changeMonth(-1),
          ),
          Text(
            '${_getMonthName(selectedMonth)} $selectedYear',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_right, color: Colors.white),
            onPressed: () => provider.changeMonth(1),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const List<String> months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    } else {
      return 'Bulan Tidak Valid';
    }
  }
}
