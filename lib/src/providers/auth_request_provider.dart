// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../widgets/notifications/widget_flushbar_notification.dart';

class AuthRequestProvider {
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> requestAuthentication(BuildContext context) async {
    bool isAuthenticated = false;

    try {
      isAuthenticated = await _localAuth.authenticate(
          localizedReason: 'Por favor, autentícate para continuar.',
          options: const AuthenticationOptions(biometricOnly: false));

      if (isAuthenticated) {
        WidgetFlushbarNotification customFlushbar = WidgetFlushbarNotification(
            title: '', message: 'Autenticación correcta', duration: 2);
        customFlushbar.flushbar(context).show(context);
      } else {
        WidgetFlushbarNotification customFlushbar = WidgetFlushbarNotification(
            title: '', message: 'Autenticación fallida', duration: 2);
        customFlushbar.flushbar(context).show(context);
      }
    } on PlatformException catch (e) {
      print(e);
    }

    return isAuthenticated;
  }
}
