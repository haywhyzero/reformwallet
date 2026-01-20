import 'package:expensetracker/model/ctrl_provider.dart';
import 'package:expensetracker/model/notification_provider.dart';
import 'package:expensetracker/model/shared_preference.dart';
import 'package:expensetracker/model/tax_service.dart';
import 'package:expensetracker/pages/about_us.dart';
import 'package:expensetracker/pages/privacy_policy.dart';
import 'package:expensetracker/pages/reminder_page.dart';
import 'package:expensetracker/pages/terms_of_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
 final localStorage = LocalStorage();
  bool soundEffect = false;
  bool notification = false;
  bool isloading = false;

  void deleteData() async {
    final prefs = await SharedPreferences.getInstance();
    final localStorage = LocalStorage();
              await localStorage.delete("Reminder");
              await localStorage.delete("saveReminder");
              await prefs.remove('notifications');
              await prefs.remove('incomes');
              await prefs.remove('expenses');
              setState(() => isloading = false,);
              ref.read(expenseProvider).clear();
              ref.read(incomeProvider).clear();
              ref.read(notificationProvider).clear();
              ref.read(setReminderProvider.notifier).state = '';
              ref.read(taxDetailsProvider.notifier).state = TaxDetails.empty();
  }

  void showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
            
          return AlertDialog(
          title: Text('Delete Account'),
          content: isloading ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(child: CircularProgressIndicator(color: Colors.red,)),
            ],
          ) 
          : const Text('Are you sure you want to delete all data? This action cannot be undone.'),
          actions: isloading ? [] : [
            TextButton(onPressed: () async {
              setState(() {
                isloading = true;
              });
              await Future.delayed(const Duration(seconds: 3));
              setState(() => deleteData(),);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You have successfully deleted all your data!')));
            }, child: Text('Yes')),
        
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ButtonStyle(),
              child: Text('No'),
            ),
          ],
        );
        },
       
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(darkModeProvider);
    final setReminder = ref.watch(setReminderProvider);
    final isNotification = ref.watch(isNotificationProvider);
    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(height: 8),
          // Themes
          _buildSwitchTile(
            icon: isDarkMode ? Icons.dark_mode : Icons.light_mode,
            title: 'Light/Dark Mode',
            value: isDarkMode,
            onChanged: (bool val)  {
              ref.read(darkModeProvider.notifier).state = val;
            },
          ),
          // Notification
          _buildSwitchTile(
            icon: isNotification ? Icons.notifications_on_outlined : Icons.notifications_off_outlined,
            title: 'Notifications',
            value: isNotification,
            onChanged: (bool val) {
              ref.read(isNotificationProvider.notifier).state = val;
            },
          ),
          const SizedBox(height: 8),
          // Income Reminder
         _buildNavigationTile(
          icon: Icons.remember_me,
          title: "Set Reminder",
          trailing: "$setReminder ➤",
          onTap: () {
          Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReminderPage()),
              );
          }
         ),
          const SizedBox(height: 8),
          // About app
          _buildNavigationTile(
            icon: Icons.info_outline_rounded,
            title: 'About Us',
            iconColor: Colors.black,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutUs()),
              );
            },
          ),
          const SizedBox(height: 8),
          // Delete Account
          _deleteData(),
          const SizedBox(height: 32),
          // Version and Links
          Center(
            child: Column(
              children: [
                const Text(
                  'Version 1.0.0',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
                        );
                      },
                      child: const Text(
                        'Privacy Policy',
                        style: TextStyle(color: Colors.blue, fontSize: 12),
                      ),
                    ),
                    const Text(
                      '  |  ',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TermsOfServicePage()),
                        );
                      },
                      child: const Text(
                        'Terms of Service',
                        style: TextStyle(color: Colors.blue, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    String? trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              )
            : null,
        trailing: trailing != null ? Text("$trailing ", style: const TextStyle(
          fontSize: 16, color: Colors.grey
        ),)
         : const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon,),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            )
          : null,
      value: value,
      onChanged: onChanged,
      activeColor: Colors.blue[700],
    );
  }

  Widget _deleteData() {
    return Container(
      child: ListTile(
        leading: Icon(Icons.delete, color: Colors.red, size: 24),
        title: Text(
          "Delete data",
          style: const TextStyle(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          "delete all saved data (income/expense/tax data) ",
          style: const TextStyle(fontSize: 12, color: Color.fromARGB(255, 134, 133, 133)),
        ),
        onTap: () {
          showDeleteDialog();
        },
      ),
    );
  }
}
