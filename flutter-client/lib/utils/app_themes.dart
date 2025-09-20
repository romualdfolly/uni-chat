import 'package:flutter/material.dart';

class AppThemes {

  static const cardBackgroundDark = Color.fromARGB(255, 48, 48, 49);
  static const cardBackgroundLight = Colors.white;
  static const pageBackgroundDark = Color(0xFF1C1C1E);
  static const pageBackgroundLight = Colors.white;

  static final light = ThemeData(
    primaryColor: const Color(0xFF0088CC),
    scaffoldBackgroundColor: const Color(0xFFFFFFFF),
    brightness: Brightness.light,
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF0088CC),
      elevation: 0,
      iconTheme: IconThemeData(
        color: Colors.black,
      )
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF0088CC),
      primary: const Color(0xFF0088CC),
      brightness: Brightness.light,
      surface: Colors.white
    ),
    cardColor: Colors.white,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFFFFFFFF),
      selectedItemColor: const Color(0xFF0088CC),
      unselectedItemColor: const Color(0xFF4E4E4E),
    ),
  );

  static final dark = ThemeData(
    primaryColor: const Color(0xFF0088CC),
    scaffoldBackgroundColor: const Color(0xFF1E1E1E),
    brightness: Brightness.dark,
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF0088CC),
      elevation: 0,
      iconTheme: IconThemeData(
        color: Colors.white,
      )
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF0088CC),
      primary: const Color(0xFF0088CC),
      brightness: Brightness.dark,
      surface: const Color(0xFF2C2C2C)
    ),
    cardColor: const Color(0xFF2C2C2C),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF1E1E1E),
      selectedItemColor: const Color(0xFF00AAFF),
      unselectedItemColor: const Color(0xFFB0B0B0),
    ),
  );
}
