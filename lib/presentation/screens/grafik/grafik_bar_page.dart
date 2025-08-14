import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../../../data/models/transaction.dart' as mymodel;

class GrafikBarPage extends StatefulWidget {
  const GrafikBarPage({super.key});

  @override
  State<GrafikBarPage> createState() => _GrafikBarPageState();
}

class _GrafikBarPageState extends State<GrafikBarPage> {
  String selectedType = 'Pengeluaran';
  bool isMonthly = true;
  DateTime currentDate = DateTime.now();

  List<double> chartData = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  void _loadData() {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final transactions = provider.filteredTransactions;

    if (isMonthly) {
      final filtered = transactions.where((tx) =>
          tx.date.month == currentDate.month &&
          tx.date.year == currentDate.year &&
          (selectedType == 'Pemasukan'
              ? tx.type == mymodel.TransactionType.income
              : tx.type == mymodel.TransactionType.expense));

      Map<int, double> perDay = {};
      for (var tx in filtered) {
        perDay[tx.date.day] = (perDay[tx.date.day] ?? 0) + tx.amount;
      }
      chartData = List.generate(
        DateUtils.getDaysInMonth(currentDate.year, currentDate.month),
        (day) => perDay[day + 1] ?? 0,
      );
    } else {
      final filtered = transactions.where((tx) =>
          tx.date.year == currentDate.year &&
          (selectedType == 'Pemasukan'
              ? tx.type == mymodel.TransactionType.income
              : tx.type == mymodel.TransactionType.expense));

      Map<int, double> perMonth = {};
      for (var tx in filtered) {
        perMonth[tx.date.month] = (perMonth[tx.date.month] ?? 0) + tx.amount;
      }
      chartData = List.generate(12, (m) => perMonth[m + 1] ?? 0);
    }

    setState(() {});
  }

  void _changeMonth(int change) {
    setState(() {
      currentDate = DateTime(currentDate.year, currentDate.month + change, 1);
      _loadData();
    });
  }

  void _changeYear(int change) {
    setState(() {
      currentDate = DateTime(currentDate.year + change, currentDate.month, 1);
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    String titlePeriod = isMonthly
        ? DateFormat('MMM yyyy').format(currentDate)
        : currentDate.year.toString();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          DropdownButton<String>(
            value: selectedType,
            dropdownColor: Colors.black,
            underline: const SizedBox(),
            items: ['Pengeluaran', 'Pemasukan']
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type, style: const TextStyle(color: Colors.white)),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedType = value!;
                _loadData();
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () =>
                      isMonthly ? _changeMonth(-1) : _changeYear(-1),
                  icon: const Icon(Icons.chevron_left, color: Colors.white)),
              Text(titlePeriod,
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
              IconButton(
                  onPressed: () =>
                      isMonthly ? _changeMonth(1) : _changeYear(1),
                  icon: const Icon(Icons.chevron_right, color: Colors.white)),
            ],
          ),
          Expanded(
            child: chartData.isEmpty
                ? const Center(
                    child: Text("Tidak ada data",
                        style: TextStyle(color: Colors.white38)),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: BarChart(
                      BarChartData(
                        barGroups: chartData
                            .asMap()
                            .entries
                            .map((e) => BarChartGroupData(
                                  x: e.key,
                                  barRods: [
                                    BarChartRodData(
                                      toY: e.value,
                                      width: 16,
                                      color: Colors.yellow,
                                    )
                                  ],
                                ))
                            .toList(),
                        titlesData: FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(show: false),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
