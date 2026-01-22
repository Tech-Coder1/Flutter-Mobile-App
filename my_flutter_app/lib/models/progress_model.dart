import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressModel {
  final String progressId;
  final String userId;
  final String courseId;
  final int completionPercentage; // 0-100
  final int videosWatched;
  final int totalVideos;
  final DateTime? lastAccessedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  ProgressModel({
    required this.progressId,
    required this.userId,
    required this.courseId,
    this.completionPercentage = 0,
    this.videosWatched = 0,
    this.totalVideos = 0,
    this.lastAccessedAt,
    this.startedAt,
    this.completedAt,
  });

  factory ProgressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProgressModel(
      progressId: doc.id,
      userId: data['userId'] ?? '',
      courseId: data['courseId'] ?? '',
      completionPercentage: data['completionPercentage'] ?? 0,
      videosWatched: data['videosWatched'] ?? 0,
      totalVideos: data['totalVideos'] ?? 0,
      lastAccessedAt: (data['lastAccessedAt'] as Timestamp?)?.toDate(),
      startedAt: (data['startedAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      progressId: json['progressId'] ?? '',
      userId: json['userId'] ?? '',
      courseId: json['courseId'] ?? '',
      completionPercentage: json['completionPercentage'] ?? 0,
      videosWatched: json['videosWatched'] ?? 0,
      totalVideos: json['totalVideos'] ?? 0,
      lastAccessedAt: json['lastAccessedAt'] is Timestamp
          ? (json['lastAccessedAt'] as Timestamp).toDate()
          : (json['lastAccessedAt'] != null
              ? DateTime.tryParse(json['lastAccessedAt'])
              : null),
      startedAt: json['startedAt'] is Timestamp
          ? (json['startedAt'] as Timestamp).toDate()
          : (json['startedAt'] != null
              ? DateTime.tryParse(json['startedAt'])
              : null),
      completedAt: json['completedAt'] is Timestamp
          ? (json['completedAt'] as Timestamp).toDate()
          : (json['completedAt'] != null
              ? DateTime.tryParse(json['completedAt'])
              : null),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'courseId': courseId,
      'completionPercentage': completionPercentage,
      'videosWatched': videosWatched,
      'totalVideos': totalVideos,
      'lastAccessedAt': lastAccessedAt != null ? Timestamp.fromDate(lastAccessedAt!) : null,
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  ProgressModel copyWith({
    String? progressId,
    String? userId,
    String? courseId,
    int? completionPercentage,
    int? videosWatched,
    int? totalVideos,
    DateTime? lastAccessedAt,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return ProgressModel(
      progressId: progressId ?? this.progressId,
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      videosWatched: videosWatched ?? this.videosWatched,
      totalVideos: totalVideos ?? this.totalVideos,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
