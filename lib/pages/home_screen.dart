import 'package:expensetracker/model/ctrl_provider.dart';
import 'package:expensetracker/model/shared_preference.dart';
import 'package:expensetracker/pages/contact_support.dart';
import 'package:expensetracker/pages/donation_page.dart';
import 'package:expensetracker/pages/tax_refund_page.dart';
// import 'package:expensetracker/pages/transaction_stat.dart';
import 'package:expensetracker/pages/transactions_list.dart';
import 'package:expensetracker/widget/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';



class HomeScreen extends ConsumerStatefulWidget  {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

// ref.read(expenseProvider.notifier).state

class _HomeScreenState extends ConsumerState<HomeScreen> { 

  bool isExpense = true;
  final TextEditingController _amountController = TextEditingController();
  String _selectedCategory = "Salary";
  DateTime _selectedDate = DateTime.now();
  final LocalStorage _localStorage = LocalStorage();
  final _uuid = Uuid();

  final List<String> _incomeCategories = [
    'Salary',
    'Return of Investment',
    'Inheritance',
    'Shares/Profits',
    'Others'
  ];
  

    @override
  void initState() {
    super.initState();
    _checkIncomePopUp();
  }




  void _saveTransaction() {

      Map<String, dynamic> transaction = {
      'id': _uuid.v4(),
      'type': 'reminder', 
      'amount': double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0,
      'category': _selectedCategory,
      'date': _selectedDate.toIso8601String(),
    };
    if(_amountController.text.isEmpty) return;

    // save to shared preference
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Reminder Saved Successfully! ${_selectedDate.day} of every Month',
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 4),
      ),
    );
    _localStorage.saveString("Reminder", "Yes");
    _localStorage.saveReminder("saveReminder", transaction);
    ref.read(setReminderProvider.notifier).state = 'Yes';
    

    // Clear form
    _amountController.clear();
    // setState(() {
    //   _selectedDate = DateTime.now();
    // });

    Navigator.of(context).pop();
  }





    void _checkIncomePopUp() async {
    final prefs = await SharedPreferences.getInstance();
    // final localStorage = LocalStorage();
    final savedIncome = prefs.getString("Reminder");
    print(savedIncome);
    if (savedIncome == "No") {return;}
    if (savedIncome == "Yes") {
        Map<String, dynamic>? getTrans = await _localStorage.getReminder("saveReminder");

        if (getTrans != null && getTrans["type"] != null) {
          return;
        }
    }
    _showIncomeDialog();
  }

  void _showIncomeDialog() {
    showDialog(context: context, builder: (context) => StatefulBuilder(
      builder: (context, setState) {
          void selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2090),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
        return AlertDialog(
        title: Text('Do you have a stable income?'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [ThousandsSeparatorInputFormatter()],
                  onTapOutside: (PointerDownEvent event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    prefixText: '₦ ',
                    prefixStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    hintText: '0',
                    // border: OutlineInputBorder(
                    //   borderRadius: BorderRadius.circular(12),
                    //   borderSide: BorderSide.none,
                    // ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color:Colors.green,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: selectDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('MMM dd, yyyy').format(_selectedDate),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(Icons.calendar_today, color: Colors.blue),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down),
                      items: _incomeCategories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category, style: TextStyle(color: Theme.of(context).colorScheme.onSurface),),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue!;
                        });
                      },
                      dropdownColor: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () {
            Navigator.of(context).pop();
            _localStorage.saveString("Reminder", "No");
            ref.read(setReminderProvider.notifier).state = 'No';
          }, child: Text('No')),
      
          ElevatedButton(onPressed: () {
            _saveTransaction();
          }, child: Text('Save Reminder'))
        ],
      );
      },
    ));
  }


  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> expenses = ref.watch(expenseProvider);
    final List<Map<String, dynamic>> incomes = ref.watch(incomeProvider);

    // Calculate total income
    double totalIncome = incomes.fold(0.0, (sum, item) => sum + (item['amount'] as double? ?? 0.0));
    // Calculate total expense
    double totalExpense = expenses.fold(0.0, (sum, item) => sum + (item['amount'] as double? ?? 0.0));

    // Calculate the net balance
    double currentBalance = totalIncome - totalExpense;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:  [
          BalanceWidget(balance: currentBalance),
          SizedBox(height: 5),
          QuickMenuWidget(),
          SizedBox(height: 8,),
          Expanded(
            child: HistoryWidget(),
          ),
        ],
      ),
    );
  }

    @override
  void dispose() {
    super.dispose();
    _amountController.dispose();
  }
}


