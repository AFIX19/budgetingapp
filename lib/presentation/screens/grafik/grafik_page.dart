import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../data/models/transaction.dart' as mymodel;

class GrafikPage extends StatefulWidget {
  const GrafikPage({super.key});

  @override
  State<GrafikPage> createState() => _GrafikPageState();
}

class _GrafikPageState extends State<GrafikPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ===== Helpers =====

  String _formatMoney(num v) {
    final f = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return f.format(v);
  }

  int _daysInMonth(int year, int month) {
    return DateUtils.getDaysInMonth(year, month);
  }

  Map<String, _CategoryAgg> _buildExpenseByCategory(List<mymodel.Transaction> txs) {
    final map = <String, _CategoryAgg>{};
    for (final t in txs) {
      if (t.type != mymodel.TransactionType.expense) continue;
      final key = (t.categoryName ?? 'Lainnya').trim().isEmpty ? 'Lainnya' : (t.categoryName ?? 'Lainnya');
      final current = map[key];
      final color = t.categoryColor ?? _defaultPalette[map.length % _defaultPalette.length];
      if (current == null) {
        map[key] = _CategoryAgg(amount: t.amount, color: color);
      } else {
        map[key] = current.copyWith(amount: current.amount + t.amount);
      }
    }
    return map;
  }

  double _sumExpense(List<mymodel.Transaction> txs) {
    double total = 0;
    for (final t in txs) {
      if (t.type == mymodel.TransactionType.expense) total += t.amount;
    }
    return total;
  }

  Map<int, double> _expensePerDay(List<mymodel.Transaction> txs) {
    final map = <int, double>{};
    for (final t in txs) {
      if (t.type != mymodel.TransactionType.expense) continue;
      final d = t.date.day;
      map[d] = (map[d] ?? 0) + t.amount;
    }
    return map;
  }

  // ===== UI =====

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final txs = provider.filteredTransactions;
    final year = provider.selectedYear;
    final month = provider.selectedMonth;
    final monthLabel = DateFormat.yMMMM('id_ID').format(DateTime(year, month));

    final byCat = _buildExpenseByCategory(txs);
    final totalExpense = _sumExpense(txs);
    final daysInMonth = _daysInMonth(year, month);
    final avgDaily = daysInMonth == 0 ? 0 : totalExpense / daysInMonth;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text('Grafik', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Header bulan
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => provider.changeMonth(-1),
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                ),
                Column(
                  children: [
                    Text(
                      monthLabel,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pengeluaran bulan ini',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => provider.changeMonth(1),
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                ),
              ],
            ),
          ),

          // Bagian Chart (yang bisa digeser)
          Container(
            height: 280,
            child: Column(
              children: [
                // Chart Area
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    children: [
                      _chartDonutPerKategori(context, byCat, totalExpense),
                      _chartDonutRingkas(context, totalExpense),
                      _chartBarHarian(context, txs, year, month, totalExpense.toDouble(), avgDaily.toDouble()),
                    ],
                  ),
                ),
                
                // Dot indicator
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      final active = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 18 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: active ? Colors.yellow : Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          // Detail Pengeluaran (tetap di tempat)
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.black,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Pengeluaran • $monthLabel',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    if (totalExpense == 0)
                      _emptyListPlaceholder()
                    else
                      Column(
                        children: byCat.entries.map((e) {
                          final name = e.key;
                          final agg = e.value;
                          final percent = (agg.amount / totalExpense) * 100;
                          return _categoryDetailRow(
                            color: agg.color ?? Colors.white,
                            title: name,
                            percentage: '${percent.toStringAsFixed(1)}%',
                            amount: _formatMoney(agg.amount),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Slide 1: Donut per kategori dengan legend di samping
  Widget _chartDonutPerKategori(
    BuildContext context,
    Map<String, _CategoryAgg> byCat,
    double totalExpense,
  ) {
    final sections = <PieChartSectionData>[];
    final legendItems = <_LegendItem>[];

    if (totalExpense > 0 && byCat.isNotEmpty) {
      int idx = 0;
      byCat.forEach((name, agg) {
        final percent = (agg.amount / totalExpense) * 100;
        final color = agg.color ?? _defaultPalette[idx % _defaultPalette.length];
        sections.add(
          PieChartSectionData(
            value: agg.amount,
            title: '${percent.toStringAsFixed(0)}%',
            radius: 55,
            titleStyle: const TextStyle(
              color: Colors.black, 
              fontWeight: FontWeight.bold, 
              fontSize: 10
            ),
            color: color,
          ),
        );
        legendItems.add(_LegendItem(
          color: color,
          title: name,
          subtitle: '${percent.toStringAsFixed(1)}%',
        ));
        idx++;
      });
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Donut Chart
          Expanded(
            flex: 6,
            child: Container(
              height: 140,
              child: totalExpense == 0 || sections.isEmpty
                  ? _emptyDonut()
                  : Stack(
                      children: [
                        PieChart(
                          PieChartData(
                            sections: sections,
                            centerSpaceRadius: 55,
                            sectionsSpace: 2,
                          ),
                        ),
                        Center(
                          child: Text(
                            '+${_formatMoney(totalExpense).substring(3)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Legend
          Expanded(
            flex: 4,
            child: Container(
              height: 140,
              child: totalExpense == 0 || legendItems.isEmpty
                  ? _emptyLegend()
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: legendItems.map((item) => _legendRow(item)).toList(),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // Slide 2: Donut ringkas dengan info tanggal
  Widget _chartDonutRingkas(
    BuildContext context,
    double totalExpense,
  ) {
    final nowStr = DateFormat('d MMM').format(DateTime.now());

    final sections = totalExpense == 0
        ? <PieChartSectionData>[]
        : [
            PieChartSectionData(
              value: totalExpense,
              color: Colors.yellow,
              title: '',
              radius: 50,
            ),
            PieChartSectionData(
              value: totalExpense * 0,
            ),
            PieChartSectionData(
              value: totalExpense * 0.1, // filler kecil
              color: Colors.white10,
              title: '',
              radius: 50,
            )
          ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Donut Chart
          Expanded(
            flex: 3,
            child: Container(
              height: 120,
              child: totalExpense == 0
                  ? _emptyDonut()
                  : Stack(
                      children: [
                        PieChart(
                          PieChartData(
                            sections: sections,
                            centerSpaceRadius: 50,
                            sectionsSpace: 2,
                          ),
                        ),
                        Center(
                          child: Text(
                            '+${_formatMoney(totalExpense).substring(3)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Info panel
          Expanded(
            flex: 3,
            child: Container(
              height: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        nowStr,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatMoney(totalExpense),
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Slide 3: Bar chart harian
  Widget _chartBarHarian(
    BuildContext context,
    List<mymodel.Transaction> txs,
    int year,
    int month,
    double totalExpense,
    double avgDaily,
  ) {
    final perDay = _expensePerDay(txs);
    final days = _daysInMonth(year, month);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Stats cards
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1C),
                    borderRadius: BorderRadius.circular(7),
                  ),              
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total: ${_formatMoney(totalExpense)}',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                      Text(
                        'Rata-rata: ${_formatMoney(avgDaily)}',
                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Bar Chart
          Expanded(
            child: BarChart(
              BarChartData(
                backgroundColor: Colors.transparent,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                barTouchData: BarTouchData(
                  enabled: false,
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 18,
                      getTitlesWidget: (value, meta) {
                        final d = value.toInt();
                        // tampilkan hanya beberapa tanggal
                        if (![1, 8, 16, 24, 31].contains(d) || d > days) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          '$d',
                          style: const TextStyle(color: Colors.white54, fontSize: 10),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                barGroups: List.generate(days, (i) {
                  final day = i + 1;
                  final val = perDay[day] ?? 0;
                  return BarChartGroupData(
                    x: day,
                    barRods: [
                      BarChartRodData(
                        toY: val == 0 ? 0.01 : val, // minimal value untuk visibility
                        width: 4,
                        color: Colors.yellow,
                        borderRadius: BorderRadius.circular(2),
                      )
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== Reusable UI parts =====

  Widget _legendRow(_LegendItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: item.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.title,
              style: const TextStyle(color: Colors.white, fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            item.subtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _categoryDetailRow({
    required Color color,
    required String title,
    required String percentage,
    required String amount,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getCategoryIcon(title),
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  percentage,
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'hadiah':
        return Icons.card_giftcard;
      case 'pakaian':
        return Icons.checkroom;
      case 'sayur-mayur':
        return Icons.eco;
      case 'belanja':
        return Icons.shopping_cart;
      case 'makanan ringan':
        return Icons.fastfood;
      case 'lotre':
        return Icons.confirmation_number;
      default:
        return Icons.category;
    }
  }

  Widget _emptyDonut() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.pie_chart_outline, color: Colors.white24, size: 40),
          SizedBox(height: 8),
          Text('Belum ada data', style: TextStyle(color: Colors.white38)),
        ],
      ),
    );
  }

  Widget _emptyLegend() {
    return Center(
      child: Text('Belum ada data', style: const TextStyle(color: Colors.white38)),
    );
  }

  Widget _emptyListPlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: const [
            Icon(Icons.receipt_long, color: Colors.white24, size: 48),
            SizedBox(height: 12),
            Text('Belum ada pengeluaran bulan ini', style: TextStyle(color: Colors.white38)),
          ],
        ),
      ),
    );
  }
}

// ===== Models/UI helpers =====

class _LegendItem {
  final Color color;
  final String title;
  final String subtitle;
  _LegendItem({required this.color, required this.title, required this.subtitle});
}

class _CategoryAgg {
  final double amount;
  final Color? color;
  _CategoryAgg({required this.amount, this.color});

  _CategoryAgg copyWith({double? amount, Color? color}) {
    return _CategoryAgg(amount: amount ?? this.amount, color: color ?? this.color);
  }
}

// Palet warna fallback kalau categoryColor null
const List<Color> _defaultPalette = [
  Color(0xFFFFD166), // kuning
  Color(0xFFEF476F), // pink
  Color(0xFF06D6A0), // hijau
  Color(0xFF118AB2), // biru
  Color(0xFF9B5DE5), // ungu
  Color(0xFFF4A261), // oranye
  Color(0xFF2A9D8F), // teal
  Color(0xFFE76F51), // salmon
];