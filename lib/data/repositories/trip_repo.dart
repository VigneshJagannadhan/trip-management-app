import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trippify/core/errors/app_exception.dart';
import 'package:trippify/data/models/trip_model.dart';

abstract class TripRepo {
  Future<DocumentReference> createTrip({
    required String name,
    required String location,
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
}

class TripRepoImpl extends TripRepo {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<DocumentReference> createTrip({
    required String name,
    required String location,
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
        'startTime': startTime,
        'endTime': endTime,
        'creatorId': currentUser.uid,
        'members': [currentUser.uid],
        if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore.collection('trips').add(tripData);
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
}
