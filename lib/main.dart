import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:push_notifications/src/pages/notifications/notifications_list.dart';
import 'package:push_notifications/src/utils/utils_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: UtilsColors.titleBgColor,
        appBarTheme: AppBarTheme.of(context).copyWith(
          backgroundColor: UtilsColors.titleBgColor,
        ),
        colorScheme: ColorScheme.fromSwatch()
            .copyWith(secondary: UtilsColors.titleAccentColor),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final _msgStreamController = StreamController<String>.broadcast();
  Stream<String> get mensajes => _msgStreamController.stream;

  int _notificationsCounter = 0;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _configureFirebaseListeners();
  }

  void _configureFirebaseListeners() {
    _firebaseMessaging.requestPermission().then((_) {
      _firebaseMessaging.getToken().then((String? token) {
        print("Device Token: $token");
      });
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _addNotification(message);

      String arg = 'no-data';
      if (Platform.isAndroid) {
        arg = message.data['comida'] ?? 'no-data';
      }

      _msgStreamController.sink.add(arg);

      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        messageText: Row(
          children: [
            Icon(
              Icons.notifications,
              color: UtilsColors.titleAccentColor,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.notification?.title ?? 'Título de notificación',
                    style: TextStyle(
                      color: UtilsColors.titleAccentColor,
                    ),
                  ),
                  Text(
                    message.notification?.body ?? 'Cuerpo de la notificación',
                    style: TextStyle(
                      color: UtilsColors.titleAccentColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white.withOpacity(0.9),
        margin: EdgeInsets.fromLTRB(16, 50, 16, 0),
        borderRadius: BorderRadius.circular(8),
        duration: Duration(seconds: 4),
        onTap: (_) {
          Navigator.pushNamed(context, 'notifications/list');
        },
      ).show(context);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _addNotification(message);
    });
  }

  Future<void> _initializeNotifications() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('notifications')) {
      await prefs.setStringList('notifications', []);
    }
  }

  Future<void> _addNotification(RemoteMessage message) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String timestamp = DateTime.now().toIso8601String();
    final notificationData = {
      "timestamp": timestamp,
      "data": message.data,
    };

    List<String> notificationsJson = prefs.getStringList('notifications') ?? [];
    notificationsJson.add(jsonEncode(notificationData));
    await prefs.setStringList('notifications', notificationsJson);

    setState(() {
      _notifications.add(notificationData);
    });
  }

  Future<List<Map<String, dynamic>>> _getStoredNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> stringList = prefs.getStringList('notifications') ?? [];
    List<Map<String, dynamic>> notifications = stringList
        .map((item) => json.decode(item) as Map<String, dynamic>)
        .toList();
    return notifications;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: UtilsColors.titleBgColor,
          statusBarIconBrightness: Brightness.light,
        ),
        child: SafeArea(
          child: Container(
            decoration: UtilsColors.gradientDecoration,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Notifications App',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Stack(
                        children: [
                          IconButton(
                            icon: Icon(Icons.notifications),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NotificationList(),
                                ),
                              );
                            },
                          ),
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: _getStoredNotifications(),
                            builder: (BuildContext context,
                                AsyncSnapshot<List<Map<String, dynamic>>>
                                    snapshot) {
                              int notificationCount = 0;
                              if (snapshot.hasData) {
                                notificationCount = snapshot.data!.length;
                              }

                              return Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 14,
                                    minHeight: 14,
                                  ),
                                  child: Text(
                                    '$notificationCount',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildActionCard(
                          title: 'Registrar QR Code',
                          icon: Icons.qr_code,
                          onPressed: () {
                            //to-do
                          },
                        ),
                        _buildActionCard(
                          title: 'Autentificación',
                          icon: Icons.face,
                          onPressed: () {
                            //to-do
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
      {required String title,
      required IconData icon,
      required VoidCallback onPressed}) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          HapticFeedback.selectionClick();
          onPressed();
        },
        onLongPress: () {
          HapticFeedback.mediumImpact();
        },
        highlightColor: Colors.grey.withOpacity(0.8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: UtilsColors.titleAccentColor,
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48),
              SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  dispose() {
    _msgStreamController.close();
  }
}
