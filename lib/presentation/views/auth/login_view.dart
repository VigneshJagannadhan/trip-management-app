import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:trippify/core/theme/app_styles.dart';
import 'package:trippify/core/utils/app_validators.dart';
import 'package:trippify/presentation/viewmodels/auth_viewmodel.dart';
import 'package:trippify/presentation/views/auth/register_view.dart';
import 'package:trippify/presentation/views/home/bottom_nav_view.dart';
import 'package:trippify/presentation/widgets/custom_text_form_field.dart';
import 'package:trippify/presentation/widgets/primary_button.dart';

class LoginView extends StatelessWidget {
  static const String route = '/login';
  LoginView({super.key});

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController(
    text: "vignesh@gmail.com",
  );
  TextEditingController passwordController = TextEditingController(
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
              Text("Login to Trippify", style: ts24CFFW400),
              SizedBox(height: 20.h),
              CustomTextFormField(
                controller: emailController,
                label: "Email",
                validator: validateEmail,
              ),
              SizedBox(height: 20.h),
              CustomTextFormField(
                controller: passwordController,
                label: "Password",
                validator: validatePasswordLogin,
              ),
              SizedBox(height: 20.h),
              Consumer<AuthViewmodel>(
                builder: (context, authVM, _) {
                  return PrimaryButton(
                    isLoading: authVM.isLoading,
                    label: "Login",
                    onTap: () async {
                      if (formKey.currentState!.validate()) {
                        var result = await authVM.signIn(
                          context: context,
                          email: emailController.text,
                          password: passwordController.text,
                        );

                        if (result) {
                          Navigator.pushReplacementNamed(
                            context,
                            HomeView.route,
                          );
                        }
                      }
                    },
                  );
                },
              ),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Forgot Password?", style: ts12CFFFW700),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(
                        context,
                        RegisterView.route,
                      );
                    },
                    child: Text("Don't have an account?", style: ts12CFFFW700),
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
