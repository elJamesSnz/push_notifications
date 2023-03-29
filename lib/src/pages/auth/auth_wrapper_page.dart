import 'package:flutter/material.dart';

import '../../providers/auth_request_provider.dart';
import '../client/actions/client_actions_list.dart';

class AuthWrapperPage extends StatefulWidget {
  static const routeName = 'auth/wrapper';

  @override
  _AuthWrapperPageState createState() => _AuthWrapperPageState();
}

class _AuthWrapperPageState extends State<AuthWrapperPage> {
  bool _authenticated = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthRequestProvider().requestAuthentication(context),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _authenticated = snapshot.data!;

          if (_authenticated) {
            return ClientActionsList();
          } else {
            return Container(
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        } else {
          return Container(
            color: Colors.white,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
