import 'package:flutter/material.dart';
import 'package:expensetracker/widget/expenses_list/expenses_list.dart';
import 'package:expensetracker/model/expense.dart';
import 'package:expensetracker/widget/new_expense.dart';

// Expenses is Stateful because it implies several changes which needs a UI update
// Creates a popup modal that is used to create user expense
// Displays the list of expenses created and also manages the remove expenses function and also displays a default if no items has been created

class Expenses extends StatefulWidget {
  const Expenses({super.key});
  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {

  //Create a List of Expense() with a Expense data type
  // List<Data type i.e Expense> _listname = [Expense(), Expense(), e.t.c.]
  //Expense() is an object created in Expense.dart file

  final List<Expense> _registeredExpenses = [
    Expense(
      title: "Prof. Ayomide Course",
      amount: 23.60,
      date: DateTime.now(),
      category: Category.work,
    ),
    Expense(
      title: "Cinema",
      amount: 7.25,
      date: DateTime.now(),
      category: Category.leisure,
    ),
  ];

// Method to add expense typed in by the user
void _addExpense(Expense expense) {
  setState(() {
    _registeredExpenses.add(expense); // Updates the Expenses List created from the popup modal
  });
}

// Method to remove expense by the user when swiped => dimissable()
void _removeExpense(Expense expense) {
  final expensesIndex = _registeredExpenses.indexOf(expense); // Gets the index of the expenses that needs to be removed
  setState(() {
    _registeredExpenses.remove(expense); // Remove the expenses from the list
  }); 
  ScaffoldMessenger.of(context).clearSnackBars(); // Clears the snackbar 
  ScaffoldMessenger.of(context).showSnackBar // Creates or shows a snackbar message, like a popup with an undo button
  (SnackBar(content: Text("Expenses Deleted!"),
  duration: Duration(seconds: 3),
  action: SnackBarAction(label: "Undo", 
  onPressed: () {
    _registeredExpenses.insert(expensesIndex, expense);
  }
  ),
  ),
  );
}

 
// Method of modal popup
void _openmodaloverlay() {
  //NewExpense() contains the page of creating expenses thats updates to the UI
  showModalBottomSheet(
    isScrollControlled: true, 
    context: context, 
    builder: (ctx) => NewExpense(onAddExpense: _addExpense,)); 
}

  @override
  Widget build(BuildContext context) {
     Widget mainContent = Center( // Creates a default widget to display if no expenses has been created
      child: Text('No expenses found. Start adding some!'), 
      );
     if (_registeredExpenses.isNotEmpty) {
      mainContent = ExpensesList(expense: _registeredExpenses, onRemoveExpense: _removeExpense,);
     }
    return Scaffold(
      appBar: AppBar(
        title: Text('ExpenseTracker'),
        actions: [IconButton(onPressed: _openmodaloverlay, icon: Icon(Icons.add))], //Action button of AppBar "+"
      ),
      body: Column(
        children: [
          Text("Chart"),
          // ExpensesList returns a beautiful List of created Expense
          // Expanded is used becuase Column is a Widget list and ExpensesList is also a Widget list. # Nesting of List
          Expanded(child: mainContent),
        ],
      ),
    );
  }
}
