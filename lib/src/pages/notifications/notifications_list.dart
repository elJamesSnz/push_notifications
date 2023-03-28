import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:push_notifications/src/utils/utils_colors.dart';
import 'package:push_notifications/src/widgets/screens/widget_main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationList extends StatelessWidget {
  const NotificationList({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> _getStoredNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> stringList = prefs.getStringList('notifications') ?? [];
    List<Map<String, dynamic>> notifications = stringList
        .map((item) => json.decode(item) as Map<String, dynamic>)
        .toList();
    return notifications;
  }

  void _showNotificationDetails(
      BuildContext context, Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalles de la notificación'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Timestamp: ${notification['timestamp']}'),
              SizedBox(height: 8),
              Text('Datos: ${notification['data']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WidgetMainScreen(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back),
                ),
                Text(
                  'Lista de notificaciones',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 24),
              ],
            ),
          ),
          _expandedNotificationsList()
        ],
      ),
    );
  }

  Widget _expandedNotificationsList() {
    return Expanded(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getStoredNotifications(),
        builder: (BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar notificaciones.'));
          }

          if (snapshot.hasData) {
            List<Map<String, dynamic>> notifications = snapshot.data!;
            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (BuildContext context, int index) {
                Map<String, dynamic> notification = notifications[index];
                return ListTile(
                  title: Text(notification['timestamp'].toString()),
                  subtitle: Text(notification['data'].toString()),
                  onTap: () => _showNotificationDetails(context, notification),
                );
              },
            );
          }

          return Center(child: Text('No hay notificaciones disponibles.'));
        },
      ),
    );
  }
}
