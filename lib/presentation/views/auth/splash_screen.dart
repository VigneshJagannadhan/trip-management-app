import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:trippify/core/constants/app_assets.dart';
import 'package:trippify/core/theme/app_styles.dart';
import 'package:trippify/presentation/views/auth/login_view.dart';
import 'package:flutter/material.dart';

class SplashView extends StatefulWidget {
  static const String route = '/';
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Trippify", style: ts24CFFW400),
            SizedBox(height: 20.h),
            SizedBox(
              height: 100.h,
              child: Lottie.asset(AppAssets.loadingLottie),
            ),
          ],
        ),
      ),
    );
  }

  void _initAsync() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      User? user = FirebaseAuth.instance.currentUser;
      await Future.delayed(Duration(seconds: 3));
      if (user != null) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed(LoginView.route);
      }
    });
  }
}
