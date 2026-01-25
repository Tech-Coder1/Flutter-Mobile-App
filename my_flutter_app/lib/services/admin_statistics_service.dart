import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activity_log_model.dart';
import '../models/admin_statistics_model.dart';

class AdminStatisticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Track user activity - called whenever something important happens
  Future<void> trackUserAction({
    required String userId,
    required String userName,
    required String action,
    required String type,
    String? description,
  }) async {
    try {
      final activityId = _firestore.collection('activity_logs').doc().id;
      await _firestore.collection('activity_logs').doc(activityId).set({
        'activityId': activityId,
        'userId': userId,
        'userName': userName,
        'action': action,
        'type': type,
        'description': description,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('Error tracking user action: $e');
    }
  }

  // Get recent activity feed (real-time)
  Stream<List<ActivityLogModel>> getActivityLog({int limit = 50}) {
    return _firestore
        .collection('activity_logs')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ActivityLogModel.fromFirestore(doc)).toList();
    });
  }

  // Get total users count
  Future<int> getTotalUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.size;
    } catch (e) {
      debugPrint('Error getting total users: $e');
      return 0;
    }
  }

  // Get total courses count
  Future<int> getTotalCourses() async {
    try {
      final snapshot = await _firestore.collection('courses').get();
      return snapshot.size;
    } catch (e) {
      debugPrint('Error getting total courses: $e');
      return 0;
    }
  }

  // Get total internships count
  Future<int> getTotalInternships() async {
    try {
      final snapshot = await _firestore.collection('internships').get();
      return snapshot.size;
    } catch (e) {
      debugPrint('Error getting total internships: $e');
      return 0;
    }
  }

  // Get total enrollments across all courses
  Future<int> getTotalEnrollments() async {
    try {
      final snapshot = await _firestore.collection('courses').get();
      int total = 0;
      for (var doc in snapshot.docs) {
        final enrolledUsers = (doc['enrolledUsers'] as List?)?.length ?? 0;
        total += enrolledUsers;
      }
      return total;
    } catch (e) {
      debugPrint('Error getting total enrollments: $e');
      return 0;
    }
  }

  // Get total applications
  Future<int> getTotalApplications() async {
    try {
      final snapshot = await _firestore.collection('applications').get();
      return snapshot.size;
    } catch (e) {
      debugPrint('Error getting total applications: $e');
      return 0;
    }
  }

  // Get pending applications count
  Future<int> getPendingApplications() async {
    try {
      final snapshot = await _firestore
          .collection('applications')
          .where('status', isEqualTo: 'pending')
          .get();
      return snapshot.size;
    } catch (e) {
      debugPrint('Error getting pending applications: $e');
      return 0;
    }
  }

  // Get approved applications count
  Future<int> getApprovedApplications() async {
    try {
      final snapshot = await _firestore
          .collection('applications')
          .where('status', isEqualTo: 'accepted')
          .get();
      return snapshot.size;
    } catch (e) {
      debugPrint('Error getting approved applications: $e');
      return 0;
    }
  }

  // Get rejected applications count
  Future<int> getRejectedApplications() async {
    try {
      final snapshot = await _firestore
          .collection('applications')
          .where('status', isEqualTo: 'rejected')
          .get();
      return snapshot.size;
    } catch (e) {
      debugPrint('Error getting rejected applications: $e');
      return 0;
    }
  }

  // Get enrollment trend for last 6 months
  Future<List<EnrollmentTrendData>> getEnrollmentTrend() async {
    try {
      final List<EnrollmentTrendData> trend = [];
      final now = DateTime.now();

      for (int i = 5; i >= 0; i--) {
        final monthDate = DateTime(now.year, now.month - i, 1);
        final monthName = _getMonthName(monthDate.month);

        // Query activity logs for this month
        final snapshot = await _firestore
            .collection('activity_logs')
            .where('type', isEqualTo: 'course_enrollment')
            .where('timestamp',
                isGreaterThanOrEqualTo: Timestamp.fromDate(
                    DateTime(monthDate.year, monthDate.month, 1)))
            .where('timestamp',
                isLessThan: Timestamp.fromDate(
                    DateTime(monthDate.year, monthDate.month + 1, 1)))
            .get();

        trend.add(EnrollmentTrendData(
          month: monthName,
          enrollments: snapshot.size,
          date: monthDate,
        ));
      }

      return trend;
    } catch (e) {
      debugPrint('Error getting enrollment trend: $e');
      return [];
    }
  }

  // Get internship statistics
  Future<Map<String, int>> getInternshipStats() async {
    try {
      final snapshot = await _firestore.collection('internships').get();

      int activeInterns = 0;
      int totalApplicants = 0;
      int totalWaitlist = 0;

      for (var doc in snapshot.docs) {
        activeInterns += doc['activeInterns'] as int? ?? 0;
        totalApplicants += doc['applicantsCount'] as int? ?? 0;
        totalWaitlist += doc['waitlist'] as int? ?? 0;
      }

      return {
        'activeInterns': activeInterns,
        'totalApplicants': totalApplicants,
        'totalWaitlist': totalWaitlist,
      };
    } catch (e) {
      debugPrint('Error getting internship stats: $e');
      return {'activeInterns': 0, 'totalApplicants': 0, 'totalWaitlist': 0};
    }
  }

  // Get completed courses count
  Future<int> getCompletedCourses() async {
    try {
      final snapshot = await _firestore
          .collection('activity_logs')
          .where('type', isEqualTo: 'course_completion')
          .get();
      return snapshot.size;
    } catch (e) {
      debugPrint('Error getting completed courses: $e');
      return 0;
    }
  }

  // Get complete statistics object
  Future<AdminStatisticsModel> getCompleteStatistics() async {
    try {
      final totalUsers = await getTotalUsers();
      final totalCourses = await getTotalCourses();
      final totalInternships = await getTotalInternships();
      final totalApplications = await getTotalApplications();
      final totalEnrollments = await getTotalEnrollments();
      final pendingApplications = await getPendingApplications();
      final approvedApplications = await getApprovedApplications();
      final rejectedApplications = await getRejectedApplications();
      final internshipStats = await getInternshipStats();
      final completedCourses = await getCompletedCourses();
      final enrollmentTrend = await getEnrollmentTrend();

      return AdminStatisticsModel(
        statisticsId: 'stats_${DateTime.now().millisecondsSinceEpoch}',
        totalUsers: totalUsers,
        totalCourses: totalCourses,
        totalInternships: totalInternships,
        totalApplications: totalApplications,
        totalEnrollments: totalEnrollments,
        pendingApplications: pendingApplications,
        approvedApplications: approvedApplications,
        rejectedApplications: rejectedApplications,
        activeInterns: internshipStats['activeInterns'] ?? 0,
        completedCourses: completedCourses,
        timestamp: DateTime.now(),
        enrollmentTrend: enrollmentTrend,
      );
    } catch (e) {
      debugPrint('Error getting complete statistics: $e');
      rethrow;
    }
  }

  String _getMonthName(int month) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
