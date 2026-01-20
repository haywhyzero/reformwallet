import 'package:expensetracker/model/ctrl_provider.dart';
import 'package:expensetracker/model/shared_preference.dart';
import 'package:expensetracker/model/tax_service.dart';
import 'package:expensetracker/model/notification_provider.dart';
import 'package:expensetracker/pages/add_expense_income.dart';
import 'package:expensetracker/pages/home_screen.dart';
import 'package:expensetracker/pages/settings_screen.dart';
import 'package:expensetracker/pages/tax_calculator.dart';
import 'package:expensetracker/pages/transaction_stat.dart';
import 'package:expensetracker/pages/splash_screen.dart';
import 'package:expensetracker/widget/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// import 'package:google_fonts/google_fonts.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Device orientation lock
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Error loading .env file: $e");
  }



  // Load data from shared preferences
  final localStorage = LocalStorage();
  List<Map<String, dynamic>> incomes = [];
  List<Map<String, dynamic>> expenses = [];
  bool isDarkMode = false;
  bool isNotification = false;
  String reminder = "No";

  try {
    incomes = await localStorage.getTransactions('incomes');
    expenses = await localStorage.getTransactions('expenses');
    isDarkMode = await localStorage.getBool('isDarkMode');
    isNotification = await localStorage.getBool('isNotification');
    reminder = await localStorage.getString('Reminder') ?? "No";
  } catch (e) {
    debugPrint("Error loading local storage: $e");
  }

  // Initial tax calculation on app start
  final taxService = TaxService();
  TaxDetails initialTaxDetails;
  try {
    final currentYear = DateTime.now().year;
    final totalAnnualIncome = incomes.fold<double>(0.0, (sum, item) {
      try {
        final dateStr = item['date'];
        final amount = item['amount'];
        if (dateStr == null || amount == null) return sum;

        final date = DateTime.parse(dateStr.toString());
        if (date.year == currentYear && item['category'] != 'Gift') {
          return sum + (amount is num ? amount.toDouble() : 0.0);
        }
        return sum;
      } catch (e) {
        return sum; // Skip malformed transactions
      }
    });
    initialTaxDetails = taxService.calculateTax(annualGrossIncome: totalAnnualIncome);
  } catch (e) {
    debugPrint("Error calculating tax on startup: $e");
    initialTaxDetails = TaxDetails.empty();
  }


  // Firebase and OneSignal initialization
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 3));
  } catch (e) {
    debugPrint("Firebase init failed: $e");
  }

  if (dotenv.env['ONESIGNAL'] != null) {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize(dotenv.env['ONESIGNAL']!);
    OneSignal.Notifications.requestPermission(true);
  }

  // Initialize Local Notifications
  await NotificationService.init();

  // Schedule initial reminder if active
  if (isNotification && reminder != "No") {
    await NotificationService.scheduleMonthly(reminder);
  }

  runApp(
    // Override provider with shared preference data
    ProviderScope(
      overrides: [
        incomeProvider.overrideWith((ref) => incomes),
        expenseProvider.overrideWith((ref) => expenses),
        taxDetailsProvider.overrideWith((ref) => initialTaxDetails),
        darkModeProvider.overrideWith((ref) => isDarkMode),
        isNotificationProvider.overrideWith((ref) => isNotification),
        setReminderProvider.overrideWith((ref) => reminder),
      ],
      child: const MyApp(),
    ),
  );
}



