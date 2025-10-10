import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trippify/core/theme/app_colors.dart';
import 'package:trippify/core/theme/app_styles.dart';

ThemeData appTheme({required bool darkMode}) {
  final primary = darkMode ? primaryColor : darkPrimaryColor;
  final secondary = darkMode ? secondaryColor : darkSecondaryColor;
  final scaffoldBg = darkMode ? primaryColor : darkPrimaryColor;
  final textColor = darkMode ? Colors.black : Colors.white;

  return ThemeData(
    scaffoldBackgroundColor: scaffoldBg,
    brightness: darkMode ? Brightness.light : Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: darkMode ? Brightness.light : Brightness.dark,
    ),
    useMaterial3: true,

    /// --- AppBar theme ---
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: scaffoldBg,
      iconTheme: IconThemeData(color: textColor),
      titleTextStyle: ts20CFFFW400.copyWith(color: textColor),
    ),

    /// --- ElevatedButton theme ---
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: secondary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
      ),
    ),

    /// --- TextField theme ---
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor:
          darkMode
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.08),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      labelStyle: ts14CFFFW400,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.r),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: darkMode ? 0.2 : 0.3),
          width: 1.r,
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.r),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: darkMode ? 0.3 : 0.4),
          width: 1.r,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.r),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: darkMode ? 0.8 : 0.9),
          width: 1.r,
        ),
      ),

      hintStyle: TextStyle(
        color: Colors.white.withValues(alpha: darkMode ? 0.5 : 0.6),
        fontSize: 14.sp,
      ),
    ),
  );
}
