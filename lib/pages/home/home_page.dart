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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTransactions();
    });
  }

  void _fetchTransactions() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.currentUser != null) {
      Provider.of<TransactionProvider>(context, listen: false)
          .fetchTransactionsForMonth(_selectedMonth);
    }
  }

  void _changeMonth(int monthsToAdd) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + monthsToAdd, 1);
    });
    _fetchTransactions();
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
        }
        final totalBalance = totalIncome - totalExpense;

        return Scaffold(
          backgroundColor: Colors.black, 
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Header dengan ikon menu, judul, search, dan kalendar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.menu, color: Colors.white),
                        const Text(
                          'Pengelola Keuangan',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.search, color: Colors.white),
                            const SizedBox(width: 16),
                            const Icon(Icons.calendar_today, color: Colors.white),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16), // Jarak setelah baris header
                    // Bagian pemilihan bulan
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('yyyy', 'id_ID').format(_selectedMonth),
                          style: const TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => _changeMonth(-1),
                              child: const Icon(Icons.arrow_left, color: Colors.white), // Tombol panah kiri
                            ),
                            Text(
                              DateFormat.yMMMM('id_ID').format(_selectedMonth), 
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                             TextButton(
                              onPressed: () => _changeMonth(1),
                              child: const Icon(Icons.arrow_right, color: Colors.white), // Tombol panah kanan
                            ),
                          ],
                        ),
                       ],
                    ),
                    const SizedBox(height: 16), 
                   
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1C), 
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text('Pengeluaran', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              Text(
                                'Rp -${NumberFormat.decimalPattern('id_ID').format(totalExpense)}',
                                style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold), 
                              ),
                            ],
                          ),
                          Container(
                            width: 1,
                            height: 30,
                            color: Colors.grey.shade800, // Garis pemisah
                          ),
                          Column(
                            children: [
                              const Text('Pemasukan', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              Text(
                                'Rp ${NumberFormat.decimalPattern('id_ID').format(totalIncome)}',
                                style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold), 
                              ),
                            ],
                          ),
                          Container(
                            width: 1,
                            height: 30,
                            color: Colors.grey.shade800, // Garis pemisah
                          ),
                          Column(
                            children: [
                              const Text('Saldo', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              Text(
                                'Rp ${NumberFormat.decimalPattern('id_ID').format(totalBalance)}',
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), 
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
                        ? const EmptyData() // Widget EmptyData Anda sudah disetel untuk tampilan gelap
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            itemCount: filteredTransactions.length,
                            itemBuilder: (context, index) {
                              // Ini untuk memastikan urutan terbaru di atas jika bulan saat ini
                              // Jika Anda ingin selalu terbaru di atas, tidak perlu kondisional
                              final transaction = filteredTransactions[_selectedMonth.year == DateTime.now().year && _selectedMonth.month == DateTime.now().month ? index : filteredTransactions.length - 1 - index];
                              return Card(
                                color: const Color(0xFF1C1C1C), // Background gelap untuk setiap card transaksi
                                margin: const EdgeInsets.symmetric(vertical: 8.0),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: transaction.categoryColor?.withOpacity(0.2) ?? Colors.grey.withOpacity(0.2),
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
                                            ? ' (${transaction.fromAccount ?? 'Tidak Ada'} -> ${transaction.toAccount ?? 'Tidak Ada'})'
                                            : ' (${transaction.fromAccount ?? 'Tidak Ada'})'),
                                    style: TextStyle(color: Colors.grey.shade400),
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