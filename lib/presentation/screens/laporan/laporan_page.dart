import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/models/transaction.dart' as mymodel;
import '../../../providers/transaction_provider.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDataForMonth();
    });
  }

  void _fetchDataForMonth() {
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    if (transactionProvider.currentUser != null) {
      transactionProvider.fetchTransactionsForMonth(_selectedMonth);
    }
  }

  void _changeMonth(int monthsToAdd) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + monthsToAdd, 1);
    });
    _fetchDataForMonth(); 
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        final filteredTransactions = transactionProvider.transactions.where((t) {
          return t.date.year == _selectedMonth.year && t.date.month == _selectedMonth.month;
        }).toList();

        Map<String, double> expenseByCategory = {};
        Map<String, double> incomeByCategory = {};

        for (var t in filteredTransactions) {
          if (t.type == mymodel.TransactionType.expense) {
            expenseByCategory.update(t.categoryName ?? 'Lain-lain', (value) => value + t.amount,
                ifAbsent: () => t.amount);
          } else if (t.type == mymodel.TransactionType.income) {
            // >>>>>> PERBAIKAN DI SINI <<<<<<
            incomeByCategory.update(t.categoryName ?? 'Lain-lain', (value) => value + t.amount,
                ifAbsent: () => t.amount);
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Laporan Keuangan',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_left, color: Colors.white),
                      onPressed: () => _changeMonth(-1),
                    ),
                    Text(
                      DateFormat.yMMMM('id_ID').format(_selectedMonth),
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_right, color: Colors.white),
                      onPressed: () => _changeMonth(1),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: transactionProvider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.yellow))
                    : filteredTransactions.isEmpty
                        ? const Center(
                            child: Text(
                              'Tidak ada data transaksi untuk bulan ini.',
                              style: TextStyle(color: Colors.white54, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle('Laporan Pengeluaran Berdasarkan Kategori'),
                                  _buildCategoryList(expenseByCategory, Colors.red),
                                  const SizedBox(height: 20),
                                  _buildSectionTitle('Laporan Pemasukan Berdasarkan Kategori'),
                                  _buildCategoryList(incomeByCategory, Colors.green),
                                ],
                              ),
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCategoryList(Map<String, double> data, Color color) {
    if (data.isEmpty) {
      return const Text(
        'Belum ada data.',
        style: TextStyle(color: Colors.white70),
      );
    }
    return Column(
      children: data.entries.map((entry) {
        return Card(
          color: const Color(0xFF1C1C1C),
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            leading: Icon(
              Icons.category,
              color: color,
            ),
            title: Text(
              entry.key,
              style: const TextStyle(color: Colors.white),
            ),
            trailing: Text(
              'Rp ${NumberFormat.decimalPattern('id_ID').format(entry.value)}',
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }).toList(),
    );
  }
}