import 'package:cloud_firestore/cloud_firestore.dart';

enum FriendRequestStatus { pending, accepted, rejected }

class FriendRequestModel {
  final String id;
  final String senderId;
  final String receiverId;
  final FriendRequestStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  FriendRequestModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory FriendRequestModel.fromMap(Map<String, dynamic> map, String docId) {
    return FriendRequestModel(
      id: docId,
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
      'senderId': senderId,
      'receiverId': receiverId,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  static FriendRequestStatus _statusFromString(String status) {
    switch (status) {
      case 'accepted':
        return FriendRequestStatus.accepted;
      case 'rejected':
        return FriendRequestStatus.rejected;
      default:
        return FriendRequestStatus.pending;
    }
  }
}
