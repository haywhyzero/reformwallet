import 'package:expensetracker/model/ctrl_provider.dart';
import 'package:expensetracker/model/shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class Transactions extends ConsumerWidget {
  const Transactions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localStorage = LocalStorage();
    final expenses = ref.watch(expenseProvider);
    final incomes = ref.watch(incomeProvider);

    final allTransactions = [...incomes, ...expenses];
    allTransactions.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));

    // Group transactions by month
    final Map<String, List<Map<String, dynamic>>> groupedTransactions = {};
    for (var transaction in allTransactions) {
      final month = DateFormat('MMMM yyyy').format(DateTime.parse(transaction['date']));
      if (groupedTransactions[month] == null) {
        groupedTransactions[month] = [];
      }
      groupedTransactions[month]!.add(transaction);
    }

    final monthKeys = groupedTransactions.keys.toList();

    final uuidKey = Uuid();

    return Scaffold(
      appBar: AppBar(
        title: Text('All transactions'),
        leading: IconButton(onPressed: () {
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back)),
      ),
      body: allTransactions.isEmpty
            ? const Center(child: Text('No transactions found.'))
            : ListView.builder(
                itemCount: monthKeys.length,
                itemBuilder: (context, index) {
                  final month = monthKeys[index];
                  final transactionsInMonth = groupedTransactions[month]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Text(
                          month,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                      ),
                      ...transactionsInMonth.map((transaction) {
                        final isExpense = transaction['type'] == 'expense';
                        final amount = transaction['amount'] as double;
                        final date = DateTime.parse(transaction['date']);
                        final icon = isExpense ? Icons.arrow_downward : Icons.arrow_upward;
                        final color = isExpense ? Colors.red : Colors.green;

                        return Dismissible(
                          key: ValueKey(uuidKey.v4()),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            if (isExpense) {
                              final updatedExpenses = ref.read(expenseProvider).where((t) => t['id'] != transaction['id']).toList();
                              ref.read(expenseProvider.notifier).state = updatedExpenses;
                              localStorage.saveTransactions('expenses', updatedExpenses);
                            } else {
                              final updatedIncomes = ref.read(incomeProvider).where((t) => t['id'] != transaction['id']).toList();
                              ref.read(incomeProvider.notifier).state = updatedIncomes;
                              localStorage.saveTransactions('incomes', updatedIncomes);
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${transaction['category']} transaction deleted.')),
                            );
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          child: Card(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: ListTile(
                              leading: Icon(icon, color: color),
                              title: Text(
                                transaction['category'],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                transaction['description'].isNotEmpty
                                    ? transaction['description']
                                    : 'No description',
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('₦${amount.toStringAsFixed(2)}', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                                  Text(DateFormat.yMMMd().format(date), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
    );
  }
}