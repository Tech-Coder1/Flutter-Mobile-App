import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel {
  final String courseId;
  final String title;
  final String duration;
  final String level;
  final String description;
  final int dailyLearningTime; // in hours
  final List<String> skills;
  final List<String> prerequisites;
  final List<String> syllabus;
  final String instructorName;
  final double rating;
  final List<String> enrolledUsers;
  final String createdBy;
  final DateTime createdAt;

  CourseModel({
    required this.courseId,
    required this.title,
    required this.duration,
    required this.level,
    required this.description,
    this.dailyLearningTime = 0,
    this.skills = const [],
    this.prerequisites = const [],
    this.syllabus = const [],
    this.instructorName = '',
    this.rating = 0.0,
    this.enrolledUsers = const [],
    required this.createdBy,
    required this.createdAt,
  });

  // Factory constructor to create CourseModel from Firestore document
  factory CourseModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CourseModel(
      courseId: doc.id,
      title: data['title'] ?? '',
      duration: data['duration'] ?? '',
      level: data['level'] ?? '',
      description: data['description'] ?? '',
      dailyLearningTime: data['dailyLearningTime'] ?? 0,
      skills: List<String>.from(data['skills'] ?? []),
      prerequisites: List<String>.from(data['prerequisites'] ?? []),
      syllabus: List<String>.from(data['syllabus'] ?? []),
      instructorName: data['instructorName'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      enrolledUsers: List<String>.from(data['enrolledUsers'] ?? []),
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Factory constructor to create CourseModel from JSON
  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      courseId: json['courseId'] ?? '',
      title: json['title'] ?? '',
      duration: json['duration'] ?? '',
      level: json['level'] ?? '',
      description: json['description'] ?? '',
      dailyLearningTime: json['dailyLearningTime'] ?? 0,
      skills: List<String>.from(json['skills'] ?? []),
      prerequisites: List<String>.from(json['prerequisites'] ?? []),
      syllabus: List<String>.from(json['syllabus'] ?? []),
      instructorName: json['instructorName'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      enrolledUsers: List<String>.from(json['enrolledUsers'] ?? []),
      createdBy: json['createdBy'] ?? '',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt']),
    );
  }

  // Convert CourseModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'title': title,
      'duration': duration,
      'level': level,
      'description': description,
      'dailyLearningTime': dailyLearningTime,
      'skills': skills,
      'prerequisites': prerequisites,
      'syllabus': syllabus,
      'instructorName': instructorName,
      'rating': rating,
      'enrolledUsers': enrolledUsers,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Convert CourseModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'duration': duration,
      'level': level,
      'description': description,
      'dailyLearningTime': dailyLearningTime,
      'skills': skills,
      'prerequisites': prerequisites,
      'syllabus': syllabus,
      'instructorName': instructorName,
      'rating': rating,
      'enrolledUsers': enrolledUsers,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create a copy with updated fields
  CourseModel copyWith({
    String? courseId,
    String? title,
    String? duration,
    String? level,
    String? description,
    int? dailyLearningTime,
    List<String>? skills,
    List<String>? prerequisites,
    List<String>? syllabus,
    String? instructorName,
    double? rating,
    List<String>? enrolledUsers,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return CourseModel(
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      duration: duration ?? this.duration,
      level: level ?? this.level,
      description: description ?? this.description,
      dailyLearningTime: dailyLearningTime ?? this.dailyLearningTime,
      skills: skills ?? this.skills,
      prerequisites: prerequisites ?? this.prerequisites,
      syllabus: syllabus ?? this.syllabus,
      instructorName: instructorName ?? this.instructorName,
      rating: rating ?? this.rating,
      enrolledUsers: enrolledUsers ?? this.enrolledUsers,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
