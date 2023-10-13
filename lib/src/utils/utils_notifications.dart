import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:push_notifications/src/utils/utils_sharedpref_wallet.dart';

import '../api/environment.dart';

class UtilsNotifications {
  final _notificationsStreamController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  Stream<List<Map<String, dynamic>>> get notificationsStream =>
      _notificationsStreamController.stream;

  void fetchStoredNotifications() async {
    String? wallet = await UtilsSharedPrefWallet().getWallet();

    if (wallet == null) {
      _notificationsStreamController.sink.add([]);
    } else {
      final response = await _getNotificationsApi(wallet);
      if (response.statusCode == 200) {
        final List<dynamic> decodedData =
            json.decode(response.body) as List<dynamic>;
        final List<Map<String, dynamic>> notifications =
            decodedData.map((item) => item as Map<String, dynamic>).toList();
        _notificationsStreamController.sink.add(notifications);
      } else {
        _notificationsStreamController.sink.add([]);
      }
    }
  }

  Future<http.Response> _getNotificationsApi(String wallet) async {
    final body = {'wallet': wallet};
    final response = await http.post(
      Uri.parse('${Environment.API_URL}/not/getNotifications'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    return response;
  }

  dispose() {
    _notificationsStreamController.close();
  }
}
