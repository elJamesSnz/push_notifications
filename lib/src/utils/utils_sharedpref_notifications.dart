import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UtilsSharedPrefNotifications {
  final _notificationsStreamController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  Stream<List<Map<String, dynamic>>> get notificationsStream =>
      _notificationsStreamController.stream;

  Future<void> initializeNotifications() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('notifications')) {
      await prefs.setStringList('notifications', []);
    }
  }

  Future<void> addNotification(RemoteMessage message) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String timestamp = DateTime.now().toIso8601String();
    final notificationData = {
      "timestamp": timestamp,
      "data": message.data,
    };

    List<String> notificationsJson = prefs.getStringList('notifications') ?? [];

    List<Map<String, dynamic>> decodedNotifications = notificationsJson
        .map((item) => json.decode(item) as Map<String, dynamic>)
        .toList();

    decodedNotifications.add(notificationData);

    notificationsJson.add(jsonEncode(notificationData));
    await prefs.setStringList('notifications', notificationsJson);

    _notificationsStreamController.sink.add(decodedNotifications);
  }

  Future<List<Map<String, dynamic>>> getStoredNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> stringList = prefs.getStringList('notifications') ?? [];
    List<Map<String, dynamic>> notifications = stringList
        .map((item) => json.decode(item) as Map<String, dynamic>)
        .toList();
    return notifications;
  }

  void fetchStoredNotifications() async {
    List<Map<String, dynamic>> storedNotifications =
        await getStoredNotifications();
    _notificationsStreamController.sink.add(storedNotifications);
  }

  dispose() {
    _notificationsStreamController.close();
  }
}
