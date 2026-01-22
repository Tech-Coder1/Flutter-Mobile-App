import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationModel {
  final String applicationId;
  final String userId;
  final String internshipId;
  final String fullName;
  final String email;
  final String phone;
  final String linkedInUrl;
  final String skillsExperience;
  final String resumeUrl;
  final String resumeFileName;
  final String status;
  final DateTime submittedAt;

  ApplicationModel({
    required this.applicationId,
    required this.userId,
    required this.internshipId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.linkedInUrl,
    required this.skillsExperience,
    this.resumeUrl = '',
    this.resumeFileName = '',
    this.status = 'pending',
    required this.submittedAt,
  });

  // Factory constructor to create ApplicationModel from Firestore document
  factory ApplicationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ApplicationModel(
      applicationId: doc.id,
      userId: data['userId'] ?? '',
      internshipId: data['internshipId'] ?? '',
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      linkedInUrl: data['linkedInUrl'] ?? '',
      skillsExperience: data['skillsExperience'] ?? '',
      resumeUrl: data['resumeUrl'] ?? '',
      resumeFileName: data['resumeFileName'] ?? '',
      status: data['status'] ?? 'pending',
      submittedAt: (data['submittedAt'] as Timestamp).toDate(),
    );
  }

  // Factory constructor to create ApplicationModel from JSON
  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      applicationId: json['applicationId'] ?? '',
      userId: json['userId'] ?? '',
      internshipId: json['internshipId'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      linkedInUrl: json['linkedInUrl'] ?? '',
      skillsExperience: json['skillsExperience'] ?? '',
      resumeUrl: json['resumeUrl'] ?? '',
      resumeFileName: json['resumeFileName'] ?? '',
      status: json['status'] ?? 'pending',
      submittedAt: json['submittedAt'] is Timestamp
          ? (json['submittedAt'] as Timestamp).toDate()
          : DateTime.parse(json['submittedAt']),
    );
  }

  // Convert ApplicationModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'applicationId': applicationId,
      'userId': userId,
      'internshipId': internshipId,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'linkedInUrl': linkedInUrl,
      'skillsExperience': skillsExperience,
      'resumeUrl': resumeUrl,
      'resumeFileName': resumeFileName,
      'status': status,
      'submittedAt': Timestamp.fromDate(submittedAt),
    };
  }

  // Convert ApplicationModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'internshipId': internshipId,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'linkedInUrl': linkedInUrl,
      'skillsExperience': skillsExperience,
      'resumeUrl': resumeUrl,
      'resumeFileName': resumeFileName,
      'status': status,
      'submittedAt': Timestamp.fromDate(submittedAt),
    };
  }

  // Create a copy with updated fields
  ApplicationModel copyWith({
    String? applicationId,
    String? userId,
    String? internshipId,
    String? fullName,
    String? email,
    String? phone,
    String? linkedInUrl,
    String? skillsExperience,
    String? resumeUrl,
    String? resumeFileName,
    String? status,
    DateTime? submittedAt,
  }) {
    return ApplicationModel(
      applicationId: applicationId ?? this.applicationId,
      userId: userId ?? this.userId,
      internshipId: internshipId ?? this.internshipId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      linkedInUrl: linkedInUrl ?? this.linkedInUrl,
      skillsExperience: skillsExperience ?? this.skillsExperience,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      resumeFileName: resumeFileName ?? this.resumeFileName,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }
}
