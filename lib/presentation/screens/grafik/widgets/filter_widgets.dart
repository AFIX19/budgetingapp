import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/transaction_provider.dart';

class FilterWidgets extends StatelessWidget {
  const FilterWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownButton<int>(
          value: provider.selectedMonth,
          items: List.generate(12, (i) {
            return DropdownMenuItem(
              value: i + 1,
              child: Text("Bulan ${i + 1}"),
            );
          }),
          onChanged: (val) {
            if (val != null) provider.setMonth(val);
          },
        ),
        const SizedBox(width: 16),
        DropdownButton<int>(
          value: provider.selectedYear,
          items: List.generate(5, (i) {
            final year = DateTime.now().year - i;
            return DropdownMenuItem(
              value: year,
              child: Text("$year"),
            );
          }),
          onChanged: (val) {
            if (val != null) provider.setYear(val);
          },
        ),
      ],
    );
  }
}
