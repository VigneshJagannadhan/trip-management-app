import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trippify/core/theme/app_styles.dart';
import 'package:trippify/presentation/views/auth/login_view.dart';
import 'package:trippify/presentation/widgets/primary_button.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 50.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 50.h),
          Text("Settings", style: ts24CFFW400),
          SizedBox(height: 20.h),
          PrimaryButton(label: "Profile", onTap: () {}),
          SizedBox(height: 20.h),
          PrimaryButton(label: "Subscriptions", onTap: () {}),
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
