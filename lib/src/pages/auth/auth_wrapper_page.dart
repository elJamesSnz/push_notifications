// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../providers/auth_request_provider.dart';
import '../../widgets/notifications/widget_flushbar_notification.dart';
import '../client/actions/client_actions_list.dart';
import '../../auth/authentication_page.dart';

class AuthWrapperPage extends StatefulWidget {
  static const routeName = 'auth/wrapper';

  @override
  _AuthWrapperPageState createState() => _AuthWrapperPageState();
}

class _AuthWrapperPageState extends State<AuthWrapperPage> {
  bool _authenticated = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: checkTokenAndAuth(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data!;
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Future<Widget> checkTokenAndAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final auth = prefs.getBool('auth');
    WidgetFlushbarNotification customFlushbar;

    if (token != null && auth == true) {
      final firebaseToken =
          await FirebaseMessaging.instance.getToken() as String;
      if (firebaseToken == token) {
        print('Bienvenido');
        //_authenticated =
        //  await AuthRequestProvider().requestAuthentication(context);
        _authenticated = true;
        if (_authenticated) {
          return ClientActionsList();
        } else {}
      } else {
        print('Nuevo dispositivo / token distinto al guardado');
        return AuthtenticationPage();
      }
    } else {
      print('Primera vez iniciando la aplicación');
      return AuthtenticationPage();
    }

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
