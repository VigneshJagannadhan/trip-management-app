import 'package:flutter/material.dart';
import 'package:trippify/data/models/friend_request_model.dart';
import 'package:trippify/data/models/user_model.dart';
import 'package:trippify/data/repositories/friend_repo.dart';
import 'package:trippify/presentation/viewmodels/base_viewmodel.dart';
import 'package:trippify/core/errors/app_exception.dart';
import '../widgets/snackbars/general_error_snackbar.dart';

class FriendViewmodel extends BaseViewmodel {
  final FriendRepo friendRepo;

  FriendViewmodel({required this.friendRepo});

  List<UserModel> friends = [];
  List<FriendRequestModel> pendingRequests = [];
  List<UserModel> searchResults = [];

  Future<void> fetchFriends() async {
    try {
      isLoading = true;
      friends = await friendRepo.getFriends();
    } catch (e) {
      debugPrint('FetchFriends error: $e');
    } finally {
      isLoading = false;
    }
  }

  Future<void> fetchPendingRequests() async {
    try {
      pendingRequests = await friendRepo.getPendingRequests();
      notifyListeners();
    } catch (e) {
      debugPrint('FetchPendingRequests error: $e');
    }
  }

  Future<bool> sendFriendRequest({
    required BuildContext context,
    required String receiverId,
  }) async {
    try {
      await friendRepo.sendFriendRequest(receiverId: receiverId);
      showGeneralSuccessSnackbar(
        context: context,
        message: 'Friend request sent',
      );
      return true;
    } on AppException catch (e) {
      showGeneralErrorSnackbar(message: e.message, context: context);
      return false;
    } catch (e) {
      showGeneralErrorSnackbar(
        message: 'Failed to send friend request.',
        context: context,
      );
      return false;
    }
  }

  Future<bool> acceptFriendRequest({
    required BuildContext context,
    required String requestId,
  }) async {
    try {
      await friendRepo.acceptFriendRequest(requestId: requestId);

      // Remove from pending and refresh friends
      pendingRequests.removeWhere((req) => req.id == requestId);
      await fetchFriends();

      showGeneralSuccessSnackbar(
        context: context,
        message: 'Friend request accepted',
      );
      return true;
    } on AppException catch (e) {
      showGeneralErrorSnackbar(message: e.message, context: context);
      return false;
    } catch (e) {
      showGeneralErrorSnackbar(
        message: 'Failed to accept friend request.',
        context: context,
      );
      return false;
    }
  }

  Future<bool> rejectFriendRequest({
    required BuildContext context,
    required String requestId,
  }) async {
    try {
      await friendRepo.rejectFriendRequest(requestId: requestId);

      // Remove from pending
      pendingRequests.removeWhere((req) => req.id == requestId);
      notifyListeners();

      showGeneralSuccessSnackbar(
        context: context,
        message: 'Friend request rejected',
      );
      return true;
    } on AppException catch (e) {
      showGeneralErrorSnackbar(message: e.message, context: context);
      return false;
    } catch (e) {
      showGeneralErrorSnackbar(
        message: 'Failed to reject friend request.',
        context: context,
      );
      return false;
    }
  }

  Future<bool> removeFriend({
    required BuildContext context,
    required String friendId,
  }) async {
    try {
      await friendRepo.removeFriend(friendId: friendId);

      // Remove from local list
      friends.removeWhere((friend) => friend.uid == friendId);
      notifyListeners();

      showGeneralSuccessSnackbar(context: context, message: 'Friend removed');
      return true;
    } on AppException catch (e) {
      showGeneralErrorSnackbar(message: e.message, context: context);
      return false;
    } catch (e) {
      showGeneralErrorSnackbar(
        message: 'Failed to remove friend.',
        context: context,
      );
      return false;
    }
  }

  Future<void> searchUsers(String query) async {
    try {
      if (query.trim().isEmpty) {
        searchResults = [];
        notifyListeners();
        return;
      }

      searchResults = await friendRepo.searchUsers(query: query);
      notifyListeners();
    } catch (e) {
      debugPrint('SearchUsers error: $e');
      searchResults = [];
      notifyListeners();
    }
  }

  void clearSearch() {
    searchResults = [];
    notifyListeners();
  }
}
