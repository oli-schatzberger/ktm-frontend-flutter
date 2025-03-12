import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 25.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        cursorColor: Theme.of(context).colorScheme.primary, // Cursor matches theme
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface, // Input text color
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface, // Background fill color
          hintText: hintText,
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), // Subtle hint text
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.tertiary, // Default border color
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary, // Focused border color
              width: 2.0,
            ),
          ),
        ),
      ),
    );
  }
}
