import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trippify/core/errors/app_exception.dart';
import 'package:trippify/data/models/user_model.dart';

abstract class UserRepo {
  Future<UserModel?> getUserById({required String userId});
  Future<void> updateUser({required UserModel user});
  Future<UserModel?> getCurrentUser();
}

class UserRepoImpl extends UserRepo {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<UserModel?> getUserById({required String userId}) async {
    try {
      log('Fetching user from Firestore: $userId');
      final doc = await _firestore.collection('users').doc(userId).get();
      log('User doc exists: ${doc.exists}');
      if (doc.exists) {
        log('User data: ${doc.data()}');
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      log('User document not found for: $userId');
      return null;
    } catch (e) {
      log('GetUserById error: $e');
      throw FetchDataException('Failed to fetch user: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) return null;

      return await getUserById(userId: currentUser.uid);
    } catch (e) {
      log('GetCurrentUser error: $e');
      return null;
    }
  }

  @override
  Future<void> updateUser({required UserModel user}) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw FetchDataException('User not logged in.');
      }

      if (currentUser.uid != user.uid) {
        throw FetchDataException('You can only update your own profile.');
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(user.toMap(), SetOptions(merge: true));
    } catch (e, st) {
      log('UpdateUser error: $e\n$st');
      if (e is AppException) rethrow;
      throw FetchDataException('Failed to update user.');
    }
  }
}
