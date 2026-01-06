import 'package:flutter/material.dart';

class AppColors {
  // Deep dark background colors for a premium feel
  static const Color primaryBg = Color(0xFF0D0D0D); // Near black
  static const Color secondaryBg = Color(0xFF1A1A2E); // Deep midnight blue
  static const Color accentBg = Color(0xFF16213E); // Dark slate

  // High-contrast Neon Gradient
  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0F0C29), // Deep Space
      Color(0xFF302B63), // Royal Purple
      Color(0xFF24243E), // Midnight
    ],
  );

  // Vibrant Neon colors for players to pop against the dark UI
  static const Color playerXColor = Color(0xFF00E5FF); // Electric Cyan Neon
  static const Color playerOColor = Color(0xFFFF007F); // Hot Pink Neon
}

class AppStyles {
  static const double borderRadius = 16.0;
}