class BalanceWidget extends StatelessWidget {
  const BalanceWidget({required this.balance, super.key});
  
  final double? balance;
  
  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'en_NG', symbol: '₦', decimalDigits: 2);
    return Card.filled(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      child: Container(
        
        width: double.infinity,
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text('Balance: ', style: TextStyle(
              // color: Theme.of(context).copyWith().colorScheme.tertiaryContainer,
            ),), 
            SizedBox(width: 10), 
            Text(formatter.format(balance ?? 0.0), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)],
        ),
      ),
    );
  }

  

}

class QuickMenuWidget extends StatelessWidget {
  const QuickMenuWidget({super.key});

  Widget _builtinCards(IconData addIcon, String label, BuildContext context, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
          onTap: onTap,
        child: Container(
              height: 120,
              width: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light ? Colors.white : Theme.of(context).colorScheme.onPrimary,
                boxShadow: [BoxShadow(blurRadius: 4)],
                borderRadius: BorderRadius.circular(13),
              ),
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(addIcon, size: 40, color: Theme.of(context).colorScheme.onPrimaryContainer),
                  
                  Text(
                    label,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                       color: Theme.of(context).brightness == Brightness.light ? Theme.of(context).colorScheme.onPrimaryContainer :  Colors.white ,
                       fontSize: 14,
                    ),
                  )
                ],
              ),
          ),
        ),
      ),
    );
}
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick Links',),
            // SizedBox(height: 20,),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _builtinCards(Icons.receipt_long, "Tax Details", context, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TaxRefundPage()),
                    );
                  }),
                  _builtinCards(Icons.account_balance_wallet, "Transactions", context, () {
                     Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Transactions()),
                    );
                  }),
                  // _builtinCards(Icons.pie_chart_rounded, "All Income or Expense History", context, () {
                  //    Navigator.push(
                  //     context,
                  //     MaterialPageRoute(builder: (context) => const TransactionStatPage()),
                  //   );
                  // }),
                  _builtinCards(Icons.handshake_outlined, "Support Us", context, () {
                   Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DonationPage()),
                    );
                  }),
                  _builtinCards(Icons.support_agent, "Contact Us", context, () async {
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ContactSupport()),
                    );

                  }),
                ],
              ),
            )
          ],
        ),
    );
  }
}

class HistoryWidget extends ConsumerWidget {
  const HistoryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localStorage = LocalStorage();
    final expenses = ref.watch(expenseProvider);
    final incomes = ref.watch(incomeProvider);

    // Combine, sort, and take the last 10 transactions
    final allTransactions = [...incomes, ...expenses];
    allTransactions.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
    final recentTransactions = allTransactions.take(10).toList();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Transactions()),
                  );
                },
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (recentTransactions.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('No transactions yet.'),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: recentTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = recentTransactions[index];
                  final isExpense = transaction['type'] == 'expense';
                  final amount = transaction['amount'] as double;
                  final date = DateTime.parse(transaction['date']);
                  final icon = isExpense ? Icons.arrow_downward : Icons.arrow_upward;
                  final color = isExpense ? Colors.red : Colors.green;

                  return Dismissible(
                    key: ValueKey(transaction['id']),
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
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
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
                },
              ),
            ),
        ],
      ),
    );
}
}