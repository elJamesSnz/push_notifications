import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';

//pages
import 'package:push_notifications/src/auth/authentication_page.dart';
import 'package:push_notifications/src/pages/notifications/notifications_list.dart';
import 'package:push_notifications/src/widgets/screens/widget_main_screen.dart';
//utils
import 'src/utils/utils_sharedpref_notifications.dart';
import 'package:push_notifications/src/utils/utils_colors.dart';
//providers
import 'src/providers/push_notifications_provider.dart';
import 'src/widgets/cards/widget_action_card.dart';
import 'src/widgets/notifications/widget_notification_Icon.dart';
import 'src/widgets/titles/widget_main_title.dart';

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
        WidgetMainTitle(title: 'Notifications App'),
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
            title: 'Autentificación',
            icon: Icons.face,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AuthtenticationPage()),
              );
            },
          )
        ],
      ),
    );
  }
}
