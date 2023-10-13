import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

import '../../utils/utils_colors.dart';

class WidgetFlushbarNotification {
  final String title;
  final String message;
  final int duration;
  final FlushbarPosition flushbarPosition;

  WidgetFlushbarNotification({
    required this.title,
    required this.message,
    this.duration = 4,
    this.flushbarPosition = FlushbarPosition.TOP,
  });

  Flushbar flushbar(BuildContext context) {
    return Flushbar(
      flushbarPosition: flushbarPosition,
      messageText: Row(
        children: [
          Icon(
            Icons.notifications,
            color: UtilsColors.titleAccentColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: UtilsColors.titleAccentColor,
                  ),
                ),
                Text(
                  message,
                  style: TextStyle(
                    color: UtilsColors.titleAccentColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white.withOpacity(0.9),
      margin: const EdgeInsets.fromLTRB(16, 50, 16, 20),
      borderRadius: BorderRadius.circular(8),
      duration: Duration(seconds: duration),
    );
  }
}
