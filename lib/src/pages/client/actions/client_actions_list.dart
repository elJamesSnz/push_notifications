import 'package:flutter/material.dart';
import 'package:push_notifications/src/auth/authentication_page.dart';
import 'package:push_notifications/src/providers/push_notifications_provider.dart';
import 'package:push_notifications/src/utils/utils_sharedpref_notifications.dart';
import 'package:push_notifications/src/widgets/cards/widget_action_card.dart';
import 'package:push_notifications/src/widgets/notifications/widget_notification_Icon.dart';
import 'package:push_notifications/src/widgets/screens/widget_main_screen.dart';
import 'package:push_notifications/src/widgets/titles/widget_main_title.dart';

import '../../notifications/notifications_list.dart';

class ClientActionsList extends StatefulWidget {
  static const routeName = 'client/list';

  @override
  _ClientActionsListState createState() => _ClientActionsListState();
}

class _ClientActionsListState extends State<ClientActionsList> {
  final UtilsSharedPrefNotifications _sharedPreferencesNotifications =
      UtilsSharedPrefNotifications();
  int notificationCount = 0;

  late PushNotificationsProvider pushNotificationsProvider;

  @override
  void initState() {
    super.initState();

    pushNotificationsProvider = PushNotificationsProvider(context);
    pushNotificationsProvider.initialize();

    _sharedPreferencesNotifications.notificationsStream
        .listen((storedNotifications) {
      setState(() {
        notificationCount = storedNotifications.length;
      });
    });

    _sharedPreferencesNotifications.fetchStoredNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return WidgetMainScreen(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildMainBar(),
            const SizedBox(height: 32),
            _buildActionCardsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const WidgetMainTitle(title: 'Notifications App'),
        WidgetNotificationIcon(
          icon: Icons.notifications,
          pushNotificationsProvider: pushNotificationsProvider,
          notificationCount: notificationCount,
        ),
      ],
    );
  }

  Widget _buildActionCardsGrid() {
    return Expanded(
        child: GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        WidgetActionCard(
          title: 'Registrar QR Code',
          icon: Icons.qr_code,
          onPressed: () {
            //to-do
          },
        ),
        WidgetActionCard(
          title: 'Notificaciones',
          icon: Icons.notifications_active,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationList(),
              ),
            );
          },
        )
      ],
    ));
  }
}
