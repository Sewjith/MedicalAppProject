import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';

class AppTheme {
  static final _border = OutlineInputBorder(
    borderSide: const BorderSide(
      color: AppPallete.borderColor,
      width: 2,
    ),
    borderRadius: BorderRadius.circular(10),
  );

  static final lightThemeMode = ThemeData.light().copyWith(
    scaffoldBackgroundColor: AppPallete.backgroundColor,
    primaryColor: AppPallete.primaryColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPallete.whiteColor,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(16),
      enabledBorder: _border,
      focusedBorder: _border,
      filled: true,
      fillColor: AppPallete.whiteColor,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle( // Replaces headline1
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      bodyLarge: TextStyle( // Replaces bodyText1
        fontSize: 16,
        color: Colors.black,
      ),
      bodyMedium: TextStyle( // Replaces bodyText2
        fontSize: 14,
        color: AppPallete.greyColor,
      ),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: AppPallete.primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppPallete.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppPallete.whiteColor,
      selectedItemColor: AppPallete.primaryColor,
      unselectedItemColor: AppPallete.greyColor,
    ),
  );
}
