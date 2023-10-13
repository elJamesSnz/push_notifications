import 'package:flutter/material.dart';
import '../../pages/notifications/notifications_list.dart';
import '../../providers/push_notifications_provider.dart';

class WidgetNotificationIcon extends StatelessWidget {
  final IconData icon;
  final PushNotificationsProvider pushNotificationsProvider;
  final int notificationCount;
  final List<Map<String, dynamic>> notifications;

  const WidgetNotificationIcon(
      {super.key, required this.icon,
      required this.pushNotificationsProvider,
      required this.notificationCount,
      required this.notifications});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: pushNotificationsProvider.notificationsStream,
      builder: (BuildContext context,
          AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
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
                    builder: (context) => const NotificationList(),
                  ),
                );
              },
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                constraints: const BoxConstraints(
                  minWidth: 14,
                  minHeight: 14,
                ),
                child: Text(
                  '$currentCount',
                  style: const TextStyle(
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
