import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:trippify/core/constants/app_assets.dart';
import 'package:trippify/core/theme/app_colors.dart';
import 'package:trippify/core/theme/app_styles.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.backgroundColor,
    this.isLoading = false,
  });

  final String label;
  final Function()? onTap;
  final Color? backgroundColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1.sw,
      height: 50.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? secondaryColor,
        ),
        onPressed: isLoading ? () {} : onTap,
        child:
            isLoading
                ? Lottie.asset(AppAssets.loadingLottie)
                : Text(label, style: ts16CFFW400),
      ),
    );
  }
}
