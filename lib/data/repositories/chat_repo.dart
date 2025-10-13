import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trippify/core/errors/app_exception.dart';
import 'package:trippify/data/models/chat_message_model.dart';
import 'package:trippify/data/models/chatroom_model.dart';

abstract class ChatRepo {
  Future<String> createChatroom({
    required String tripId,
    required String adminId,
    required List<String> members,
  });
  Future<ChatroomModel?> getChatroomByTripId({required String tripId});
  Future<void> addMemberToChatroom({
    required String chatroomId,
    required String userId,
  });
  Future<void> sendMessage({
    required String chatroomId,
    required String message,
  });
  Stream<List<ChatMessageModel>> getMessages({required String chatroomId});
}

class ChatRepoImpl extends ChatRepo {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<String> createChatroom({
    required String tripId,
    required String adminId,
    required List<String> members,
  }) async {
    try {
      final docRef = await _firestore.collection('chatrooms').add({
        'tripId': tripId,
        'adminId': adminId,
        'members': members,
        'createdAt': FieldValue.serverTimestamp(),
      });

      log('Chatroom created: ${docRef.id} for trip: $tripId');
      return docRef.id;
    } catch (e, st) {
      log('CreateChatroom error: $e\n$st');
      throw FetchDataException('Failed to create chatroom.');
    }
  }

  @override
  Future<ChatroomModel?> getChatroomByTripId({required String tripId}) async {
    try {
      final snapshot =
          await _firestore
              .collection('chatrooms')
              .where('tripId', isEqualTo: tripId)
              .limit(1)
              .get();

      if (snapshot.docs.isEmpty) {
        log('No chatroom found for trip: $tripId');
        return null;
      }

      return ChatroomModel.fromMap(
        snapshot.docs.first.data(),
        snapshot.docs.first.id,
      );
    } catch (e) {
      log('GetChatroomByTripId error: $e');
      throw FetchDataException('Failed to fetch chatroom: $e');
    }
  }

  @override
  Future<void> addMemberToChatroom({
    required String chatroomId,
    required String userId,
  }) async {
    try {
      await _firestore.collection('chatrooms').doc(chatroomId).update({
        'members': FieldValue.arrayUnion([userId]),
      });
      log('Added user $userId to chatroom $chatroomId');
    } catch (e, st) {
      log('AddMemberToChatroom error: $e\n$st');
      throw FetchDataException('Failed to add member to chatroom.');
    }
  }

  @override
  Future<void> sendMessage({
    required String chatroomId,
    required String message,
  }) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw FetchDataException('User not logged in.');
      }

      final messageData = {
        'chatroomId': chatroomId,
        'senderId': currentUser.uid,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      };

      await _firestore.collection('messages').add(messageData);

      // Update chatroom last message
      await _firestore.collection('chatrooms').doc(chatroomId).update({
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      log('SendMessage error: $e\n$st');
      if (e is AppException) rethrow;
      throw FetchDataException('Failed to send message.');
    }
  }

  @override
  Stream<List<ChatMessageModel>> getMessages({required String chatroomId}) {
    return _firestore
        .collection('messages')
        .where('chatroomId', isEqualTo: chatroomId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ChatMessageModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }
}
