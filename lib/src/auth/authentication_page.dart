// ignore_for_file: use_build_context_synchronously

import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

import '../widgets/cards/widget_action_card.dart';
import '../widgets/notifications/widget_flushbar_notification.dart';
import '../widgets/screens/widget_main_screen.dart';
import '../widgets/titles/widget_main_title.dart';

import '../pages/client/actions/client_actions_list.dart';

class AuthtenticationPage extends StatefulWidget {
  static const routeName = 'auth/page';

  @override
  _AuthtenticationPageState createState() => _AuthtenticationPageState();
}

class _AuthtenticationPageState extends State<AuthtenticationPage> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late WidgetFlushbarNotification customFlushbar;

  Future<void> _authenticate() async {
    customFlushbar = WidgetFlushbarNotification(
        title: '', message: 'Autenticación registrada', duration: 2);
    try {
      bool isAuthenticated = await _localAuth.authenticate(
          localizedReason: 'Por favor, autentícate para continuar.',
          options: const AuthenticationOptions(biometricOnly: false));

      if (isAuthenticated) {
        customFlushbar.flushbar(context).show(context);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String token = await _firebaseMessaging.getToken() as String;
        print('El token ID que se guardará es ${token}');
        await prefs.setString("token", token);
        await prefs.setBool("auth", true);
        Navigator.pushNamed(context, ClientActionsList.routeName);
      } else {
        customFlushbar = WidgetFlushbarNotification(
            title: '', message: 'Autenticación fallida', duration: 2);
        customFlushbar.flushbar(context).show(context);
      }
    } on PlatformException catch (e) {
      print(e);

      if (e.code == auth_error.notAvailable) {
        // to-do
      } else if (e.code == auth_error.notEnrolled) {
        // ...
      } else {
        // ...
      }
    }
  }

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
                WidgetMainTitle(title: 'Registro de autenticación'),
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
                        title: 'Registrar autenticación',
                        icon: Icons.face,
                        onPressed: _authenticate,
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
