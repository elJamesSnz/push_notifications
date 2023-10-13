import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/utils_colors.dart';

class WidgetActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;

  const WidgetActionCard({super.key, 
    required this.title,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          HapticFeedback.selectionClick();
          onPressed();
        },
        onLongPress: () {
          HapticFeedback.mediumImpact();
        },
        highlightColor: Colors.grey.withOpacity(0.8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: UtilsColors.titleAccentColor,
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
