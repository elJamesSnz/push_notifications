import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class UtilsSharedPrefWallet {
  Future<void> saveWallet(String wallet) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('wallet', wallet);
  }

  Future<String?> getWallet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('wallet');
  }
}
