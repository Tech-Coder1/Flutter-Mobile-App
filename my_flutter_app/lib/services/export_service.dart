import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ExportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate CSV header row
  String _generateCSVRow(List<String> values) {
    return values.map((v) => '"${v.replaceAll('"', '""')}"').join(',');
  }

  // Export users to CSV
  Future<String> exportUsersToCSV() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      
      List<String> rows = [];
      
      // Header
      rows.add(_generateCSVRow([
        'User ID',
        'Full Name',
        'Email',
        'Phone Number',
        'Role',
        'Registered Date',
      ]));

      // Data rows
      for (var doc in snapshot.docs) {
        final data = doc.data();
        rows.add(_generateCSVRow([
          doc.id,
          data['fullName'] ?? '',
          data['email'] ?? '',
          data['phoneNumber'] ?? '',
          data['role'] ?? 'learner',
          (data['createdAt'] as Timestamp?)?.toDate().toString() ?? '',
        ]));
      }

      return rows.join('\n');
    } catch (e) {
      throw Exception('Error exporting users: $e');
    }
  }

  // Export enrollments to CSV with date range
  Future<String> exportEnrollmentsToCSV({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection('enrollments');

      if (startDate != null) {
        query = query.where('enrolledAt', 
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('enrolledAt', 
          isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.orderBy('enrolledAt', descending: true).get();
      
      List<String> rows = [];
      
      // Header
      rows.add(_generateCSVRow([
        'Enrollment ID',
        'User ID',
        'Course ID',
        'Enrollment Date',
      ]));

      // Data rows
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        rows.add(_generateCSVRow([
          doc.id,
          data['userId'] ?? '',
          data['courseId'] ?? '',
          (data['enrolledAt'] as Timestamp?)?.toDate().toString() ?? '',
        ]));
      }

      return rows.join('\n');
    } catch (e) {
      throw Exception('Error exporting enrollments: $e');
    }
  }

  // Export applications to CSV with date range
  Future<String> exportApplicationsToCSV({
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  }) async {
    try {
      Query query = _firestore.collection('applications');

      if (startDate != null) {
        query = query.where('submittedAt', 
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('submittedAt', 
          isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      if (status != null && status.isNotEmpty) {
        query = query.where('status', isEqualTo: status);
      }

      final snapshot = await query.orderBy('submittedAt', descending: true).get();
      
      List<String> rows = [];
      
      // Header
      rows.add(_generateCSVRow([
        'Application ID',
        'User ID',
        'Internship ID',
        'Internship Role',
        'Full Name',
        'Email',
        'Phone',
        'Status',
        'Submitted Date',
      ]));

      // Data rows
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        rows.add(_generateCSVRow([
          doc.id,
          data['userId'] ?? '',
          data['internshipId'] ?? '',
          data['internshipRole'] ?? '',
          data['fullName'] ?? '',
          data['email'] ?? '',
          data['phone'] ?? '',
          data['status'] ?? 'pending',
          (data['submittedAt'] as Timestamp?)?.toDate().toString() ?? '',
        ]));
      }

      return rows.join('\n');
    } catch (e) {
      throw Exception('Error exporting applications: $e');
    }
  }

  // Export courses to CSV
  Future<String> exportCoursesToCSV() async {
    try {
      final snapshot = await _firestore.collection('courses').get();
      
      List<String> rows = [];
      
      // Header
      rows.add(_generateCSVRow([
        'Course ID',
        'Title',
        'Duration',
        'Level',
        'Enrolled Users Count',
        'Created Date',
      ]));

      // Data rows
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final enrolledUsers = data['enrolledUsers'] as List?;
        rows.add(_generateCSVRow([
          doc.id,
          data['title'] ?? '',
          data['duration'] ?? '',
          data['level'] ?? '',
          (enrolledUsers?.length ?? 0).toString(),
          (data['createdAt'] as Timestamp?)?.toDate().toString() ?? '',
        ]));
      }

      return rows.join('\n');
    } catch (e) {
      throw Exception('Error exporting courses: $e');
    }
  }

  // Export internships to CSV
  Future<String> exportInternshipsToCSV() async {
    try {
      final snapshot = await _firestore.collection('internships').get();
      
      List<String> rows = [];
      
      // Header
      rows.add(_generateCSVRow([
        'Internship ID',
        'Role',
        'Company',
        'Location',
        'Type',
        'Posted Date',
      ]));

      // Data rows
      for (var doc in snapshot.docs) {
        final data = doc.data();
        rows.add(_generateCSVRow([
          doc.id,
          data['role'] ?? '',
          data['company'] ?? '',
          data['location'] ?? '',
          data['type'] ?? '',
          (data['postedAt'] as Timestamp?)?.toDate().toString() ?? '',
        ]));
      }

      return rows.join('\n');
    } catch (e) {
      throw Exception('Error exporting internships: $e');
    }
  }

  // Export feedback to CSV
  Future<String> exportFeedbackToCSV({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection('feedback');

      if (startDate != null) {
        query = query.where('createdAt', 
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('createdAt', 
          isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.orderBy('createdAt', descending: true).get();
      
      List<String> rows = [];
      
      // Header
      rows.add(_generateCSVRow([
        'Feedback ID',
        'User ID',
        'Category',
        'Rating',
        'Comment',
        'Status',
        'Created Date',
      ]));

      // Data rows
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        rows.add(_generateCSVRow([
          doc.id,
          data['userId'] ?? '',
          data['category'] ?? '',
          (data['rating'] ?? 0).toString(),
          data['comment'] ?? '',
          data['status'] ?? 'new',
          (data['createdAt'] as Timestamp?)?.toDate().toString() ?? '',
        ]));
      }

      return rows.join('\n');
    } catch (e) {
      throw Exception('Error exporting feedback: $e');
    }
  }

  // Download CSV file (web only)
  void downloadCSV(String csvContent, String filename) {
    if (kIsWeb) {
      // For web platform, create a download link
      final bytes = utf8.encode(csvContent);
      
      // This would need additional web-specific implementation
      // For now, just log that it's ready
      debugPrint('CSV ready for download: $filename');
      debugPrint('Content length: ${bytes.length} bytes');
    } else {
      // For mobile/desktop, would need file system access
      debugPrint('CSV export not yet implemented for this platform');
    }
  }

  // Generate summary report as JSON
  Future<Map<String, dynamic>> generateSummaryReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Get counts for the date range
      Query usersQuery = _firestore.collection('users');
      Query enrollmentsQuery = _firestore.collection('enrollments');
      Query applicationsQuery = _firestore.collection('applications');

      if (startDate != null) {
        usersQuery = usersQuery.where('createdAt', 
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
        enrollmentsQuery = enrollmentsQuery.where('enrolledAt', 
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
        applicationsQuery = applicationsQuery.where('submittedAt', 
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        usersQuery = usersQuery.where('createdAt', 
          isLessThanOrEqualTo: Timestamp.fromDate(endDate));
        enrollmentsQuery = enrollmentsQuery.where('enrolledAt', 
          isLessThanOrEqualTo: Timestamp.fromDate(endDate));
        applicationsQuery = applicationsQuery.where('submittedAt', 
          isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final users = await usersQuery.get();
      final enrollments = await enrollmentsQuery.get();
      final applications = await applicationsQuery.get();
      final courses = await _firestore.collection('courses').get();
      final internships = await _firestore.collection('internships').get();

      return {
        'period': {
          'startDate': startDate?.toIso8601String(),
          'endDate': endDate?.toIso8601String(),
        },
        'statistics': {
          'totalUsers': users.size,
          'totalCourses': courses.size,
          'totalInternships': internships.size,
          'totalEnrollments': enrollments.size,
          'totalApplications': applications.size,
        },
        'generatedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Error generating summary report: $e');
    }
  }
}
