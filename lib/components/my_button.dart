import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final Function()? onTap;
  final String text;

  const MyButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary, // Primary color for button background
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2), // Subtle shadow
              offset: const Offset(0, 4),
              blurRadius: 6,
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary, // Text color for contrast
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
