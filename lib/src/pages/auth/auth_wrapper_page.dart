import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:push_notifications/src/auth/create_account_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';

import '../../api/environment.dart';
import '../../providers/auth_request_provider.dart';
import '../../widgets/notifications/widget_flushbar_notification.dart';
import '../client/actions/client_actions_list.dart';
import '../../auth/authentication_page.dart';

class AuthWrapperPage extends StatefulWidget {
  static const routeName = 'auth/wrapper';

  const AuthWrapperPage({super.key});

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

  Widget navigateToAuthentication() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove("wallet");
      prefs.remove("token");
      prefs.remove("auth");
      print('Nuevo dispositivo / token distinto al guardado');
    });

    return const AuthtenticationPage();
  }

  Future<Widget> checkTokenAndAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final auth = prefs.getBool('auth');
    final wallet = prefs.getString('wallet');
    late bool result = false;
    late bool deviceSaved = false;
    WidgetFlushbarNotification customFlushbar;
    late String firebaseToken;
    // Initialize Firebase
    await Firebase.initializeApp();

    //si no hay token ni wallet guardado no ha asociado dispositivo
    if (token != null && wallet != null) {
      firebaseToken = await FirebaseMessaging.instance.getToken() as String;

      //si firebaseToken y token no son iguales, se cambió la config o es otro dispositivo
      if (firebaseToken == token) {
        result = await _verify(token, wallet);
        if (result == true) {
          int attempts = 0;
          while (!_authenticated && attempts < 2) {
            // try up to 5 times
            _authenticated =
                // ignore: use_build_context_synchronously
                await AuthRequestProvider().requestAuthentication(context);
            attempts++;
          }

          if (_authenticated) {
            return const ClientActionsList();
          } else {
            SystemNavigator.pop();
          }
        } else {
          return navigateToAuthentication();
        }
      } else {
        return navigateToAuthentication();
      }

      if (_authenticated) {
        return const CreateAccountPage();
      } else {
        SystemNavigator.pop();
      }
    } else {
      if (auth == true) {
        var attempts = 0;
        while (!_authenticated && attempts < 2) {
          // try up to 5 times
          _authenticated =
              // ignore: use_build_context_synchronously
              await AuthRequestProvider().requestAuthentication(context);
          attempts++;
        }

        if (_authenticated) {
          return const CreateAccountPage();
        } else {
          SystemNavigator.pop();
        }
      } else {
        return navigateToAuthentication();
      }
    }

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<bool> _verify(firebaseToken, wallet) async {
    final prefs = await SharedPreferences.getInstance();
    final response = await http.post(
      Uri.parse("${Environment.API_URL}/auth/verify"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'wallet': wallet ?? "",
        'device_id': firebaseToken ?? "",
      }),
    );

    // Check the server response
    final responseBody = jsonDecode(response.body);

    print(responseBody);

    if (responseBody['result']['found'] != true ||
        responseBody['result']['verified'] != true) {
      // Remove the wallet key
      prefs.remove('wallet');

      return false;
    } else {
      return true;
    }
  }
}
