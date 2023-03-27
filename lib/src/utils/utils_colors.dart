import 'package:flutter/material.dart';

class UtilsColors {
  static Color titleBgColor = const Color(0xFF0F172A);
  static Color titleAccentColor = const Color(0xFF313C5C);
  static Color contrastAccentColor = const Color(0xFF50446C);

  static BoxDecoration boxDecoration = const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF423E63),
        Color(0xFF363F60),
        Color(0xFF313C5C),
        Color(0xFF0F172A),
        Color(0xFF0F172A),
      ],
    ),
  );

  static BoxDecoration gradientDecoration = const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF0F172A),
        Color(0xFF0F172A),
        Color(0xFF313C5C),
        Color(0xFF363F60),
        Color(0xFF423E63),
      ],
    ),
  );
}
