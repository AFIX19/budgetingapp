import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/transaction.dart' as mymodel;
import '../../providers/transaction_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/empty_data.dart';
import '../transaction/add_edit_record_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Jika Anda ingin memastikan data dimuat saat masuk ke HomePage,
    // Anda bisa memicu fetchTransactionsForMonth di sini.
    // Namun, karena TransactionProvider sudah memiliki listener real-time,
    // ini mungkin tidak sepenuhnya diperlukan kecuali Anda perlu filter spesifik.
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final userProvider = Provider.of<UserProvider>(context, listen: false);
    //   if (userProvider.currentUser != null) {
    //     Provider.of<TransactionProvider>(context, listen: false)
    //         .fetchTransactionsForMonth(_selectedMonth);
    //   }
    // });
  }

  void _changeMonth(int monthsToAdd) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + monthsToAdd, 1);
    });
    // Memuat ulang transaksi untuk bulan yang dipilih
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.currentUser != null) {
      Provider.of<TransactionProvider>(context, listen: false)
          .fetchTransactionsForMonth(_selectedMonth);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        final filteredTransactions = transactionProvider.transactions.where((t) {
          return t.date.year == _selectedMonth.year && t.date.month == _selectedMonth.month;
        }).toList();

        double totalIncome = 0;
        double totalExpense = 0;
        
        for (var t in filteredTransactions) {
          if (t.type == mymodel.TransactionType.income) {
            totalIncome += t.amount;
          } else if (t.type == mymodel.TransactionType.expense) {
            totalExpense += t.amount;
          }
          // Transfer tidak dihitung ke income/expense total saldo akun utama
          // Jika perlu saldo total akun, Anda harus memiliki data akun terpisah.
        }
        final totalBalance = totalIncome - totalExpense; // Saldo sederhana untuk bulan ini

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Catatan Keuangan',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () async {
                  final userProvider = Provider.of<UserProvider>(context, listen: false);
                  try {
                    await userProvider.signOut();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal logout: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Bagian Header Bulan dan Total
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
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
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1C),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text('Pemasukan', style: TextStyle(color: Colors.green, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(
                                'Rp ${NumberFormat.decimalPattern('id_ID').format(totalIncome)}',
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text('Pengeluaran', style: TextStyle(color: Colors.red, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(
                                'Rp ${NumberFormat.decimalPattern('id_ID').format(totalExpense)}',
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text('Saldo', style: TextStyle(color: Colors.yellow, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(
                                'Rp ${NumberFormat.decimalPattern('id_ID').format(totalBalance)}',
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: transactionProvider.isLoading
                        ? const Center(child: CircularProgressIndicator(color: Colors.yellow))
                        : filteredTransactions.isEmpty
                            ? const EmptyData()
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                itemCount: filteredTransactions.length,
                                itemBuilder: (context, index) {
                                  final transaction = filteredTransactions[index];
                                  return Card(
                                    color: const Color(0xFF1C1C1C),
                                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        // >>>>>> PERBAIKAN DI SINI <<<<<<
                                        backgroundColor: transaction.categoryColor != null
                                            ? transaction.categoryColor!.withOpacity(0.2)
                                            : Colors.grey.withOpacity(0.2), // Default jika null
                                        child: Icon(
                                          transaction.categoryIcon,
                                          color: transaction.categoryColor,
                                        ),
                                      ),
                                      title: Text(
                                        transaction.title,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        DateFormat('dd MMMM yyyy', 'id_ID').format(transaction.date) +
                                            (transaction.type == mymodel.TransactionType.transfer
                                                ? ' (${transaction.fromAccount ?? 'Tidak Ada'} -> ${transaction.toAccount ?? 'Tidak Ada'})' // Tambahkan null check
                                                : ' (${transaction.fromAccount ?? 'Tidak Ada'})'), // Tambahkan null check
                                        style: TextStyle(color: Colors.grey[400]),
                                      ),
                                      trailing: Text(
                                        'Rp ${NumberFormat.decimalPattern('id_ID').format(transaction.amount)}',
                                        style: TextStyle(
                                          color: transaction.type == mymodel.TransactionType.income
                                              ? Colors.green
                                              : transaction.type == mymodel.TransactionType.expense
                                                  ? Colors.red
                                                  : Colors.yellow,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => AddEditRecordPage(transactionToEdit: transaction),
                                          ),
                                        );
                                      },
                                      onLongPress: () {
                                        _showDeleteDialog(context, transaction.id);
                                      },
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, String transactionId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        title: const Text('Hapus Transaksi', style: TextStyle(color: Colors.white)),
        content: const Text('Apakah Anda yakin ingin menghapus transaksi ini?', style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Batal', style: TextStyle(color: Colors.yellow)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
              try {
                await transactionProvider.deleteTransaction(transactionId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Transaksi berhasil dihapus!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                print('Error deleting transaction: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal menghapus transaksi: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}