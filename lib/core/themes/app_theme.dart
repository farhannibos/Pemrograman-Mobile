// lib/core/themes/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white, // Warna teks di AppBar
    ),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.blue,
      brightness: Brightness.light,
    ).copyWith(
      secondary: Colors.amber, // Warna aksen
    ),
    // Tambahan kustomisasi tema terang lainnya
  );

  static final ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.indigo,
    brightness: Brightness.dark,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212),
      foregroundColor: Colors.white,
    ),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.indigo,
      brightness: Brightness.dark,
    ).copyWith(
      secondary: Colors.teal, // Warna aksen
      background: const Color(0xFF1E1E1E), // Warna background gelap
    ),
    scaffoldBackgroundColor: const Color(0xFF1E1E1E),
    // Tambahan kustomisasi tema gelap lainnya
  );
}