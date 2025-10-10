import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trippify/core/theme/app_styles.dart';

void showGeneralErrorSnackbar({
  required BuildContext context,
  required String message,
}) {
  final snackBar = SnackBar(
    backgroundColor: Colors.white, // white background
    behavior: SnackBarBehavior.floating, // floating style
    margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.r), // curved edges
    ),
    content: Row(
      children: [
        Icon(Icons.error_outline, color: Colors.red, size: 24.r),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            message,
            style: TextStyle(color: Colors.black, fontSize: 14.sp),
          ),
        ),
      ],
    ),
    duration: const Duration(seconds: 3),
  );

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}

void showGeneralSuccessSnackbar({
  required BuildContext context,
  required String message,
}) {
  final snackBar = SnackBar(
    backgroundColor: Colors.white,
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
    content: Row(
      children: [
        Icon(Icons.check, color: Colors.green, size: 24.r),
        SizedBox(width: 12.w),
        Expanded(child: Text(message, style: ts14C000W400)),
      ],
    ),
    duration: const Duration(seconds: 3),
  );

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}
