import 'dart:ui';
import 'package:trippify/core/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trippify/presentation/views/home/create_trip_tab.dart';
import 'package:trippify/presentation/views/home/friends_tab.dart';
import 'package:trippify/presentation/views/home/home_view_tab.dart';
import 'package:trippify/presentation/views/home/settings_tab.dart';
import 'package:trippify/presentation/widgets/bottom_nav_icon.dart';

class HomeView extends StatefulWidget {
  static const String route = '/home';
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<Widget> tabs = [
    HomeViewTab(),
    CreateTripTab(),
    FriendsTab(),
    SettingsTab(),
  ];

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: tabs[currentIndex],
      bottomNavigationBar: AppBottomNav(
        currentIndex: currentIndex,
        onItemSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.white,
        border: Border.all(
          color:
              isDarkMode
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.3),
        ),
        boxShadow:
            isDarkMode
                ? null
                : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BottomNavIcon(
                svgIcon: AppAssets.homeIcon,
                isSelected: currentIndex == 0,
                onTap: () => onItemSelected(0),
              ),
              BottomNavIcon(
                svgIcon: AppAssets.createIcon,
                isSelected: currentIndex == 1,
                onTap: () => onItemSelected(1),
              ),
              BottomNavIcon(
                svgIcon: AppAssets.peopleIcon,
                isSelected: currentIndex == 2,
                onTap: () => onItemSelected(2),
              ),
              BottomNavIcon(
                svgIcon: AppAssets.settingsIcon,
                isSelected: currentIndex == 3,
                onTap: () => onItemSelected(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
