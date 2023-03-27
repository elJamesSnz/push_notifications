import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import '../../notifications/notifications_list.dart';
import 'package:push_notifications/src/utils/utils_colors.dart';

class ClientActionsList extends StatefulWidget {
  const ClientActionsList({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ClientActionsListState createState() => _ClientActionsListState();
}

class _ClientActionsListState extends State<ClientActionsList> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  int _notificationsCounter = 0;
  final List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
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
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _addNotification(message);
    });
  }

  void _addNotification(RemoteMessage message) {
    setState(() {
      _notificationsCounter++;
      _notifications.add({
        'data': message.data,
        'timestamp': DateTime.now().toString(),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nana Push Notifications App',
                    style: TextStyle(
                        fontSize: 24, color: UtilsColors.titleAccentColor),
                  ),
                  Stack(
                    children: [
                      IconButton(
                        icon: Icon(Icons.notifications,
                            color: UtilsColors.titleAccentColor),
                        onPressed: () {
                          //to-do
                        },
                      ),
                      if (_notificationsCounter > 0)
                        Positioned(
                          top: 5,
                          right: 5,
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 12,
                              minHeight: 12,
                            ),
                            child: Text(
                              '$_notificationsCounter',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // Acciones
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                children: [
                  _buildActionCard(
                    title: 'Registrar QR Code',
                    icon: Icons.qr_code,
                    onPressed: () {
                      // to-do
                    },
                  ),
                  _buildActionCard(
                    title: 'Registrar Autenticación',
                    icon: Icons.face,
                    onPressed: () {
                      // to-do
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
      {required String title,
      required IconData icon,
      required VoidCallback onPressed}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        onLongPress: () {
          HapticFeedback.lightImpact();
        },
        highlightColor: Colors.grey.withOpacity(0.2),
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
}