class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(darkModeProvider);

    // Using ref.listen to save the dark mode state only when it changes.
    ref.listen(darkModeProvider, (_, next) {
      LocalStorage().saveBool('isDarkMode', next);
    });
    ref.listen(isNotificationProvider, (_, next) {
      LocalStorage().saveBool('isNotification', next);
      final reminder = ref.read(setReminderProvider);
      if (next) {
        NotificationService.scheduleMonthly(reminder);
      } else {
        NotificationService.cancelAll();
      }
    });
    ref.listen(setReminderProvider, (_, next) {
      LocalStorage().saveString('Reminder', next);
      final isNotif = ref.read(isNotificationProvider);
      if (isNotif) {
        NotificationService.scheduleMonthly(next);
      }
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reform Wallet',
      theme: lightMode(),
      darkTheme: darkMode(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _notifications.initialize(settings);
  }

  static Future<void> scheduleMonthly(String dayStr) async {
    if (dayStr == "No") {
      await cancelAll();
      return;
    }

    final int? day = int.tryParse(dayStr);
    if (day == null) return;

    await cancelAll();

    await _notifications.zonedSchedule(
      0,
      'Monthly Reminder',
      'Don\'t forget to add your transactions for this month!',
      _nextInstanceOfDay(day),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'monthly_reminder_channel',
          'Monthly Reminders',
          channelDescription: 'Channel for monthly expense reminders',
          importance: Importance.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
    );
  }

  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  static tz.TZDateTime _nextInstanceOfDay(int day) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    // Schedule for 10:00 AM
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, day, 10);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = tz.TZDateTime(tz.local, now.year, now.month + 1, day, 10);
    }
    return scheduledDate;
  }
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initOneSignalListeners();
  }

  void _initOneSignalListeners() {
    // Handle foreground notifications
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      event.notification.display();
      
      final notif = AppNotification(
        id: event.notification.notificationId ?? const Uuid().v4(),
        title: event.notification.title ?? 'Notification',
        body: event.notification.body ?? '',
        date: DateTime.now(),
      );
      
      ref.read(notificationProvider.notifier).addNotification(notif);
    });

    // Handle notification clicks
    OneSignal.Notifications.addClickListener((event) {
      // You can navigate to specific page here if needed
      final notification = event.notification;
      final customData = notification.additionalData;

      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => Placeholder())
      );
    });
  }

  Widget _buildPages(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const TaxCalculatorPage();
      case 2:
        return const AddTransactionPage();
      case 3:
        return const TransactionStatPage();
      case 4:
        return const SettingsScreen();
      default:
        return const HomeScreen();
    }
  }

  void _ontapPage(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NotificationListSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationProvider);
    final unreadCount = notifications.where((n) => !n.isRead).length;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Reform Wallet'),
        actions: [
          GestureDetector(
            onTap: () {
              _showNotifications();
            },
            
            child: Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.notifications),
                  onPressed: _showNotifications,
                  
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 7,
                    top: 7,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints(minHeight: 8, minWidth: 14),
                      child: Text(
                        '$unreadCount',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 5),
        ],
      ),

      body: SafeArea(child: _buildPages(_currentIndex)),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 1),
        child: FloatingActionButton(
          onPressed: () {
            // Pop modal
            setState(() {
              _currentIndex = 2;
            });
          },
          elevation: 2,
          shape: CircleBorder(),
          child: Icon(Icons.add, size: 30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Stack(
        children: [
          BottomAppBar(
            shape: CircularNotchedRectangle(),
            height: 20,
            notchMargin: 8,
            color: Colors.white,
            elevation: 2,
          ),

          SafeArea(
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _currentIndex,
              onTap: _ontapPage,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calculate_outlined),
                  label: "Tax",
                ),
                BottomNavigationBarItem(icon: Icon(Icons.add), label: ""),
                BottomNavigationBarItem(
                  icon: Icon(Icons.stacked_bar_chart_outlined),
                  label: "Stats",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: "settings",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationListSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Notifications",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (notifications.isNotEmpty)
                  TextButton(
                    onPressed: () async {
                      // Optional: Add clear all functionality
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('notifications');
                      for (var n in notifications) {
                        ref.read(notificationProvider.notifier).removeNotification(n.id);
                      }
                    },
                    child: const Text("Clear All"),
                  )
              ],
            ),
          ),
          Expanded(
            child: notifications.isEmpty
                ? const Center(child: Text("No notifications"))
                : ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notif = notifications[index];
                      return Dismissible(
                        key: Key(notif.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          ref.read(notificationProvider.notifier).removeNotification(notif.id);
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Card(
                          elevation: 2,
                          color: notif.isRead ? null : Theme.of(context).primaryColor.withOpacity(0.05),
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: ListTile(
                            title: Text(
                              notif.title,
                              style: TextStyle(
                                fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              notif.body,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(
                              DateFormat('MMM d, h:mm a').format(notif.date),
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            onTap: () {
                              ref.read(notificationProvider.notifier).markAsRead(notif.id);
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text(notif.title),
                                  content: Text(notif.body),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Close"),
                                    )
                                  ],
                                ),
                              );
                            },
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
