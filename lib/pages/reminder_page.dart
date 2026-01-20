import 'package:expensetracker/model/ctrl_provider.dart';
import 'package:expensetracker/model/shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReminderPage extends ConsumerStatefulWidget {
  const ReminderPage({super.key});

  @override
  ConsumerState<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends ConsumerState<ReminderPage> {
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
    _loadSavedReminder();
  }

  Future<void> _loadSavedReminder() async {
    final prefs = await SharedPreferences.getInstance();
    final savedReminder = prefs.getString("Reminder");
    if (savedReminder == 'Yes') {
      ref.read(setReminderProvider.notifier).state = 'Yes';
    }
  }

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


   void _saveTransaction() async {

    // final prefs = await SharedPreferences.getInstance();
    // final localStorage = LocalStorage();
    // final savedIncome = prefs.getString("Reminder");

      Map<String, dynamic> transaction = {
      'id': _uuid.v4(),
      'type': 'reminder', 
      'amount': double.tryParse(_amountController.text) ?? 0.0,
      'category': _selectedCategory,
      'date': _selectedDate.toIso8601String(),
    };
    if(_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Fill all fields!',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 1),
      ),
    );
    }

    else 
    {// save to shared preference
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Reminder Saved Successfully! ${_selectedDate.day} of every Month',
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 4),
      ),
    );
    
    ref.read(setReminderProvider.notifier).state = 'Yes';
    _localStorage.saveString("Reminder", "Yes");
    _localStorage.saveReminder("saveReminder", transaction);
    

    // Clear form
    _amountController.clear();
    // setState(() {
    //   _selectedDate = DateTime.now();
    // });}

  }
   }

  
  



  @override
  Widget build(BuildContext context) {

    final setReminder = ref.watch(setReminderProvider);
    bool value = setReminder == 'Yes';
    bool showForm = value;
    
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              CheckboxMenuButton(value: !value, onChanged:  (bool? rem) {
                setState(() {
                  value = rem as bool;
                  
                });
                _deleteReminder();
                ref.read(setReminderProvider.notifier).state = 'No';
                _localStorage.saveString("Reminder", "No");
              },
        
              child: Text('No (This will erase existing reminder)')),
              CheckboxMenuButton(value: value, onChanged:  (bool? rem) {
                ref.read(setReminderProvider.notifier).state = 'Yes';
              }, child: Text('Yes')),
        
              SizedBox(height: 30,),
        
              if (showForm)
                  _showForm()
              else 
                  Text('Oops! Your reminder is off!')
            ],
          ),
        ),
      ),
    );
  }

  // Widget _showReminders() {
  //   return ListView.builder(
  //     shrinkWrap: true,

  //     itemBuilder: (context, index) {

  //   });
  // }


  Widget _deleteReminder() {
    return AlertDialog(
      title: Text('Delete Reminder'),
      content: Text('Are you sure you want to delete this reminder?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final localStorage = LocalStorage();
              await localStorage.delete("Reminder");
              await localStorage.delete("saveReminder");
              ref.read(setReminderProvider.notifier).state = '';
            Navigator.of(context).pop();
          },
          child: Text('Delete'),
        ),
      ],
    );
  }

  Widget _showForm() {
    return SizedBox(
            width: 280,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    onTapOutside: (PointerDownEvent event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
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
                  SizedBox(height: 14,),
                  ElevatedButton(onPressed: () {
              _saveTransaction();
            }, child: Text('Save Reminder'))
              ],
            ),
        );
  }
}