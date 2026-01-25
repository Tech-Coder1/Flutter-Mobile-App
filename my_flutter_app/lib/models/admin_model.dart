import 'package:cloud_firestore/cloud_firestore.dart';

class AdminModel {
  final String adminId;
  final String email;
  final String role;
  final String? fullName;
  final DateTime createdAt;

  AdminModel({
    required this.adminId,
    required this.email,
    required this.role,
    this.fullName,
    required this.createdAt,
  });

  // Factory constructor to create AdminModel from Firestore document
  factory AdminModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AdminModel(
      adminId: doc.id,
      email: data['email'] ?? '',
      role: data['role'] ?? 'admin',
      fullName: data['fullName'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Factory constructor to create AdminModel from JSON
  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      adminId: json['adminId'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'],
      role: json['role'] ?? 'admin',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt']),
    );
  }

  // Convert AdminModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'adminId': adminId,
      'email': email,
      'role': role,
      'fullName': fullName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Convert AdminModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'role': role,
      if (fullName != null) 'fullName': fullName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create a copy with updated fields
  AdminModel copyWith({
    String? adminId,
    String? email,
    String? role,
    String? fullName,
    DateTime? createdAt,
  }) {
    return AdminModel(
      adminId: adminId ?? this.adminId,
      email: email ?? this.email,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
