import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  Future<void> saveString(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  
  }

  getString(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> saveBool(String key, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<bool> getBool(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }


  Future<void> delete(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // Saves and Retrieves income reminder

  Future<void> saveReminder(String key, Map<String, dynamic> income) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(income);
    await prefs.setString(key, encodedData);
  }

  Future<Map<String, dynamic>?> getReminder(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(key);
    if (encodedData == null) {
      return null;
    }
    final decodedData = jsonDecode(encodedData);
    if(decodedData is Map<String, dynamic>) {
      return decodedData;
    }

    return null;
  }

  // Saves a list of transactions (like incomes or expenses) as a JSON string
  Future<void> saveTransactions(String key, List<Map<String, dynamic>> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(transactions);
    await prefs.setString(key, encodedData);
  }

  // Retrieves and decodes a list of transactions
  Future<List<Map<String, dynamic>>> getTransactions(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(key);
    if (encodedData != null) {
      final List<dynamic> decodedData = jsonDecode(encodedData);
      return decodedData.cast<Map<String, dynamic>>().toList();
    }
    return []; 
  }
}
