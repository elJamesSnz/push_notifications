import 'package:flutter/material.dart';
import '../../pages/notifications/notifications_list.dart';
import '../../providers/push_notifications_provider.dart';

class WidgetNotificationIcon extends StatelessWidget {
  final IconData icon;
  final PushNotificationsProvider pushNotificationsProvider;
  final int notificationCount;

  WidgetNotificationIcon({
    required this.icon,
    required this.pushNotificationsProvider,
    required this.notificationCount,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: pushNotificationsProvider.notificationsStream,
      builder: (BuildContext context,
          AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        print('Actualizando contador de notificaciones: ${snapshot.data}');

        int currentCount = notificationCount;
        if (snapshot.hasData) {
          currentCount = snapshot.data!.length;
        }

        return Stack(
          children: [
            IconButton(
              icon: Icon(icon),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationList(),
                  ),
                );
              },
            ),
            Positioned(
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
                  '$currentCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
