import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:push_notifications/src/pages/client/actions/client_actions_qrcode.dart';
import 'package:push_notifications/src/utils/utils_colors.dart';

import 'src/pages/auth/auth_wrapper_page.dart';
import 'src/pages/client/actions/client_actions_list.dart';
import 'src/auth/authentication_page.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

Future printFirebaseToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  print("Firebase Token: $token");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // ignore: await_only_futures
  await printFirebaseToken();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      initialRoute: AuthWrapperPage.routeName,
      routes: {
        '/': (BuildContext context) => const AuthWrapperPage(),
        ClientActionsList.routeName: (BuildContext context) =>
            const ClientActionsList(),
        AuthWrapperPage.routeName: (BuildContext context) =>
            const AuthWrapperPage(),
        AuthtenticationPage.routeName: (BuildContext context) =>
            const AuthtenticationPage(),
        ClientActionsQRCode.routeName: (BuildContext context) =>
            const ClientActionsQRCode(),
      },
    );
  }
}
