import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trippify/core/theme/app_colors.dart';

class BottomNavIcon extends StatelessWidget {
  const BottomNavIcon({
    super.key,
    required this.svgIcon,
    this.isSelected = false,
    this.onTap,
  });

  final String svgIcon;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color iconColor =
        isSelected ? colorFFF : colorFFF.withValues(alpha: 0.7);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.r, vertical: 20.r),
        decoration:
            isSelected
                ? BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.20),
                  ),
                )
                : null,
        child: SvgPicture.asset(
          svgIcon,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          width: 30.r,
          height: 30.r,
        ),
      ),
    );
  }
}
