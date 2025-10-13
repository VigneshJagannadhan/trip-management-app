import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:trippify/core/theme/app_styles.dart';
import 'package:trippify/core/utils/app_validators.dart';
import 'package:trippify/presentation/viewmodels/auth_viewmodel.dart';
import 'package:trippify/presentation/views/auth/login_view.dart';
import 'package:trippify/presentation/views/home/home_view_tab.dart';
import 'package:trippify/presentation/widgets/custom_text_form_field.dart';
import 'package:trippify/presentation/widgets/primary_button.dart';
import 'package:trippify/presentation/widgets/snackbars/general_error_snackbar.dart';

class RegisterView extends StatelessWidget {
  static const String route = '/register';
  RegisterView({super.key});

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController(
    text: "Vignesh K",
  );
  TextEditingController nickNameController = TextEditingController(
    text: "Test",
  );
  TextEditingController emailController = TextEditingController(
    text: "vignesh@gmail.com",
  );
  TextEditingController passwordController = TextEditingController(
    text: "Abcd@1234",
  );
  TextEditingController confirmPasswordController = TextEditingController(
    text: "Abcd@1234",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Text("Create your Trippify Account", style: ts24CFFW400),
              SizedBox(height: 20.h),

              /// FULL NAME
              CustomTextFormField(
                label: "Full name",
                controller: nameController,
                validator: validateName,
              ),
              SizedBox(height: 20.h),
              CustomTextFormField(
                label: "Nick name (Optional)",
                controller: nickNameController,
              ),
              SizedBox(height: 20.h),
              CustomTextFormField(
                label: "Email",
                controller: emailController,
                validator: validateEmail,
              ),
              SizedBox(height: 20.h),
              CustomTextFormField(
                controller: passwordController,
                label: "Password",
                validator: validatePasswordRegistration,
              ),
              SizedBox(height: 20.h),
              CustomTextFormField(
                label: "Confirm Password",
                controller: confirmPasswordController,
                validator: validatePasswordRegistration,
              ),
              SizedBox(height: 20.h),
              Consumer<AuthViewmodel>(
                builder: (context, authVM, _) {
                  return PrimaryButton(
                    isLoading: authVM.isLoading,
                    label: "Create Account",
                    onTap: () async {
                      if (formKey.currentState!.validate()) {
                        var result = await authVM.signUp(
                          context: context,
                          name: nameController.text,
                          nickName: nickNameController.text,
                          email: emailController.text,
                          password: passwordController.text,
                        );

                        if (result) {
                          showGeneralSuccessSnackbar(
                            message: "Account created sucessfully",
                            context: context,
                          );
                          Navigator.pushReplacementNamed(
                            context,
                            HomeViewTab.route,
                          );
                        }
                      }
                    },
                  );
                },
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap:
                        () => Navigator.pushReplacementNamed(
                          context,
                          LoginView.route,
                        ),
                    child: Text(
                      "Already have an account?",
                      style: ts12CFFFW700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
