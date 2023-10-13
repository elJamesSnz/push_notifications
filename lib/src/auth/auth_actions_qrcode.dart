import 'dart:async';
import 'dart:convert';
import 'package:push_notifications/src/pages/auth/auth_wrapper_page.dart';
import 'package:push_notifications/src/utils/utils_sharedpref_wallet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:push_notifications/src/providers/qrcode_provider.dart';

import '../utils/utils_colors.dart';
import '../widgets/notifications/widget_flushbar_notification.dart';

class AuthActionsQRCode extends StatefulWidget {
  static const routeName = 'auth/qrcode';

  const AuthActionsQRCode({super.key});

  @override
  _AuthActionsQRCodeState createState() => _AuthActionsQRCodeState();
}

class _AuthActionsQRCodeState extends State<AuthActionsQRCode> {
  MobileScannerController? _cameraController;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _qrCodeData;
  bool _screenOpened = false;
  late http.Response response;
  late String solicitud = "";
  final int _countdown = 5;
  Timer? _countdownTimer;
  int res = 0;

  @override
  void initState() {
    super.initState();
    _cameraController = MobileScannerController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: _cameraController!,
            onDetect: (BarcodeCapture barcode) => _foundBarcode(barcode),
          ),
          Positioned(
            bottom: 40,
            child: Text(
              'QR Code Data: $_qrCodeData',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: _finish,
              child: Container(
                height: 60,
                color: UtilsColors.titleBgColor,
                child: const Center(
                  child: Text(
                    'Haz clic para cerrar la cámara',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _foundBarcode(BarcodeCapture barcodeCapture) async {
    if (!_screenOpened) {
      String? code = barcodeCapture.barcodes.first.rawValue;
      _screenOpened = true;
      final decodedData = json.decode(code!);

      if (decodedData is Map) {
        _showBottomBar("Se encontró QR, haciendo petición");
        solicitud = decodedData['accion'];
        switch (decodedData['accion']) {
          case 'registrar':
            response =
                await QrCodeProvider().sendDeviceIdToServer(decodedData['jwt']);

            if (response.statusCode == 200) {
              final responseBody = json.decode(response.body);
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String token = await _firebaseMessaging.getToken() as String;
              await prefs.setString("token", token);
              final wallet = responseBody['wallet'] as String;
              UtilsSharedPrefWallet().saveWallet(wallet);
            }
            break;

          default:
            notify('inválido', 'QR inválido');
            break;
        }

        switch (response.statusCode) {
          case 200:
            solicitud = 'Solicitud [$solicitud]: autorizada';

            break;
          case 404:
            solicitud = 'Solicitud [$solicitud]: inválida';
            break;
          case 400:
            solicitud = 'Solicitud [$solicitud]: inválida';
            break;
          case 401:
            solicitud = 'Solicitud [$solicitud]: no autorizada / expirada';
            break;
          case 500:
            solicitud = 'Solicitud [$solicitud]: no realizada correctamente';
            break;
        }

        notify('Respuesta a solicitud', solicitud);

        _showBottomBar('Haga clic para salir o espere 5 segundos');

        Future.delayed(const Duration(seconds: 5), () {
          _finish();
        });
      }
    }
  }

  void _showBottomBar(String bodyText) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: _finish,
          child: Container(
            height: 80,
            color: UtilsColors.titleBgColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    bodyText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (res == 1 && _countdown > 0)
                    Container(
                      height: 60,
                      color: UtilsColors.titleAccentColor,
                      child: Center(
                        child: Text(
                          'Cerrando ventana en $_countdown segundos',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void notify(String title, String txt) {
    WidgetFlushbarNotification(
      title: title,
      message: txt,
      duration: 4,
    ).flushbar(context).show(context);
  }

  void _finish() {
    _cameraController?.stop();
    Navigator.pushNamed(context, AuthWrapperPage.routeName);
  }
}
