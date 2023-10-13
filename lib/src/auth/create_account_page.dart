// ignore_for_file: use_build_context_synchronously

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:push_notifications/src/auth/auth_actions_qrcode.dart';

import '../widgets/cards/widget_action_card.dart';
import '../widgets/notifications/widget_flushbar_notification.dart';
import '../widgets/screens/widget_main_screen.dart';
import '../widgets/titles/widget_main_title.dart';


class CreateAccountPage extends StatefulWidget {
  static const routeName = 'create/page';

  const CreateAccountPage({super.key});

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
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                WidgetMainTitle(title: 'Asociar dispositivo'),
                SizedBox(width: 24),
              ],
            ),
            const SizedBox(height: 16),
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
                              builder: (context) => const AuthActionsQRCode(),
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
