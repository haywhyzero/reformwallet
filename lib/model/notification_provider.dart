import 'dart:convert';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime date;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'date': date.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'],
      title: map['title'],
      body: map['body'],
      date: DateTime.parse(map['date']),
      isRead: map['isRead'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory AppNotification.fromJson(String source) =>
      AppNotification.fromMap(json.decode(source));
}

class NotificationNotifier extends StateNotifier<List<AppNotification>> {
  NotificationNotifier() : super([]) {
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? list = prefs.getStringList('notifications');
    if (list != null) {
      state = list.map((e) => AppNotification.fromJson(e)).toList();
    }
  }

  Future<void> addNotification(AppNotification notification) async {
    // Prevent duplicates
    if (state.any((n) => n.id == notification.id)) return;
    
    state = [notification, ...state];
    _saveNotifications();
  }

  Future<void> removeNotification(String id) async {
    state = state.where((n) => n.id != id).toList();
    _saveNotifications();
  }

  Future<void> markAsRead(String id) async {
    state = [
      for (final n in state)
        if (n.id == id)
          AppNotification(
            id: n.id,
            title: n.title,
            body: n.body,
            date: n.date,
            isRead: true,
          )
        else
          n
    ];
    _saveNotifications();
  }

  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final list = state.map((e) => e.toJson()).toList();
    await prefs.setStringList('notifications', list);
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, List<AppNotification>>((ref) {
  return NotificationNotifier();
});