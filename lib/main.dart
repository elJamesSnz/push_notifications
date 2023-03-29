import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:push_notifications/src/pages/notifications/notifications_list.dart';
import 'package:push_notifications/src/utils/utils_colors.dart';

import 'src/pages/auth/auth_wrapper_page.dart';
import 'src/pages/client/actions/client_actions_list.dart';

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
      initialRoute: AuthWrapperPage.routeName,
      routes: {
        '/': (BuildContext context) => AuthWrapperPage(),
        ClientActionsList.routeName: (BuildContext context) =>
            ClientActionsList(),
        AuthWrapperPage.routeName: (BuildContext context) => AuthWrapperPage(),
      },
    );
  }
}
