import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:trippify/core/theme/app_colors.dart';
import 'package:trippify/presentation/views/auth/login_view.dart';
import 'package:trippify/presentation/views/profile/profile_edit_view.dart';
import 'package:trippify/presentation/views/subscription/subscription_view.dart';
import 'package:trippify/presentation/viewmodels/theme_viewmodel.dart';
import 'package:trippify/presentation/viewmodels/language_viewmodel.dart';
import 'package:trippify/presentation/widgets/primary_button.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  void _showLanguageDialog(BuildContext context, LanguageViewmodel langVM) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Language'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  langVM.supportedLanguages.map((lang) {
                    final isSelected = lang.locale == langVM.currentLocale;
                    return ListTile(
                      leading: Text(
                        lang.flag,
                        style: TextStyle(fontSize: 24.sp),
                      ),
                      title: Text(lang.name),
                      trailing:
                          isSelected
                              ? Icon(Icons.check_circle, color: secondaryColor)
                              : null,
                      selected: isSelected,
                      onTap: () {
                        langVM.changeLanguage(lang.locale);
                        Navigator.of(context).pop();
                      },
                    );
                  }).toList(),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 70.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Settings",
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.white : neutral900,
            ),
          ),
          SizedBox(height: 20.h),
          Consumer<ThemeViewmodel>(
            builder: (context, themeVM, child) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: neutral800,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: secondaryColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            themeVM.isDarkMode
                                ? Icons.dark_mode
                                : Icons.light_mode,
                            color: secondaryColor,
                            size: 20.r,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Theme Mode',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              themeVM.isDarkMode ? 'Dark Mode' : 'Light Mode',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Switch(
                      value: themeVM.isDarkMode,
                      onChanged: (value) => themeVM.toggleTheme(),
                      activeColor: secondaryColor,
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 20.h),

          // Language Selector
          Consumer<LanguageViewmodel>(
            builder: (context, langVM, child) {
              final currentLang = langVM.supportedLanguages.firstWhere(
                (lang) => lang.locale == langVM.currentLocale,
              );

              return GestureDetector(
                onTap: () {
                  _showLanguageDialog(context, langVM);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: neutral800,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: secondaryColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Icons.language,
                              color: secondaryColor,
                              size: 20.r,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Language',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${currentLang.flag} ${currentLang.name}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white.withValues(alpha: 0.5),
                        size: 16.r,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 20.h),
          PrimaryButton(
            label: "Profile",
            onTap: () async {
              Navigator.of(context).pushNamed(ProfileEditView.route);
            },
          ),
          SizedBox(height: 20.h),
          PrimaryButton(
            label: "Subscriptions",
            onTap: () async {
              Navigator.of(context).pushNamed(SubscriptionView.route);
            },
          ),
          SizedBox(height: 20.h),
          PrimaryButton(
            label: "Logout",
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed(LoginView.route);
            },
            backgroundColor: Colors.red,
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
