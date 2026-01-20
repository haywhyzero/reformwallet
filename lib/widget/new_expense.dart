import 'package:flutter/material.dart';
import 'package:expensetracker/model/expense.dart';

// A Stateful Widget class that works from the pop up modal created in Expenses.dart file
// It contains all the necessary widget that helps in creating a new expenses 
// And the created expenses are returned

class NewExpense extends StatefulWidget {
  const NewExpense({super.key, required this.onAddExpense});

  final void Function(Expense expense) onAddExpense;


  @override
  State<NewExpense> createState() => _NewExpenseState();
}

class _NewExpenseState extends State<NewExpense> {
final _titlecontroller = TextEditingController();
final _amountcontroller = TextEditingController();
DateTime? _selectedDate;
Category _selectedCategory = Category.leisure;

// override with a dispose method that clears the controllers after being used. it is in-built just like initState() and setState()
@override
  void dispose() {
    _titlecontroller.dispose();
    _amountcontroller.dispose();
    super.dispose();
  }

  // Datepicker function that displays a showDatePicker()
  void _datepicker() async {
    var now = DateTime.now();
    final firstdate = DateTime(now.year - 10, now.month, now.day);
    final pickedDate = await showDatePicker(context: context, firstDate: firstdate, lastDate: now);

    setState(() {
      _selectedDate = pickedDate;
    });
  }

  void _submitformValidate() {
   final enteredamount = double.tryParse(_amountcontroller.text);
   final isvalidamount = enteredamount == null || enteredamount <= 0;
   if (_titlecontroller.text.trim().isEmpty || isvalidamount || _selectedDate == null) {
      //Show Error message!
      showDialog(context: context, 
      builder: (ctx) => AlertDialog(title: Text("An Error Occured!"),
      content: Text("Please make sure a valid title, amount, date and category was entered."),
      actions: [
        TextButton(onPressed: () {
          Navigator.pop(ctx);
        }, child: Text('Okay'))
      ],
)
      );
      return;
   }
   
  widget.onAddExpense(
    Expense(title: _titlecontroller.text, amount: enteredamount, date: _selectedDate!, category: _selectedCategory)
  );

  Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      child: Column(
        children: [
          TextField( // TextField for title and a controller that controls the inputted text
            controller: _titlecontroller,
            maxLength: 50,
            decoration: InputDecoration(
              label: Text('Title:'),
            ),
          ),
           Row(
             children: [
               Expanded(
                 child: TextField( // Textfield for amount
                  controller: _amountcontroller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixText: '\$',
                    label: Text('Amount:'),
                  ),
                  ),
               ),
                Expanded( // Widget inside a Widget Row(Row()) so we expanded
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Displays a default text if no dates has been selected
                    Text(_selectedDate == null ? 'No date selected' : formatter.format(_selectedDate!)),
                    IconButton(
                      onPressed: _datepicker, 
                      icon: Icon(Icons.calendar_month),
                      )
                  ],
                  ),
                )
             ],
           ),
           SizedBox(height: 18,),
          Row(
            children: [
              DropdownButton(
                value: _selectedCategory,
                items: Category.values.map((category) => DropdownMenuItem(
                value: category,
                child: Text(category.name.toUpperCase()))).toList(), 
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _selectedCategory = value;
                  });
                }
                ),
                Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                }, 
                child: Text('Cancel')),
              ElevatedButton(
                onPressed: _submitformValidate,
              child: Text('Save Expense')),
            ],
          )
        ],
      ),
    );
  }
}