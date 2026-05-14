import 'package:flutter/material.dart';

class StandardData {
  static const String appName = "App Name";

  // Backgrounds
  static const Color mainBackground = Color(0xFF0E0E12);
  static const Color backgroundColor1 = Color(0xFF17171E);
  static const Color backgroundColor2 = Color(0xFF1F1F29);
  static const Color mainColor = Color(0xFF1F1F29);

  // Accents
  static const Color primaryColor = Color(0xFF8B83F0);
  static const Color tealColor = Color(0xFF3ECFA3);
  static const Color amberColor = Color(0xFFF0A040);

  // Tints
  static const Color purpleTint = Color(0x268B83F0);
  static const Color tealTint = Color(0x1F3ECFA3);
  static const Color amberTint = Color(0x1FF0A040);

  // Borders
  static const Color borderSubtle = Color(0x12FFFFFF);
  static const Color borderStrong = Color(0x1FFFFFFF);

  // Text
  static const Color primaryTextColor = Color(0xFFF0EFF8);
  static const Color secondaryTextColor = Color(0xFF9590A8);
  static const Color hintTextColor = Color(0xFF5E5A72);

  // Icons (matching design)
  static const Color iconColor1 = Color(0xFF3ECFA3);
  static const Color iconColor2 = Color(0xFFF0A040);
  static const Color iconColor3 = Color(0xFF8B83F0);

  // Buttons
  static const Color buttonColor1 = Color(0xFF8B83F0);

  static List<String> days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

  static List<String> daysFull = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
  ];

  static void errorSnackbar(final context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error in execution! Try again"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void normalSnackbar(final context, final String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
