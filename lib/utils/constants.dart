import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBg = Color(0xFF1a2a6c);
  static const Color secondaryBg = Color(0xFFb21f1f);
  static const Color accentBg = Color(0xFFfdbb2d);

  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1a2a6c), Color(0xFFb21f1f), Color(0xFFfdbb2d)],
  );

  static const Color playerXColor = Colors.cyanAccent;
  static const Color playerOColor = Colors.orangeAccent;
}

class AppStyles {
  static const double borderRadius = 16.0;
}