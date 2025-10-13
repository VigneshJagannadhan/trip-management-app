import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    final displayName = map['displayName'] ?? map['name'] ?? '';

    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      displayName: displayName,
      photoUrl: map['photoUrl'],
      phoneNumber: map['phoneNumber'],
      createdAt:
          map['createdAt'] != null
              ? (map['createdAt'] as Timestamp).toDate()
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    };
  }
}
