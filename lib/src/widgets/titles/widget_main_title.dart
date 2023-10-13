import 'package:flutter/material.dart';

class WidgetMainTitle extends StatelessWidget {
  final String title;

  const WidgetMainTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}
