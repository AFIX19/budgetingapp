import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/models/transaction.dart' as mymodel;
import '../../../providers/transaction_provider.dart';
import '../transaction/add_edit_record_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required transactions});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _searchQuery = '';
  String? _filterType;
  String _dateFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final transactions = context.watch<TransactionProvider>().transactions;

    final now = DateTime.now();

    DateTime getStartDate() {
      switch (_dateFilter) {
        case 'Hari ini':
          return DateTime(now.year, now.month, now.day);
        case 'Minggu ini':
          return now.subtract(Duration(days: now.weekday - 1));
        case 'Bulan ini':
          return DateTime(now.year, now.month, 1);
        case 'Tahun ini':
          return DateTime(now.year, 1, 1);
        default:
          return DateTime(2000); // semua
      }
    }

    final filtered = transactions.where((t) {
      final matchesQuery = t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (t.note?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      final matchesType = _filterType == null || t.type.name == _filterType;
      final matchesDate = t.date.isAfter(getStartDate().subtract(const Duration(days: 1)));
      return matchesQuery && matchesType && matchesDate;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Pencarian', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Cari judul atau catatan...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF1C1C1C),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DropdownButton<String>(
                      value: _dateFilter,
                      dropdownColor: Colors.black,
                      items: const [
                        DropdownMenuItem(
                          value: "Semua",
                          child: Text("Semua Waktu", style: TextStyle(color: Colors.white)),
                        ),
                        DropdownMenuItem(
                          value: "Hari ini",
                          child: Text("Harian", style: TextStyle(color: Colors.white)),
                        ),
                        DropdownMenuItem(
                          value: "Minggu ini",
                          child: Text("Mingguan", style: TextStyle(color: Colors.white)),
                        ),
                        DropdownMenuItem(
                          value: "Bulan ini",
                          child: Text("Bulanan", style: TextStyle(color: Colors.white)),
                        ),
                        DropdownMenuItem(
                          value: "Tahun ini",
                          child: Text("Tahunan", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _dateFilter = value!;
                        });
                      },
                    ),
                    // Text("${filtered.length} hasil", style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final transaction = filtered[index];
                return Card(
                  color: const Color(0xFF1C1C1C),
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: transaction.categoryColor?.withOpacity(0.2) ?? Colors.grey.withOpacity(0.2),
                      child: Icon(transaction.categoryIcon, color: transaction.categoryColor),
                    ),
                    title: Text(transaction.title, style: const TextStyle(color: Colors.white)),
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
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => AddEditRecordPage(transactionToEdit: transaction),
                      ));
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
