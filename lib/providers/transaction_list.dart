import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../data/models/transaction.dart' as mymodel;

class TransactionList extends StatelessWidget {
  final List<mymodel.Transaction> transactions;

  const TransactionList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(
        child: Text('Belum ada transaksi'),
      );
    }

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (ctx, i) {
        final tx = transactions[i];
        return Dismissible(
          key: ValueKey(tx.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            padding: const EdgeInsets.only(right: 20),
            alignment: Alignment.centerRight,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Hapus Transaksi?'),
                content: const Text('Yakin mau hapus transaksi ini?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Batal'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
          onDismissed: (_) {
            Provider.of<TransactionProvider>(context, listen: false)
                .deleteTransaction(tx.id);
          },
          child: ListTile(
            title: Text(tx.title),
            subtitle: Text(
              '${tx.date.day}/${tx.date.month}/${tx.date.year}',
            ),
            trailing: Text(
              'Rp ${tx.amount.toStringAsFixed(0)}',
              style: TextStyle(
                color: tx.type == mymodel.TransactionType.income
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ),
        );
      },
    );
  }
}
