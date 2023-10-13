import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:push_notifications/src/pages/client/actions/client_actions_qrcode.dart';
import 'package:push_notifications/src/providers/push_notifications_provider.dart';
import 'package:push_notifications/src/utils/utils_notifications.dart';
import 'package:push_notifications/src/utils/utils_sharedpref_wallet.dart';
import 'package:push_notifications/src/widgets/cards/widget_action_card.dart';
import 'package:push_notifications/src/widgets/notifications/widget_notification_Icon.dart';
import 'package:push_notifications/src/widgets/screens/widget_main_screen.dart';
import 'package:push_notifications/src/widgets/titles/widget_main_title.dart';

import '../../../widgets/notifications/widget_flushbar_notification.dart';
import '../../notifications/notifications_list.dart';

class ClientActionsList extends StatefulWidget {
  static const routeName = 'client/list';

  const ClientActionsList({super.key});

  @override
  _ClientActionsListState createState() => _ClientActionsListState();
}

class _ClientActionsListState extends State<ClientActionsList> {
  final UtilsNotifications _sharedPreferencesNotifications =
      UtilsNotifications();
  int notificationCount = 0;

  late PushNotificationsProvider pushNotificationsProvider;
  late String? wallet = '';
  List<Map<String, dynamic>> notificationsList = [];

  @override
  void initState() {
    super.initState();

    pushNotificationsProvider = PushNotificationsProvider(context);
    pushNotificationsProvider.initialize();

    UtilsSharedPrefWallet().getWallet().then((value) {
      setState(() {
        wallet = value;
        if (wallet != null) {
          // Only fetch notifications if wallet is not null
          _sharedPreferencesNotifications.fetchStoredNotifications();
        }
      });
    });

    _sharedPreferencesNotifications.notificationsStream
        .listen((storedNotifications) {
      setState(() {
        notificationCount = storedNotifications.length;
        notificationsList = storedNotifications;
      });
    });
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
        const WidgetMainTitle(title: 'Push Notifications App'),
        WidgetNotificationIcon(
            icon: Icons.notifications,
            pushNotificationsProvider: pushNotificationsProvider,
            notificationCount: notificationCount,
            notifications: notificationsList),
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
            title: 'Leer QR Code',
            icon: Icons.qr_code,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ClientActionsQRCode(),
                ),
              );
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
          ),
          if (wallet != null && wallet != "")
            WidgetActionCard(
              title: 'Wallet',
              icon: Icons.account_balance_wallet,
              onPressed: () {
                WidgetFlushbarNotification(
                  title: 'Wallet del dispositivo',
                  message: wallet!,
                  duration: 4,
                ).flushbar(context).show(context);
              },
            ),
          WidgetActionCard(
            title: 'Salir',
            icon: Icons.exit_to_app_outlined,
            onPressed: () {
              SystemNavigator.pop();
            },
          ),
        ],
      ),
    );
  }
}
