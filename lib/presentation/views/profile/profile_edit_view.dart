import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:trippify/core/theme/app_colors.dart';
import 'package:trippify/data/models/user_model.dart';
import 'package:trippify/presentation/viewmodels/user_viewmodel.dart';
import 'package:trippify/presentation/widgets/primary_button.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileEditView extends StatefulWidget {
  static const String route = '/profile-edit';

  const ProfileEditView({super.key});

  @override
  State<ProfileEditView> createState() => _ProfileEditViewState();
}

class _ProfileEditViewState extends State<ProfileEditView> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool isLoading = true;
  UserModel? currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      log('No Firebase user found');
      return;
    }

    log('Firebase user UID: ${firebaseUser.uid}');
    log('Firebase user email: ${firebaseUser.email}');

    final userVM = Provider.of<UserViewmodel>(context, listen: false);
    await userVM.fetchCurrentUser();

    if (!mounted) return;

    UserModel? loadedUser = userVM.currentUser;
    log('Loaded user from Firestore: ${loadedUser?.displayName}');

    if (loadedUser == null) {
      log('No user in Firestore, creating default');
      loadedUser = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? 'User',
        photoUrl: firebaseUser.photoURL,
      );
    }

    if (mounted) {
      setState(() {
        currentUser = loadedUser;
        displayNameController.text = currentUser!.displayName;
        phoneController.text = currentUser!.phoneNumber ?? '';
        isLoading = false;
      });
      log('Profile loaded - Display name: ${currentUser!.displayName}');
    }
  }

  @override
  void dispose() {
    displayNameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!formKey.currentState!.validate()) return;
    if (currentUser == null) return;

    final updatedUser = UserModel(
      uid: currentUser!.uid,
      email: currentUser!.email,
      displayName: displayNameController.text.trim(),
      phoneNumber:
          phoneController.text.trim().isEmpty
              ? null
              : phoneController.text.trim(),
      photoUrl: currentUser!.photoUrl,
      createdAt: currentUser!.createdAt ?? DateTime.now(),
    );

    final userVM = Provider.of<UserViewmodel>(context, listen: false);
    final success = await userVM.updateUser(
      context: context,
      user: updatedUser,
    );

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
              : SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 20.h),
                      // Profile Picture
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 60.r,
                            backgroundColor: neutral700,
                            backgroundImage:
                                currentUser?.photoUrl != null
                                    ? NetworkImage(currentUser!.photoUrl!)
                                    : null,
                            child:
                                currentUser?.photoUrl == null
                                    ? Icon(
                                      Icons.person,
                                      size: 60.r,
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                    )
                                    : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: secondaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: primaryColor,
                                  width: 3,
                                ),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20.r,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32.h),

                      // Email (read-only)
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: neutral800,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.email,
                              color: Colors.white.withValues(alpha: 0.6),
                              size: 20.r,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Email',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.white.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    currentUser?.email ?? '',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: accentTeal.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                'Verified',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: accentTeal,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Display Name
                      TextFormField(
                        controller: displayNameController,
                        decoration: const InputDecoration(
                          labelText: 'Display Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20.h),

                      // Phone Number
                      TextFormField(
                        controller: phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number (Optional)',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 32.h),

                      // Save Button
                      Consumer<UserViewmodel>(
                        builder: (context, userVM, child) {
                          return PrimaryButton(
                            label: 'Save Changes',
                            onTap: _saveProfile,
                            isLoading: userVM.isLoading,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
