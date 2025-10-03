import 'package:budgetting_app/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/models/transaction.dart' as mymodel;
import '../../../providers/user_provider.dart';
import '../../../core/widgets/empty_data.dart';
import '../transaction/add_edit_record_page.dart';
import 'widgets/home_header.dart';
import 'widgets/home_summary.dart';
import 'widgets/home_transaction_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedMonth = DateTime.now();

  DateTime get selectedDate => _selectedMonth;

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
      Provider.of<TransactionProvider>(
        context,
        listen: false,
      ).fetchTransactionsForMonth(_selectedMonth);
    }
  }

  void _changeMonth(DateTime picked) {
    setState(() {
      _selectedMonth = DateTime(picked.year, picked.month, 1);
    });
    _fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final allTransactions = context.watch<TransactionProvider>().transactions;

    final filteredTransactions = allTransactions
        .where(
          (t) =>
              t.date.year == _selectedMonth.year &&
              t.date.month == _selectedMonth.month,
        )
        .toList();

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
      body: SafeArea(
        child: Column(
          children: [
            HomeHeader(
              selectedDate: selectedDate,
              allTransactions: allTransactions,
              onMonthChanged: _changeMonth,
            ),
            HomeSummary(
              totalIncome: totalIncome,
              totalExpense: totalExpense,
              totalBalance: totalBalance,
            ),
            Expanded(
              child: context.watch<TransactionProvider>().isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.yellow),
                    )
                  : filteredTransactions.isEmpty
                      ? const EmptyData()
                      : HomeTransactionList(transactions: filteredTransactions),
            ),
          ],
        ),
      ),
    );
  }
}
