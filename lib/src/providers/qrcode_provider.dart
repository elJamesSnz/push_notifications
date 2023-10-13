import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import '../api/environment.dart';
import '../utils/utils_sharedpref_wallet.dart';

class QrCodeProvider {
  Future<http.Response> sendDeviceIdToServer(String tokenJWT) async {
    final String? deviceId = await FirebaseMessaging.instance.getToken();
    if (deviceId != null) {
      final response = await _sendPostApi(
        url: '/auth/save',
        authorization: tokenJWT,
        body: <String, String>{
          'device_id': deviceId,
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
    final String? deviceId = await FirebaseMessaging.instance.getToken();
    final String? wallet = await UtilsSharedPrefWallet().getWallet();

    if (deviceId != null && wallet != null) {
      final response = await _sendPostApi(
        url: '/not/authNotification',
        authorization: tokenJWT,
        body: <String, String>{
          'token': tokenJWT,
          'accion': 'autorizar',
          'device_id': deviceId,
          'wallet': wallet,
        },
      );
      return response;
    } else {
      print('Error: Device token or wallet is null');
      return http.Response('Device token or wallet is null', 500);
    }
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

    print('petición POST\n$url-$authorization-"$body');

    final response = await http.post(
      Uri.parse('${Environment.API_URL}$url'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        if (authorization.isNotEmpty) 'authorization': authorization,
      },
      body: jsonEncode(body),
    );

    return response;
  }
}
