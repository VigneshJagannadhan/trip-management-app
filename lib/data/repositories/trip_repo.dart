import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trippify/core/errors/app_exception.dart';
import 'package:trippify/data/models/trip_model.dart';
import 'package:trippify/data/models/trip_invitation_model.dart';

abstract class TripRepo {
  Future<DocumentReference> createTrip({
    required String name,
    required String location,
    String? description,
    required DateTime startTime,
    required DateTime endTime,
    String? imageUrl,
  });

  Future<void> updateTrip({
    required String tripId,
    required String name,
    required String location,
    required DateTime startTime,
    required DateTime endTime,
  });

  Future<void> addUserToTrip({required String tripId, required String userId});

  Future<List<TripModel>> getTrips();
  Future<TripModel?> getTripById({required String tripId});
  Future<void> deleteTrip({required String tripId});

  // Trip Invitations
  Future<void> sendTripInvitation({
    required String tripId,
    required String receiverId,
  });
  Future<void> acceptTripInvitation({required String invitationId});
  Future<void> rejectTripInvitation({required String invitationId});
  Future<List<TripInvitationModel>> getPendingTripInvitations();
}

class TripRepoImpl extends TripRepo {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<DocumentReference> createTrip({
    required String name,
    required String location,
    String? description,
    required DateTime startTime,
    required DateTime endTime,
    String? imageUrl,
  }) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw FetchDataException('User not logged in.');
      }

      final tripData = {
        'name': name,
        'location': location,
        if (description != null && description.isNotEmpty)
          'description': description,
        'startTime': startTime,
        'endTime': endTime,
        'creatorId': currentUser.uid,
        'members': [currentUser.uid],
        if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore.collection('trips').add(tripData);

      try {
        await _firestore.collection('chatrooms').add({
          'tripId': docRef.id,
          'adminId': currentUser.uid,
          'members': [currentUser.uid],
          'createdAt': FieldValue.serverTimestamp(),
        });
        log('Chatroom auto-created for trip: ${docRef.id}');
      } catch (e) {
        log('Failed to create chatroom: $e');
      }

      return docRef;
    } catch (e, st) {
      log('CreateTrip error: $e\n$st');
      throw FetchDataException('Failed to create trip.');
    }
  }

  @override
  Future<void> updateTrip({
    required String tripId,
    required String name,
    required String location,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      await _firestore.collection('trips').doc(tripId).update({
        'name': name,
        'location': location,
        'startTime': startTime,
        'endTime': endTime,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      log('UpdateTrip error: $e\n$st');
      throw FetchDataException('Failed to update trip.');
    }
  }

  @override
  Future<void> addUserToTrip({
    required String tripId,
    required String userId,
  }) async {
    try {
      await _firestore.collection('trips').doc(tripId).update({
        'members': FieldValue.arrayUnion([userId]),
      });

      try {
        final chatroomSnapshot =
            await _firestore
                .collection('chatrooms')
                .where('tripId', isEqualTo: tripId)
                .limit(1)
                .get();

        if (chatroomSnapshot.docs.isNotEmpty) {
          await _firestore
              .collection('chatrooms')
              .doc(chatroomSnapshot.docs.first.id)
              .update({
                'members': FieldValue.arrayUnion([userId]),
              });
          log('Added user to chatroom for trip: $tripId');
        }
      } catch (e) {
        log('Failed to add user to chatroom: $e');
      }
    } catch (e, st) {
      log('AddUserToTrip error: $e\n$st');
      throw FetchDataException('Failed to add user to trip.');
    }
  }

  @override
  Future<List<TripModel>> getTrips() async {
    try {
      final snapshot = await _firestore.collection('trips').get();
      return snapshot.docs
          .map((doc) => TripModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw FetchDataException('Failed to fetch trips: $e');
    }
  }

  @override
  Future<TripModel?> getTripById({required String tripId}) async {
    try {
      final doc = await _firestore.collection('trips').doc(tripId).get();
      if (doc.exists) {
        return TripModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      log('GetTripById error: $e');
      throw FetchDataException('Failed to fetch trip: $e');
    }
  }

  @override
  Future<void> deleteTrip({required String tripId}) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw FetchDataException('User not logged in.');
      }

      // Get the trip to check if user is the creator
      final trip = await getTripById(tripId: tripId);
      if (trip == null) {
        throw FetchDataException('Trip not found.');
      }

      if (trip.creatorId != currentUser.uid) {
        throw FetchDataException('You can only delete trips you created.');
      }

      await _firestore.collection('trips').doc(tripId).delete();
    } catch (e, st) {
      log('DeleteTrip error: $e\n$st');
      if (e is AppException) rethrow;
      throw FetchDataException('Failed to delete trip.');
    }
  }

  @override
  Future<void> sendTripInvitation({
    required String tripId,
    required String receiverId,
  }) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw FetchDataException('User not logged in.');
      }

      // Check if user is trip creator
      final trip = await getTripById(tripId: tripId);
      if (trip == null) {
        throw FetchDataException('Trip not found.');
      }

      if (trip.creatorId != currentUser.uid) {
        throw UnauthorisedException('Only trip creator can send invitations.');
      }

      // Check if already a member
      if (trip.members.contains(receiverId)) {
        throw BadRequestException('User is already a member of this trip.');
      }

      // Check if invitation already exists
      final existing =
          await _firestore
              .collection('tripInvitations')
              .where('tripId', isEqualTo: tripId)
              .where('receiverId', isEqualTo: receiverId)
              .where('status', isEqualTo: 'pending')
              .get();

      if (existing.docs.isNotEmpty) {
        throw BadRequestException('Invitation already sent.');
      }

      await _firestore.collection('tripInvitations').add({
        'tripId': tripId,
        'senderId': currentUser.uid,
        'receiverId': receiverId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      log('Trip invitation sent to $receiverId for trip $tripId');
    } catch (e, st) {
      log('SendTripInvitation error: $e\n$st');
      if (e is AppException) rethrow;
      throw FetchDataException('Failed to send trip invitation.');
    }
  }

  @override
  Future<void> acceptTripInvitation({required String invitationId}) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw FetchDataException('User not logged in.');
      }

      final invDoc =
          await _firestore
              .collection('tripInvitations')
              .doc(invitationId)
              .get();

      if (!invDoc.exists) {
        throw FetchDataException('Invitation not found.');
      }

      final invitation = TripInvitationModel.fromMap(invDoc.data()!, invDoc.id);

      if (invitation.receiverId != currentUser.uid) {
        throw UnauthorisedException(
          'You can only accept invitations sent to you.',
        );
      }

      // Update invitation status
      await _firestore.collection('tripInvitations').doc(invitationId).update({
        'status': 'accepted',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Add user to trip (which also adds to chatroom)
      await addUserToTrip(tripId: invitation.tripId, userId: currentUser.uid);

      log('Trip invitation accepted: $invitationId');
    } catch (e, st) {
      log('AcceptTripInvitation error: $e\n$st');
      if (e is AppException) rethrow;
      throw FetchDataException('Failed to accept trip invitation.');
    }
  }

  @override
  Future<void> rejectTripInvitation({required String invitationId}) async {
    try {
      await _firestore.collection('tripInvitations').doc(invitationId).update({
        'status': 'rejected',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      log('Trip invitation rejected: $invitationId');
    } catch (e, st) {
      log('RejectTripInvitation error: $e\n$st');
      if (e is AppException) rethrow;
      throw FetchDataException('Failed to reject trip invitation.');
    }
  }

  @override
  Future<List<TripInvitationModel>> getPendingTripInvitations() async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) return [];

      final snapshot =
          await _firestore
              .collection('tripInvitations')
              .where('receiverId', isEqualTo: currentUser.uid)
              .where('status', isEqualTo: 'pending')
              .get();

      return snapshot.docs
          .map((doc) => TripInvitationModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      log('GetPendingTripInvitations error: $e');
      throw FetchDataException('Failed to fetch trip invitations: $e');
    }
  }
}
