import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme => ThemeData.dark().copyWith(
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF00D9FF),
      secondary: Color(0xFFFF006E),
    ),
  );
}