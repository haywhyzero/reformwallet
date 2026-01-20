import 'package:expensetracker/model/ctrl_provider.dart';
import 'package:expensetracker/model/shared_preference.dart';
import 'package:expensetracker/model/tax_service.dart';
import 'package:expensetracker/widget/toggle.dart';
import 'package:expensetracker/widget/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AddTransactionPage extends ConsumerStatefulWidget {
  const AddTransactionPage({super.key});

  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  bool isExpense = true;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();
  final LocalStorage _localStorage = LocalStorage();
  final Uuid _uuid = const Uuid();

  final List<String> _expenseCategories = [
    'Food',
    'Transport',
    'Shopping',
    'Entertainment',
    'Bills',
    'Healthcare',
    'Education',
    'Other'
  ];

  final List<String> _incomeCategories = [
    'Salary',
    'Business',
    'Investment',
    'Freelance',
    'Gift',
    'Other'
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTransaction() {


    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }

    
      Map<String, dynamic> transaction = {
      'id': _uuid.v4(),
      'type': isExpense ? 'expense' : 'income', 
      'amount': double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0,
      'category': _selectedCategory,
      'description': _descriptionController.text,
      'date': _selectedDate.toIso8601String(),
    };

    // save to shared preference
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${isExpense ? "Expense" : "Income"} of ₦${_amountController.text} saved successfully!',
        ),
        backgroundColor: isExpense ? Colors.red : Colors.green,
      ),
    );

    if (isExpense) {
      final newExpenses = [...ref.read(expenseProvider), transaction];
      ref.read(expenseProvider.notifier).state = newExpenses;
      _localStorage.saveTransactions('expenses', newExpenses);

    } else {
      final currentIncomes = ref.read(incomeProvider);
      final newIncomes = [...currentIncomes, transaction];
      ref.read(incomeProvider.notifier).state = newIncomes;
      _localStorage.saveTransactions('incomes', newIncomes);

      // Automatically calculate tax
      _calculateAndStoreTax(ref, newIncomes);
    }

    // Clear form
    _amountController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedCategory = isExpense ? 'Food' : 'Salary';
      _selectedDate = DateTime.now();
    });
  }

  void _calculateAndStoreTax(WidgetRef ref, List<Map<String, dynamic>> allIncomes) {
    final taxService = ref.read(taxServiceProvider);
    final currentYear = DateTime.now().year;

    // Sum up all income for the current year
    final totalAnnualIncome = allIncomes
        .where((t) => DateTime.parse(t['date']).year == currentYear && t['category'] != 'Gift')
        .fold<double>(0.0, (sum, item) => sum + (item['amount'] as double));

    final taxDetails = taxService.calculateTax(annualGrossIncome: totalAnnualIncome);
    ref.read(taxDetailsProvider.notifier).state = taxDetails;
  }

  @override
  Widget build(BuildContext context) {
    // No need to watch here if we're only updating state in _saveTransaction
    // ref.watch(expenseProvider);
    // ref.watch(incomeProvider);


    final categories = isExpense ? _expenseCategories : _incomeCategories;

    return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomToggle(
              isExpense: isExpense,
              onToggle: (value) {
                setState(() {
                  isExpense = value;
                  _selectedCategory = value ? 'Food' : 'Salary';
                });
              },
            ),
            const SizedBox(height: 30),
            const Text(
              'Amount',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
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
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                hintText: '0',
                
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isExpense ? Colors.red : Colors.green,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Category',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
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
                  items: categories.map((String category) {
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
            const SizedBox(height: 20),
            const Text(
              'Description (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              onTapOutside: (PointerDownEvent event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              decoration: InputDecoration(
                hintText: 'Add a note...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isExpense ? Colors.red : Colors.green,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Date',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectDate,
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
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isExpense ? Colors.red : Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Save ${isExpense ? "Expense" : "Income"}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }
}