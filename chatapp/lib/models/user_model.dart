import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime? lastSeen;
  final String status;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.lastSeen,
    required this.status,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      lastSeen: (map['lastSeen'] as Timestamp?)?.toDate(),
      status: map['status'] ?? 'offline',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'lastSeen': lastSeen,
      'status': status,
    };
  }
} 