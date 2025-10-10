import 'package:cloud_firestore/cloud_firestore.dart';

class TripModel {
  final String id;
  final String name;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final String creatorId;
  final List<String> members;
  final String imageUrl;

  TripModel({
    required this.id,
    required this.name,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.creatorId,
    required this.members,
    required this.imageUrl,
  });

  /// Create TripModel from Firestore document
  factory TripModel.fromMap(Map<String, dynamic> map, String docId) {
    return TripModel(
      id: docId,
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
      creatorId: map['creatorId'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  /// Convert TripModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'creatorId': creatorId,
      'members': members,
      'imageUrl': imageUrl,
    };
  }
}
