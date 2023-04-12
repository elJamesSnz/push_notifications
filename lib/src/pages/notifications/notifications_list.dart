import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:push_notifications/src/utils/utils_colors.dart';
import 'package:push_notifications/src/widgets/screens/widget_main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/titles/widget_main_title.dart';

class NotificationList extends StatefulWidget {
  const NotificationList({Key? key}) : super(key: key);

  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  int _visibilityFilter = 1;
  late final PageController _pageController =
      new PageController(initialPage: 0);

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
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handlePageChange(int pageIndex) {
    setState(() {
      print('dfsa');
      _visibilityFilter = pageIndex + 1;
    });
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
                  icon: const Icon(Icons.arrow_back),
                ),
                const WidgetMainTitle(title: 'Lista de notificaciones'),
                const SizedBox(width: 24),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _showNavBar(),
          const SizedBox(height: 24),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _handlePageChange,
              children: [
                _expandedNotificationsList(1),
                _expandedNotificationsList(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navBarOption(
    Color textColor,
    IconData icon,
    String text,
    int pageIndex,
  ) {
    final isSelected = _visibilityFilter == pageIndex;
    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey,
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(
              color: isSelected ? textColor : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _showNavBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _navBarOption(Colors.white, Icons.visibility_off, 'Sin ver', 1),
        _navBarOption(Colors.white, Icons.visibility, 'Vistas', 2),
      ],
    );
  }

  Widget _expandedNotificationsList(int visibilityFilter) {
    return FutureBuilder<List<Map<String, dynamic>>>(
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
          List<Map<String, dynamic>> notifications = snapshot.data!
              .where((n) => n['visibilidad'] == visibilityFilter)
              .toList();

          if (notifications.isEmpty && visibilityFilter == 1) {
            return Center(
                child: const Text('No hay notificaciones pendientes de ver'));
          }

          if (notifications.isEmpty && visibilityFilter == 2) {
            return Center(
                child:
                    const Text('No hay notificaciones marcadas como leídas'));
          }

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
    );
  }
}
