
// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'tax_service.dart';



// final controllerProvider = Provider<Controller>((ref) => Controller());
final expenseProvider = StateProvider<List<Map<String, dynamic>>>((ref) => []);
final incomeProvider = StateProvider<List<Map<String, dynamic>>>((ref) => []);
final taxDetailsProvider = StateProvider<TaxDetails?>((ref) => TaxDetails.empty());
final darkModeProvider = StateProvider<bool>((ref) => false);
final isNotificationProvider = StateProvider<bool>((ref) => false);
final setReminderProvider = StateProvider<String>((ref) => '');
