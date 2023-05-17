// ignore_for_file: use_build_context_synchronously

import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:push_notifications/src/auth/auth_actions_qrcode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

import '../widgets/cards/widget_action_card.dart';
import '../widgets/notifications/widget_flushbar_notification.dart';
import '../widgets/screens/widget_main_screen.dart';
import '../widgets/titles/widget_main_title.dart';

import '../pages/client/actions/client_actions_list.dart';

class CreateAccountPage extends StatefulWidget {
  static const routeName = 'create/page';

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late WidgetFlushbarNotification customFlushbar;

  @override
  Widget build(BuildContext context) {
    return WidgetMainScreen(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                WidgetMainTitle(title: 'Asociar dispositivo'),
                SizedBox(width: 24),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: MediaQuery.of(context).size.height * 0.1,
                ),
                child: Center(
                  child: GridView.count(
                    crossAxisCount: 1,
                    childAspectRatio: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      WidgetActionCard(
                        title: 'Registrar dispositivo',
                        icon: Icons.phone_android,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AuthActionsQRCode(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
