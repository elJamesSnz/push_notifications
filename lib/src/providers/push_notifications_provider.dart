import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/src/widgets/framework.dart';
import '../utils/utils_sharedpref_notifications.dart';
import '../widgets/notifications/widget_flushbar_notification.dart';

class PushNotificationsProvider {
  final BuildContext context;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  // ignore: prefer_final_fields
  UtilsSharedPrefNotifications _sharedPreferencesNotifications =
      UtilsSharedPrefNotifications();

  Stream<List<Map<String, dynamic>>> get notificationsStream =>
      _sharedPreferencesNotifications.notificationsStream;
  PushNotificationsProvider(this.context);

  void initialize() {
    _sharedPreferencesNotifications.initializeNotifications();
    _configureFirebaseListeners();
  }

  void _configureFirebaseListeners() {
    _firebaseMessaging.requestPermission().then((_) {
      _firebaseMessaging.getToken().then((String? token) {
        print("Device Token: $token");
      });
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _sharedPreferencesNotifications.addNotification(message);
      String notificationTitle =
          message.notification?.title ?? 'Título de notificación';
      String notificationMessage =
          message.notification?.body ?? 'Cuerpo de la notificación';
      WidgetFlushbarNotification customFlushbar = WidgetFlushbarNotification(
          title: notificationTitle, message: notificationMessage);

      customFlushbar.flushbar(context).show(context);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _sharedPreferencesNotifications.addNotification(message);
    });
  }
}
