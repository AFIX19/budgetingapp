import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../search/search_page.dart';
import '../../../../data/models/transaction.dart' as mymodel;

class HomeHeader extends StatelessWidget {
  final DateTime selectedDate;
  final List<mymodel.Transaction> allTransactions;
  final Function(DateTime) onMonthChanged;

  const HomeHeader({
    super.key,
    required this.selectedDate,
    required this.allTransactions,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.calendar_today, color: Colors.white),
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                    locale: const Locale("id", "ID"),
                  );
                  if (picked != null) {
                    onMonthChanged(picked);
                  }
                },
              ),
              const Text(
                "Pengelola Keuangan",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
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
            ],
          ),
        ),
    
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                DateFormat.y().format(selectedDate),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                   color: Colors.white70),
                  ),
              const SizedBox(width: 8),

              DropdownButton<String>(
                dropdownColor: Colors.black,
                underline: const SizedBox(),
                value: DateFormat.MMMM('id_ID').format(selectedDate),
                items: List.generate(12, (index) {
                  final month = DateTime(0, index + 1);
                  return DropdownMenuItem<String>(
                    value: DateFormat.MMMM('id_ID').format(month),
                    child: Text(
                      DateFormat.MMMM('id_ID').format(month),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  );
                }),
                onChanged: (value) {
                  if (value != null) {
                    final monthIndex =
                        DateFormat.MMMM('id_ID').parse(value).month;
                    onMonthChanged(DateTime(selectedDate.year, monthIndex));
                  }
                },
              ),
            ],
          
          ),
        ),
      ],
    );
  }
}
