import 'package:expensetracker/model/ctrl_provider.dart';
import 'package:expensetracker/pages/tax_refund_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class TransactionStatPage extends ConsumerWidget {
  const TransactionStatPage({super.key});

  

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseProvider);
    // final incomes = ref.watch(incomeProvider);

    final now = DateTime.now();
    final prevMonth = DateTime(now.year, now.month - 1, now.day);

    final currentMonthExpenses = expenses
        .where((t) => DateTime.parse(t['date']).month == now.month && DateTime.parse(t['date']).year == now.year)
        .fold<double>(0.0, (sum, item) => sum + (item['amount'] as double));

    final prevMonthExpenses = expenses
        .where((t) => DateTime.parse(t['date']).month == prevMonth.month && DateTime.parse(t['date']).year == prevMonth.year)
        .fold<double>(0.0, (sum, item) => sum + (item['amount'] as double));

    final difference = currentMonthExpenses - prevMonthExpenses;
    final hasIncreased = difference > 0;
    final percentageChange = prevMonthExpenses == 0 ? 100.0 : (difference.abs() / prevMonthExpenses) * 100;

    final Map<String, double> expenseByCategory = {};
    for (var expense in expenses) {
      final category = expense['category'] as String;
      final amount = expense['amount'] as double;
      expenseByCategory.update(category, (value) => value + amount, ifAbsent: () => amount);
    }

    final List<Color> sectionColors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
      Colors.brown,
    ];

    final entries = expenseByCategory.entries.toList();
    final List<PieChartSectionData> pieChartSections = List.generate(entries.length, (index) {
      final entry = entries[index];
      return PieChartSectionData(
        value: entry.value,
        title: '${entry.key}\n${NumberFormat.compact().format(entry.value)}',
        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
        radius: 100,
        color: sectionColors[index % sectionColors.length],
      );
    });

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Spending Insights',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildMonthlyComparisonCard(
              currentMonthExpenses,
              hasIncreased,
              percentageChange,
              context,
            ),
            const SizedBox(height: 30),
            const Text(
              'Expense Breakdown',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (expenses.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Text('No expense data to show.'),
                ),
              )
            else
              SizedBox(
                height: 300,
                child: PieChart(
                  PieChartData(
                    sections: pieChartSections,
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                    
                  ),
                  
                ),
              ),

              SizedBox(height: 25,),

             OutlinedButton.icon(onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => TaxRefundPage())
              );
             }, label: Text('Check Refund'), icon: Icon(Icons.price_change_outlined), 
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyComparisonCard(
    double currentMonthTotal,
    bool hasIncreased,
    double percentage,
    BuildContext context,
  ) {
    final formatter = NumberFormat.currency(locale: 'en_NG', symbol: '₦');
    final monthName = DateFormat('MMMM').format(DateTime.now());

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending in $monthName',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              formatter.format(currentMonthTotal),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 30),
            Row(
              children: [
                Icon(
                  hasIncreased ? Icons.arrow_upward : Icons.arrow_downward,
                  color: hasIncreased ? Colors.red : Colors.green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${percentage.toStringAsFixed(1)}% ${hasIncreased ? "more" : "less"} than last month',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: hasIncreased ? Colors.red : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              hasIncreased
                  ? 'You are spending more this month. Keep an eye on your budget!'
                  : 'Great job! You\'ve reduced your spending this month.',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}