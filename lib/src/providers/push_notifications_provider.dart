import 'dart:async';

import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/src/widgets/framework.dart';
import '../utils/utils_notifications.dart';
import '../widgets/notifications/widget_flushbar_notification.dart';

class PushNotificationsProvider {
  final BuildContext context;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  // ignore: prefer_final_fields
  UtilsNotifications _sharedPreferencesNotifications = UtilsNotifications();

  Stream<List<Map<String, dynamic>>> get notificationsStream =>
      _sharedPreferencesNotifications.notificationsStream;
  PushNotificationsProvider(this.context);

  void initialize() {
    _sharedPreferencesNotifications.fetchStoredNotifications();
    _configureFirebaseListeners();
  }

  void _configureFirebaseListeners() {
    _firebaseMessaging.requestPermission().then((_) {
      _firebaseMessaging.getToken().then((String? token) {
        print("Device Token: $token");
      });
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _sharedPreferencesNotifications.fetchStoredNotifications();

      WidgetFlushbarNotification customFlushbar = WidgetFlushbarNotification(
          title: 'Notificación',
          message: 'Notificación recibida',
          flushbarPosition: FlushbarPosition.BOTTOM);

      customFlushbar.flushbar(context).show(context);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _sharedPreferencesNotifications.fetchStoredNotifications();

      WidgetFlushbarNotification customFlushbar = WidgetFlushbarNotification(
          title: 'Notificación',
          message: 'Notificación recibida',
          flushbarPosition: FlushbarPosition.BOTTOM);

      customFlushbar.flushbar(context).show(context);
    });
  }
}
