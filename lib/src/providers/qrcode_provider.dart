import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import '../../src/widgets/notifications/widget_flushbar_notification.dart';
import '../api/environment.dart';

class QrCodeProvider {
  Future<http.Response> sendDeviceIdToServer(String tokenJWT) async {
    final String? device_id = await FirebaseMessaging.instance.getToken();
    if (device_id != null) {
      final response = await _sendPostApi(
        url: '/auth/save',
        authorization: tokenJWT,
        body: <String, String>{
          'device_id': device_id,
          'token': tokenJWT,
        },
      );
      return response;
    } else {
      print('Error: Device token is null');

      return http.Response('Device token is null', 500);
    }
  }

  Future<http.Response> sendAuthorizationToServer(String tokenJWT) async {
    final response = await _sendPostApi(
      url: '/auth/authorize',
      authorization: tokenJWT,
      body: <String, String>{
        'token': tokenJWT,
      },
    );
    return response;
  }

  Future<http.Response> sendMarketAuthorizationToServer(String tokenJWT) async {
    final response = await _sendPostApi(
      url: '/auth/market',
      authorization: tokenJWT,
      body: <String, String>{
        'token': tokenJWT,
      },
    );
    return response;
  }

  Future<http.Response> test() async {
    final response = await _sendPostApi(url: '/');
    return response;
  }

  Future<http.Response> _sendPostApi({
    required String url,
    String? authorization,
    Map<String, String>? body,
  }) async {
    authorization ??= '';
    body ??= {};

    print('petición POST\n${url}-${authorization}-"${body}');

    final response = await http.post(
      Uri.parse('${Environment.API_URL}${url}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        if (authorization.isNotEmpty) 'authorization': authorization,
      },
      body: jsonEncode(body),
    );

    return response;
  }
}
