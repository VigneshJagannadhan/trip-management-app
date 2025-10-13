import 'package:flutter/material.dart';
import 'package:trippify/data/models/user_model.dart';
import 'package:trippify/data/repositories/user_repo.dart';
import 'package:trippify/presentation/viewmodels/base_viewmodel.dart';
import 'package:trippify/core/errors/app_exception.dart';
import '../widgets/snackbars/general_error_snackbar.dart';

class UserViewmodel extends BaseViewmodel {
  final UserRepo userRepo;

  UserViewmodel({required this.userRepo});

  UserModel? currentUser;

  Future<void> fetchCurrentUser() async {
    try {
      currentUser = await userRepo.getCurrentUser();
      notifyListeners();
    } catch (e) {
      debugPrint('FetchCurrentUser error: $e');
    }
  }

  Future<UserModel?> fetchUserById({required String userId}) async {
    try {
      return await userRepo.getUserById(userId: userId);
    } catch (e) {
      debugPrint('FetchUserById error: $e');
      return null;
    }
  }

  Future<bool> updateUser({
    required BuildContext context,
    required UserModel user,
  }) async {
    try {
      isLoading = true;
      await userRepo.updateUser(user: user);
      currentUser = user;
      notifyListeners();

      showGeneralSuccessSnackbar(
        context: context,
        message: 'Profile updated successfully',
      );
      return true;
    } on AppException catch (e) {
      showGeneralErrorSnackbar(message: e.message, context: context);
      return false;
    } catch (e) {
      showGeneralErrorSnackbar(
        message: 'Unexpected error occurred.',
        context: context,
      );
      return false;
    } finally {
      isLoading = false;
    }
  }
}
