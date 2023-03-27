import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';

class PushNotificationsProvider {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  initNotifications() async {
    //await Firebase.initializeApp();
    _firebaseMessaging.requestPermission();
    _firebaseMessaging.getToken().then((value) {
      print(value);
    });

    //app abierta
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
          'Got a message whilst in the foreground!: ${message.notification!.title}');
      print('Message foreground: ${message.data}');
     
    });

    //click en notificacion
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      print('Message onMessageOpenedApp: ${message.data}');
      
    });
  }
}
