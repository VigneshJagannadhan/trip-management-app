import 'package:cloud_firestore/cloud_firestore.dart';

class ChatroomModel {
  final String id;
  final String tripId;
  final String adminId;
  final List<String> members;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final DateTime createdAt;

  ChatroomModel({
    required this.id,
    required this.tripId,
    required this.adminId,
    required this.members,
    this.lastMessage,
    this.lastMessageTime,
    required this.createdAt,
  });

  factory ChatroomModel.fromMap(Map<String, dynamic> map, String docId) {
    return ChatroomModel(
      id: docId,
      tripId: map['tripId'] ?? '',
      adminId: map['adminId'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      lastMessage: map['lastMessage'],
      lastMessageTime:
          map['lastMessageTime'] != null
              ? (map['lastMessageTime'] as Timestamp).toDate()
              : null,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tripId': tripId,
      'adminId': adminId,
      'members': members,
      if (lastMessage != null) 'lastMessage': lastMessage,
      if (lastMessageTime != null)
        'lastMessageTime': Timestamp.fromDate(lastMessageTime!),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
