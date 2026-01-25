import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? linkedInUrl;
  final String? profileImageUrl;
  final List<String> enrolledCourses;
  final int certificatesCount;
  final int applicationsCount;
  final DateTime createdAt;

  UserModel({
    required this.userId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.linkedInUrl,
    this.profileImageUrl,
    this.enrolledCourses = const [],
    this.certificatesCount = 0,
    this.applicationsCount = 0,
    required this.createdAt,
  });

  // Factory constructor to create UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      userId: doc.id,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'],
      linkedInUrl: data['linkedInUrl'],
      profileImageUrl: data['profileImageUrl'],
      enrolledCourses: List<String>.from(data['enrolledCourses'] ?? []),
      certificatesCount: data['certificatesCount'] ?? 0,
      applicationsCount: data['applicationsCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Factory constructor to create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      linkedInUrl: json['linkedInUrl'],
      profileImageUrl: json['profileImageUrl'],
      enrolledCourses: List<String>.from(json['enrolledCourses'] ?? []),
      certificatesCount: json['certificatesCount'] ?? 0,
      applicationsCount: json['applicationsCount'] ?? 0,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt']),
    );
  }

  // Convert UserModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'linkedInUrl': linkedInUrl,
      'profileImageUrl': profileImageUrl,
      'enrolledCourses': enrolledCourses,
      'certificatesCount': certificatesCount,
      'applicationsCount': applicationsCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Convert UserModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'linkedInUrl': linkedInUrl,
      'profileImageUrl': profileImageUrl,
      'enrolledCourses': enrolledCourses,
      'certificatesCount': certificatesCount,
      'applicationsCount': applicationsCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create a copy with updated fields
  UserModel copyWith({
    String? userId,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? linkedInUrl,
    String? profileImageUrl,
    List<String>? enrolledCourses,
    int? certificatesCount,
    int? applicationsCount,
    DateTime? createdAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      linkedInUrl: linkedInUrl ?? this.linkedInUrl,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      enrolledCourses: enrolledCourses ?? this.enrolledCourses,
      certificatesCount: certificatesCount ?? this.certificatesCount,
      applicationsCount: applicationsCount ?? this.applicationsCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
