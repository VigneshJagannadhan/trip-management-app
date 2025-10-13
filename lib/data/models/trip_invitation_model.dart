import 'package:cloud_firestore/cloud_firestore.dart';

enum TripInvitationStatus { pending, accepted, rejected }

class TripInvitationModel {
  final String id;
  final String tripId;
  final String senderId;
  final String receiverId;
  final TripInvitationStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TripInvitationModel({
    required this.id,
    required this.tripId,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory TripInvitationModel.fromMap(Map<String, dynamic> map, String docId) {
    return TripInvitationModel(
      id: docId,
      tripId: map['tripId'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      status: _statusFromString(map['status'] ?? 'pending'),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt:
          map['updatedAt'] != null
              ? (map['updatedAt'] as Timestamp).toDate()
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tripId': tripId,
      'senderId': senderId,
      'receiverId': receiverId,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  static TripInvitationStatus _statusFromString(String status) {
    switch (status) {
      case 'accepted':
        return TripInvitationStatus.accepted;
      case 'rejected':
        return TripInvitationStatus.rejected;
      default:
        return TripInvitationStatus.pending;
    }
  }
}
