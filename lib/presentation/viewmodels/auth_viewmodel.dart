import 'package:flutter/material.dart';
import 'package:trippify/core/errors/app_exception.dart';
import 'package:trippify/data/repositories/auth_repo.dart';
import 'package:trippify/presentation/viewmodels/base_viewmodel.dart';
import 'package:trippify/presentation/widgets/snackbars/general_error_snackbar.dart';

class AuthViewmodel extends BaseViewmodel {
  final AuthRepo authRepo;

  AuthViewmodel({required this.authRepo});

  Future<bool> signUp({
    required BuildContext context,
    required String name,
    required String nickName,
    required String email,
    required String password,
  }) async {
    try {
      isLoading = true;
      var response = await authRepo.signUp(
        email: email,
        password: password,
        name: name,
        nickName: nickName,
      );
      isLoading = false;

      if (response != null) {
        return true;
      } else {
        return false;
      }
    } on AppException catch (e) {
      showGeneralErrorSnackbar(message: e.message, context: context);
      return false;
    } finally {
      isLoading = false;
    }
  }

  Future<bool> signIn({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      isLoading = true;
      var response = await authRepo.signIn(email: email, password: password);
      isLoading = false;

      if (response != null) {
        return true;
      } else {
        return false;
      }
    } on AppException catch (e) {
      showGeneralErrorSnackbar(message: e.message, context: context);
      return false;
    } finally {
      isLoading = false;
    }
  }
}
