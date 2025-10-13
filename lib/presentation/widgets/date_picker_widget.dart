import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trippify/core/theme/app_colors.dart';

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isSelected = !label.contains('Date'); // Has a date selected

    final borderColor =
        isError
            ? accentOrange
            : isSelected
            ? secondaryColor
            : (isDarkMode ? Colors.white.withValues(alpha: 0.2) : neutral300);

    final bgColor =
        isSelected
            ? secondaryColor.withValues(alpha: 0.1)
            : (isDarkMode ? Colors.white.withValues(alpha: 0.05) : neutral100);

    final textColor =
        isSelected ? secondaryColor : (isDarkMode ? Colors.white : neutral900);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        height: 56.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: borderColor, width: isError ? 2 : 1),
          color: bgColor,
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 18.r,
              color:
                  isSelected
                      ? secondaryColor
                      : (isDarkMode ? neutral400 : neutral600),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: textColor,
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: isDarkMode ? neutral400 : neutral600,
              size: 24.r,
            ),
          ],
        ),
      ),
    );
  }
}
