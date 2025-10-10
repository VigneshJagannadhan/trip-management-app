import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trippify/core/theme/app_styles.dart';

class DatePickerWidget extends StatelessWidget {
  const DatePickerWidget({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.r,
        ),
      ),
      child: Text(label, style: ts14CFFFW400),
    );
  }
}
