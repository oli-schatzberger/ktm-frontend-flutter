import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
    colorScheme: ColorScheme.dark(
        primary: Color(0xFFFF6F00), // KTM orange in dark mode
        onPrimary: Colors.black,   // Black text/icons on primary
        secondary: Color(0xFF1A1A1A), // Dark grey for accents
        onSecondary: Colors.white, // White text/icons on secondary
        surface: Color(0xFF121212), // Dark surface color (material dark theme)
        onSurface: Color(0xFFE0E0E0), // Light grey text on dark surfaces
        background: Color(0xFF000000), // Black background
        onBackground: Color(0xFFE0E0E0), // Light grey text on background
        error: Color(0xFFCF6679),   // Dark red for errors
        onError: Colors.black,      // Black text on error
        inversePrimary: Color(0xFFFF8A00), // Brighter orange for contrast
        tertiary: Color(0xFFFF6F00), // Additional KTM orange for accents
    ),
    // Optional: Set app bar theme to match dark mode
    appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF1A1A1A), // Dark grey
        foregroundColor: Colors.white,     // White text/icons
    ),
    scaffoldBackgroundColor: Color(0xFF000000), // Black app background
);
