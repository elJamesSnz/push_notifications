import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/utils_colors.dart';

class WidgetMainScreen extends StatelessWidget {
  final Widget body;
  final Widget? leading;
  final List<Widget>? actions;

  const WidgetMainScreen({
    Key? key,
    required this.body,
    this.leading,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: UtilsColors.titleBgColor,
          statusBarIconBrightness: Brightness.light,
        ),
        child: SafeArea(
          child: Container(
            decoration: UtilsColors.gradientDecoration,
            child: body,
          ),
        ),
      ),
    );
  }
}
