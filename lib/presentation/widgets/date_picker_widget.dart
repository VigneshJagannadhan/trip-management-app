import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trippify/core/theme/app_styles.dart';

class DatePickerWidget extends StatelessWidget {
  const DatePickerWidget({
    super.key,
    required this.label,
    this.onTap,
    this.isError = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isError ? Colors.redAccent : Colors.white.withValues(alpha: 0.2);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        height: 50.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: borderColor, width: 1.r),
        ),
        child: Text(label, style: ts14CFFFW400),
      ),
    );
  }
}
