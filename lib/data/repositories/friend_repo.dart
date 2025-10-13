import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trippify/core/errors/app_exception.dart';
import 'package:trippify/data/models/friend_request_model.dart';
import 'package:trippify/data/models/user_model.dart';

abstract class FriendRepo {
  Future<void> sendFriendRequest({required String receiverId});
  Future<void> acceptFriendRequest({required String requestId});
  Future<void> rejectFriendRequest({required String requestId});
  Future<void> removeFriend({required String friendId});
  Future<List<FriendRequestModel>> getPendingRequests();
  Future<List<UserModel>> getFriends();
  Future<List<UserModel>> searchUsers({required String query});
}

class FriendRepoImpl extends FriendRepo {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> sendFriendRequest({required String receiverId}) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw FetchDataException('User not logged in.');
      }

      if (currentUser.uid == receiverId) {
        throw InvalidInputException(
          'You cannot send a friend request to yourself.',
        );
      }

      // Check if request already exists
      final existingRequest =
          await _firestore
              .collection('friendRequests')
              .where('senderId', isEqualTo: currentUser.uid)
              .where('receiverId', isEqualTo: receiverId)
              .where('status', isEqualTo: 'pending')
              .get();

      if (existingRequest.docs.isNotEmpty) {
        throw BadRequestException('Friend request already sent.');
      }

      // Check if already friends
      final friendship =
          await _firestore
              .collection('friendships')
              .where('users', arrayContains: currentUser.uid)
              .get();

      for (var doc in friendship.docs) {
        final users = List<String>.from(doc.data()['users'] ?? []);
        if (users.contains(receiverId)) {
          throw BadRequestException('Already friends with this user.');
        }
      }

      final docRef = await _firestore.collection('friendRequests').add({
        'senderId': currentUser.uid,
        'receiverId': receiverId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      log('Friend request created: ${docRef.id}');
      log('From: ${currentUser.uid} To: $receiverId');
    } catch (e, st) {
      log('SendFriendRequest error: $e\n$st');
      if (e is AppException) rethrow;
      throw FetchDataException('Failed to send friend request.');
    }
  }

  @override
  Future<void> acceptFriendRequest({required String requestId}) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw FetchDataException('User not logged in.');
      }

      final requestDoc =
          await _firestore.collection('friendRequests').doc(requestId).get();

      if (!requestDoc.exists) {
        throw FetchDataException('Friend request not found.');
      }

      final request = FriendRequestModel.fromMap(
        requestDoc.data()!,
        requestDoc.id,
      );

      if (request.receiverId != currentUser.uid) {
        throw UnauthorisedException(
          'You can only accept requests sent to you.',
        );
      }

      // Update request status
      await _firestore.collection('friendRequests').doc(requestId).update({
        'status': 'accepted',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Create friendship
      await _firestore.collection('friendships').add({
        'users': [request.senderId, request.receiverId],
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      log('AcceptFriendRequest error: $e\n$st');
      if (e is AppException) rethrow;
      throw FetchDataException('Failed to accept friend request.');
    }
  }

  @override
  Future<void> rejectFriendRequest({required String requestId}) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw FetchDataException('User not logged in.');
      }

      await _firestore.collection('friendRequests').doc(requestId).update({
        'status': 'rejected',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      log('RejectFriendRequest error: $e\n$st');
      if (e is AppException) rethrow;
      throw FetchDataException('Failed to reject friend request.');
    }
  }

  @override
  Future<void> removeFriend({required String friendId}) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw FetchDataException('User not logged in.');
      }

      // Find and delete the friendship
      final friendships =
          await _firestore
              .collection('friendships')
              .where('users', arrayContains: currentUser.uid)
              .get();

      for (var doc in friendships.docs) {
        final users = List<String>.from(doc.data()['users'] ?? []);
        if (users.contains(friendId)) {
          await doc.reference.delete();
          break;
        }
      }
    } catch (e, st) {
      log('RemoveFriend error: $e\n$st');
      if (e is AppException) rethrow;
      throw FetchDataException('Failed to remove friend.');
    }
  }

  @override
  Future<List<FriendRequestModel>> getPendingRequests() async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        log('No current user for getPendingRequests');
        return [];
      }

      log('Fetching pending requests for user: ${currentUser.uid}');

      final snapshot =
          await _firestore
              .collection('friendRequests')
              .where('receiverId', isEqualTo: currentUser.uid)
              .where('status', isEqualTo: 'pending')
              .get();

      log('Found ${snapshot.docs.length} pending requests');

      final requests =
          snapshot.docs
              .map((doc) => FriendRequestModel.fromMap(doc.data(), doc.id))
              .toList();

      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      for (var doc in snapshot.docs) {
        log('Request: ${doc.id} - ${doc.data()}');
      }

      return requests;
    } catch (e) {
      log('GetPendingRequests error: $e');
      throw FetchDataException('Failed to fetch friend requests: $e');
    }
  }

  @override
  Future<List<UserModel>> getFriends() async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) return [];

      // Get all friendships
      final friendships =
          await _firestore
              .collection('friendships')
              .where('users', arrayContains: currentUser.uid)
              .get();

      // Extract friend IDs
      Set<String> friendIds = {};
      for (var doc in friendships.docs) {
        final users = List<String>.from(doc.data()['users'] ?? []);
        for (var userId in users) {
          if (userId != currentUser.uid) {
            friendIds.add(userId);
          }
        }
      }

      // Fetch user data for each friend
      List<UserModel> friends = [];
      for (var friendId in friendIds) {
        final userDoc =
            await _firestore.collection('users').doc(friendId).get();
        if (userDoc.exists) {
          friends.add(UserModel.fromMap(userDoc.data()!, userDoc.id));
        }
      }

      return friends;
    } catch (e) {
      log('GetFriends error: $e');
      throw FetchDataException('Failed to fetch friends: $e');
    }
  }

  @override
  Future<List<UserModel>> searchUsers({required String query}) async {
    try {
      if (query.trim().isEmpty) return [];

      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) return [];

      // Search by email or display name
      final snapshot =
          await _firestore
              .collection('users')
              .where('email', isGreaterThanOrEqualTo: query.toLowerCase())
              .where(
                'email',
                isLessThanOrEqualTo: '${query.toLowerCase()}\uf8ff',
              )
              .limit(10)
              .get();

      return snapshot.docs
          .where((doc) => doc.id != currentUser.uid)
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      log('SearchUsers error: $e');
      throw FetchDataException('Failed to search users: $e');
    }
  }
}
