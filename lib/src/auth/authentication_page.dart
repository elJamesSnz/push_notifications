// ignore_for_file: use_build_context_synchronously

import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

import '../widgets/notifications/widget_flushbar_notification.dart';

class AuthtenticationPage extends StatefulWidget {
  @override
  _AuthtenticationPageState createState() => _AuthtenticationPageState();
}

class _AuthtenticationPageState extends State<AuthtenticationPage> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> _authenticate() async {
    WidgetFlushbarNotification customFlushbar = WidgetFlushbarNotification(
        title: '', message: 'Autenticación exitosa', duration: 2);
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
    return Scaffold(
      appBar: AppBar(title: const Text('Autenticación biométrica')),
      body: Center(
        child: ElevatedButton(
          onPressed: _authenticate,
          child: const Text('Autenticarse'),
        ),
      ),
    );
  }
}
