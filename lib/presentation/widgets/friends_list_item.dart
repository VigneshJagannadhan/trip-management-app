import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trippify/core/theme/app_styles.dart';

class FriendsListItem extends StatelessWidget {
  const FriendsListItem({super.key, required this.image, required this.name});

  final String image;
  final String name;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.r,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(backgroundImage: NetworkImage(image)),
              SizedBox(width: 10.w),
              Text(name, style: ts14CFFFW400),
            ],
          ),
        ),
      ),
    );
  }
}
