import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trippify/core/theme/app_colors.dart';
import 'package:trippify/core/theme/app_styles.dart';

ThemeData appTheme({required bool darkMode}) {
  final secondary = darkMode ? secondaryColor : darkSecondaryColor;
  final scaffoldBg = darkMode ? primaryColor : darkPrimaryColor;
  final textColor = darkMode ? neutral50 : neutral900;

  return ThemeData(
    scaffoldBackgroundColor: scaffoldBg,
    brightness: darkMode ? Brightness.dark : Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: secondaryColor,
      brightness: darkMode ? Brightness.dark : Brightness.light,
      primary: secondaryColor,
      secondary: accentTeal,
      surface: darkMode ? neutral800 : neutral50,
      surfaceTint: scaffoldBg,
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
      fillColor: darkMode ? neutral800 : neutral100,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      labelStyle: TextStyle(
        color: darkMode ? neutral300 : neutral600,
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: darkMode ? neutral600 : neutral300,
          width: 1.r,
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: darkMode ? neutral600 : neutral300,
          width: 1.r,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: secondaryColor, width: 2.r),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: accentOrange, width: 1.r),
      ),

      hintStyle: TextStyle(
        color: darkMode ? neutral400 : neutral500,
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
      ),
    ),
  );
}
