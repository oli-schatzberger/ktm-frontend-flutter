import 'package:flutter/material.dart';

/// Light mode theme
ThemeData lightMode = ThemeData(
    colorScheme: ColorScheme.light(
      primary: Colors.black,
      // KTM orange
      onPrimary: Colors.white,
      // White text/icons on primary
      secondary: Color(0xFF000000),
      // Black for secondary
      onSecondary: Colors.white,
      // White text/icons on secondary
      surface: Color(0xFFF5F5F5),
      // Light grey for surfaces
      onSurface: Color(0xFF000000),
      // Black text on surfaces
      background: Colors.white,
      // White background
      onBackground: Color(0xFF000000),
      // Black text on background
      error: Color(0xFFB00020),
      // Red for error
      onError: Colors.white,
      // White text on error
      inversePrimary: Color(0xFF6A3800),
      // Darker orange
      tertiary: Colors.black, // Additional KTM orange for accents
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.black), // Default for large text
      bodyMedium: TextStyle(color: Colors.black), // Default for regular text
      headlineLarge: TextStyle(color: Color(0xFFF97300)), // Orange headlines
      titleMedium: TextStyle(color: Colors.grey[800]), // Subtle grey text
    ));
