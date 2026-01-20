import 'package:flutter/material.dart';
import 'package:expensetracker/model/expense.dart';
import 'package:expensetracker/widget/expenses_list/expenses_item.dart';

// This class is stateless and doesnt do much. just displays the list of expenses in a ListView which is scrollable
// And it also takes function argument used to remove the displayed expense item using the Dismissable widget 

class ExpensesList extends StatelessWidget {
  const ExpensesList({
    super.key, 
    required this.expense,
    required this.onRemoveExpense,
  });

  final List<Expense> expense;
  final void Function(Expense expense) onRemoveExpense;


  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: expense.length,
      itemBuilder: (ctx, index) => Dismissible( // Dismissable widget is used to remove added expenses on a certain index
        key: ValueKey(expense[index]), 
        onDismissed: (direction) {
        onRemoveExpense(expense[index]);
        }, 
        child: ExpensesItem(expense[index]) // ListView builder context => ExpensesItem and wrapped with the Dismissable widget
        ),
    );
  }
}
