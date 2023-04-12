import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../../../widgets/notifications/widget_flushbar_notification.dart';
import 'client_actions_list.dart';

class ClientActionsQRCode extends StatefulWidget {
  static const routeName = 'client/qrcode';

  @override
  _ClientActionsQRCodeState createState() => _ClientActionsQRCodeState();
}

class _ClientActionsQRCodeState extends State<ClientActionsQRCode> {
  MobileScannerController? _cameraController;
  String? _qrCodeData;
  bool _screenOpened = false;

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
        ],
      ),
    );
  }

  void _foundBarcode(BarcodeCapture barcodeCapture) {
    if (!_screenOpened) {
      String? code = barcodeCapture.barcodes.first.rawValue;

      debugPrint('Barcode found! $code');
      _screenOpened = true;
      final decodedData = json.decode(code!);
      if (decodedData is Map && decodedData['registro'] == true) {
        _sendDeviceIdToServer();
        _cameraController?.stop();
        Navigator.pushNamed(context, ClientActionsList.routeName);
        WidgetFlushbarNotification(
          title: '',
          message: 'Se envió el token Id: ${decodedData['tokenSession']}',
          duration: 2,
        ).flushbar(context).show(context);
      }
    }
  }

  Future<void> _sendDeviceIdToServer() async {
    final String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      final newSocket = io("http://localhost:4000/");
      newSocket.emit("device-id", token);
      print("Se hace emit del token");
      print(newSocket.toString());
      print(token);
    } else {
      print('Error: Device token is null');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}
