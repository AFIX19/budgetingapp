import 'package:budgetting_app/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/models/transaction.dart' as mymodel;
import '../../../providers/user_provider.dart';
import '../../../widgets/empty_data.dart';
import '../transaction/add_edit_record_page.dart';
import '../../../pages/search_page.dart';
import '../../../presentation/screens/home/home_widgets.dart';

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
    final allTransactions = context.watch<TransactionProvider>().transactions;

    final filteredTransactions = allTransactions.where((t) =>
      t.date.year == _selectedMonth.year &&
      t.date.month == _selectedMonth.month
    ).toList();

    double totalIncome = 0;
    double totalExpense =  0;

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
                        IconButton(
                          icon: const Icon(Icons.search, color: Colors.white),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => SearchPage(transactions: allTransactions),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.calendar_today, color: Colors.white),
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedMonth,
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                              locale: const Locale("id", "ID"),
                            );
                            if (picked != null && picked != _selectedMonth) {
                              setState(() {
                                _selectedMonth = DateTime(picked.year, picked.month, 1);
                                _fetchTransactions();
                              });
                            }
                          },
                        )
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
                          child: const Icon(Icons.arrow_left, color: Colors.white),
                        ),
                        Text(
                          DateFormat.yMMMM('id_ID').format(_selectedMonth),
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () => _changeMonth(1),
                          child: const Icon(Icons.arrow_right, color: Colors.white),
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
                            'Rp ${NumberFormat.decimalPattern('id_ID').format(totalExpense)}',
                            style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Container(width: 1, height: 30, color: Colors.grey.shade800),
                      Column(
                        children: [
                          const Text('Pemasukan', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(
                            'Rp ${NumberFormat.decimalPattern('id_ID').format(totalIncome)}',
                            style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Container(width: 1, height: 30, color: Colors.grey.shade800),
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
            child: context.watch<TransactionProvider>().isLoading
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
                            backgroundColor: transaction.categoryColor?.withOpacity(0.2) ?? Colors.grey.withOpacity(0.2),
                            child: Icon(transaction.categoryIcon, color: transaction.categoryColor),
                          ),
                          title: Text(transaction.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
    
  }
}
