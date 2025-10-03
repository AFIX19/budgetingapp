import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/transaction.dart' as mymodel;
import '../../transaction/add_edit_record_page.dart';

class HomeTransactionList extends StatelessWidget {
  final List<mymodel.Transaction> transactions;

  const HomeTransactionList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Card(
          color: const Color(0xFF1C1C1C),
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  transaction.categoryColor?.withOpacity(0.2) ??
                      Colors.grey.withOpacity(0.2),
              child: Icon(
                transaction.categoryIcon,
                color: transaction.categoryColor,
              ),
            ),
            title: Text(
              transaction.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              DateFormat('dd MMM yyyy', 'id_ID').format(transaction.date),
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: Text(
              'Rp ${NumberFormat.decimalPattern('id_ID').format(transaction.amount)}',
              style: TextStyle(
                color: transaction.type == mymodel.TransactionType.income
                    ? Colors.green
                    : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      AddEditRecordPage(transactionToEdit: transaction),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
