import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityLogModel {
  final String activityId;
  final String userId;
  final String userName;
  final String action; // 'signup', 'enrolled_course', 'applied_internship', 'completed_course'
  final String type; // 'user_signup', 'course_enrollment', 'internship_application', 'course_completion'
  final String? description; // Optional detailed description
  final DateTime timestamp;

  ActivityLogModel({
    required this.activityId,
    required this.userId,
    required this.userName,
    required this.action,
    required this.type,
    this.description,
    required this.timestamp,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'activityId': activityId,
      'userId': userId,
      'userName': userName,
      'action': action,
      'type': type,
      'description': description,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  // Create from Firestore document
  factory ActivityLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActivityLogModel(
      activityId: data['activityId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown User',
      action: data['action'] ?? '',
      type: data['type'] ?? '',
      description: data['description'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Copy with method for immutability
  ActivityLogModel copyWith({
    String? activityId,
    String? userId,
    String? userName,
    String? action,
    String? type,
    String? description,
    DateTime? timestamp,
  }) {
    return ActivityLogModel(
      activityId: activityId ?? this.activityId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      action: action ?? this.action,
      type: type ?? this.type,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() => 'ActivityLogModel(activityId: $activityId, action: $action, type: $type, timestamp: $timestamp)';
}
