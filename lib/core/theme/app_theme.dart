import 'package:flutter/material.dart';

class AppTheme {
  // Couleurs officielles HeritageMada
  static const Color greenForest = Color(0xFF1B4332);
  static const Color malagasyGold = Color(0xFFD4A017);
  static const Color zebuRed = Color(0xFFC0392B);
  static const Color ivoryWhite = Color(0xFFFFFFFF);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: greenForest,
    scaffoldBackgroundColor: ivoryWhite,
    colorScheme: ColorScheme.light(
      primary: greenForest,
      secondary: malagasyGold,
      error: zebuRed,
      surface: ivoryWhite,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: greenForest,
      foregroundColor: ivoryWhite,
      centerTitle: true,
      elevation: 0,
    ),
  );
}