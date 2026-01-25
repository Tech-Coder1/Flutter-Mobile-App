import 'package:cloud_firestore/cloud_firestore.dart';

class CertificateModel {
  final String certificateId;
  final String userId;
  final String courseId;
  final String courseTitle;
  final String userName;
  final DateTime issuedDate;
  final String certificateUrl; // Optional: link to generated PDF
  final double completionScore; // Optional: score achieved

  CertificateModel({
    required this.certificateId,
    required this.userId,
    required this.courseId,
    required this.courseTitle,
    required this.userName,
    required this.issuedDate,
    this.certificateUrl = '',
    this.completionScore = 0.0,
  });

  factory CertificateModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CertificateModel(
      certificateId: doc.id,
      userId: data['userId'] ?? '',
      courseId: data['courseId'] ?? '',
      courseTitle: data['courseTitle'] ?? '',
      userName: data['userName'] ?? '',
      issuedDate: (data['issuedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      certificateUrl: data['certificateUrl'] ?? '',
      completionScore: (data['completionScore'] ?? 0.0).toDouble(),
    );
  }

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    return CertificateModel(
      certificateId: json['certificateId'] ?? '',
      userId: json['userId'] ?? '',
      courseId: json['courseId'] ?? '',
      courseTitle: json['courseTitle'] ?? '',
      userName: json['userName'] ?? '',
      issuedDate: json['issuedDate'] is Timestamp
          ? (json['issuedDate'] as Timestamp).toDate()
          : DateTime.parse(json['issuedDate'] ?? DateTime.now().toIso8601String()),
      certificateUrl: json['certificateUrl'] ?? '',
      completionScore: (json['completionScore'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'certificateId': certificateId,
      'userId': userId,
      'courseId': courseId,
      'courseTitle': courseTitle,
      'userName': userName,
      'issuedDate': Timestamp.fromDate(issuedDate),
      'certificateUrl': certificateUrl,
      'completionScore': completionScore,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'certificateId': certificateId,
      'userId': userId,
      'courseId': courseId,
      'courseTitle': courseTitle,
      'userName': userName,
      'issuedDate': issuedDate.toIso8601String(),
      'certificateUrl': certificateUrl,
      'completionScore': completionScore,
    };
  }

  CertificateModel copyWith({
    String? certificateId,
    String? userId,
    String? courseId,
    String? courseTitle,
    String? userName,
    DateTime? issuedDate,
    String? certificateUrl,
    double? completionScore,
  }) {
    return CertificateModel(
      certificateId: certificateId ?? this.certificateId,
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      courseTitle: courseTitle ?? this.courseTitle,
      userName: userName ?? this.userName,
      issuedDate: issuedDate ?? this.issuedDate,
      certificateUrl: certificateUrl ?? this.certificateUrl,
      completionScore: completionScore ?? this.completionScore,
    );
  }
}
