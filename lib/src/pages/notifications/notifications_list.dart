import 'package:flutter/material.dart';
import 'package:push_notifications/src/utils/utils_colors.dart';
import 'package:push_notifications/src/widgets/screens/widget_main_screen.dart';

import '../../providers/push_notifications_provider.dart';
import '../../utils/utils_notifications.dart';
import '../../widgets/titles/widget_main_title.dart';

class NotificationList extends StatefulWidget {
  const NotificationList({super.key});

  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  final UtilsNotifications _sharedPreferencesNotifications =
      UtilsNotifications();

  int _visibilityFilter = 1;
  late final PageController _pageController =
      PageController(initialPage: 0);
  int notificationCount = 0;

  late PushNotificationsProvider pushNotificationsProvider;
  late String? wallet = '';
  List<Map<String, dynamic>> notificationsList = [];

  void _showNotificationDetails(
      BuildContext context, Map<String, dynamic> notification) {
    DateTime timestamp = DateTime.parse(notification['timestamp']);
    String formattedTimestamp =
        "${timestamp.day.toString().padLeft(2, '0')}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.year}";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '${notification['title']}',
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Fecha: $formattedTimestamp',
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${notification['subtitle']}',
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${notification['body']}',
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tipo: ${notification['notification']['type'].toString().toLowerCase()}',
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              Text(
                'Tipo: ${notification['notification']['result'].toString().toLowerCase()}',
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
          backgroundColor: UtilsColors.titleAccentColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    pushNotificationsProvider = PushNotificationsProvider(context);
    pushNotificationsProvider.initialize();

    _sharedPreferencesNotifications.notificationsStream
        .listen((storedNotifications) {
      setState(() {
        notificationCount = storedNotifications.length;
        notificationsList = storedNotifications;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handlePageChange(int pageIndex) {
    setState(() {
      _visibilityFilter = pageIndex + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: pushNotificationsProvider.notificationsStream,
      builder: (BuildContext context,
          AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar notificaciones.'));
        }

        if (!snapshot.hasData) {
          return const Center(
              child: Text('No hay notificaciones disponibles.'));
        }

        List<Map<String, dynamic>> notifications = snapshot.data!;
        print('tamaño data: ${notifications.length}');

        return WidgetMainScreen(
          body: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    _expandedNotificationsList(notifications, false),
                    _expandedNotificationsList(notifications, true),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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

  Widget _expandedNotificationsList(
      List<Map<String, dynamic>> notifications, bool visibilityFilter) {
    List<Map<String, dynamic>> filteredNotifications =
        notifications.where((n) => n['seen'] == visibilityFilter).toList();

    if (filteredNotifications.isEmpty && !visibilityFilter) {
      return const Center(
          child: Text('No hay notificaciones pendientes de ver'));
    }

    if (filteredNotifications.isEmpty && visibilityFilter) {
      return const Center(
          child: Text('No hay notificaciones marcadas como leídas'));
    }

    return ListView.builder(
      itemCount: filteredNotifications.length,
      itemBuilder: (BuildContext context, int index) {
        Map<String, dynamic> notification = filteredNotifications[index];

        DateTime timestamp = DateTime.parse(notification['timestamp']);
        String formattedTimestamp =
            "${timestamp.day.toString().padLeft(2, '0')}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.year}";

        return ListTile(
          title: Text('[$formattedTimestamp]- ${notification['title']}'),
          subtitle: Text(notification['subtitle'].toString()),
          onTap: () => _showNotificationDetails(context, notification),
        );
      },
    );
  }
}
