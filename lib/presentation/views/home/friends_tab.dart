import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trippify/core/constants/app_assets.dart';
import 'package:trippify/core/theme/app_styles.dart';
import 'package:trippify/core/theme/app_colors.dart';
import 'package:trippify/presentation/widgets/friends_list_item.dart';

class FriendsTab extends StatelessWidget {
  const FriendsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: primaryColor,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          FriendsTabAppbar(),
          FriendsTabBody(),
          SliverToBoxAdapter(child: SizedBox(height: 100.h)),
        ],
      ),
    );
  }
}

class FriendsTabBody extends StatelessWidget {
  const FriendsTabBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      sliver: SliverList.separated(
        itemCount: 20,
        itemBuilder:
            (context, index) => FriendsListItem(
              image: "${AppAssets.dummyImageIndex}$index",
              name: "Jake Doe",
            ),
        separatorBuilder: (context, index) => SizedBox(height: 10.h),
      ),
    );
  }
}

class FriendsTabAppbar extends StatelessWidget {
  const FriendsTabAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      pinned: false,
      snap: false,
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      expandedHeight: 60.h,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            padding: EdgeInsets.only(
              top: 40.h,
              left: 20.w,
              right: 20.w,
              bottom: 20.h,
            ),
            alignment: Alignment.bottomLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Fellow travellers", style: ts24CFFW400),
                SvgPicture.asset(
                  AppAssets.createIcon,
                  colorFilter: ColorFilter.mode(colorFFF, BlendMode.srcIn),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
