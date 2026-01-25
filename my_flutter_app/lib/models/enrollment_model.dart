import 'package:cloud_firestore/cloud_firestore.dart';

class EnrollmentModel {
  final String enrollmentId; // userId_courseId
  final String userId;
  final String courseId;
  final DateTime enrolledAt;

  EnrollmentModel({
    required this.enrollmentId,
    required this.userId,
    required this.courseId,
    required this.enrolledAt,
  });

  factory EnrollmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EnrollmentModel(
      enrollmentId: doc.id,
      userId: data['userId'] ?? '',
      courseId: data['courseId'] ?? '',
      enrolledAt: (data['enrolledAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'courseId': courseId,
      'enrolledAt': Timestamp.fromDate(enrolledAt),
    };
  }
}
