import 'package:cloud_firestore/cloud_firestore.dart';

class AdminStatisticsModel {
  final String statisticsId;
  final int totalUsers;
  final int totalCourses;
  final int totalInternships;
  final int totalApplications;
  final int totalEnrollments;
  final int pendingApplications;
  final int approvedApplications;
  final int rejectedApplications;
  final int activeInterns;
  final int completedCourses;
  final DateTime timestamp;
  final List<EnrollmentTrendData> enrollmentTrend;

  AdminStatisticsModel({
    required this.statisticsId,
    required this.totalUsers,
    required this.totalCourses,
    required this.totalInternships,
    required this.totalApplications,
    required this.totalEnrollments,
    required this.pendingApplications,
    required this.approvedApplications,
    required this.rejectedApplications,
    required this.activeInterns,
    required this.completedCourses,
    required this.timestamp,
    required this.enrollmentTrend,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'statisticsId': statisticsId,
      'totalUsers': totalUsers,
      'totalCourses': totalCourses,
      'totalInternships': totalInternships,
      'totalApplications': totalApplications,
      'totalEnrollments': totalEnrollments,
      'pendingApplications': pendingApplications,
      'approvedApplications': approvedApplications,
      'rejectedApplications': rejectedApplications,
      'activeInterns': activeInterns,
      'completedCourses': completedCourses,
      'timestamp': Timestamp.fromDate(timestamp),
      'enrollmentTrend': enrollmentTrend.map((e) => e.toJson()).toList(),
    };
  }

  // Create from Firestore document
  factory AdminStatisticsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final trendList = (data['enrollmentTrend'] as List<dynamic>?)
        ?.map((item) => EnrollmentTrendData.fromJson(item as Map<String, dynamic>))
        .toList() ??
        [];

    return AdminStatisticsModel(
      statisticsId: data['statisticsId'] ?? '',
      totalUsers: data['totalUsers'] ?? 0,
      totalCourses: data['totalCourses'] ?? 0,
      totalInternships: data['totalInternships'] ?? 0,
      totalApplications: data['totalApplications'] ?? 0,
      totalEnrollments: data['totalEnrollments'] ?? 0,
      pendingApplications: data['pendingApplications'] ?? 0,
      approvedApplications: data['approvedApplications'] ?? 0,
      rejectedApplications: data['rejectedApplications'] ?? 0,
      activeInterns: data['activeInterns'] ?? 0,
      completedCourses: data['completedCourses'] ?? 0,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      enrollmentTrend: trendList,
    );
  }

  @override
  String toString() =>
      'AdminStatisticsModel(totalUsers: $totalUsers, totalEnrollments: $totalEnrollments, totalApplications: $totalApplications)';
}

class EnrollmentTrendData {
  final String month;
  final int enrollments;
  final DateTime date;

  EnrollmentTrendData({
    required this.month,
    required this.enrollments,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'enrollments': enrollments,
      'date': Timestamp.fromDate(date),
    };
  }

  factory EnrollmentTrendData.fromJson(Map<String, dynamic> json) {
    return EnrollmentTrendData(
      month: json['month'] ?? '',
      enrollments: json['enrollments'] ?? 0,
      date: (json['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
