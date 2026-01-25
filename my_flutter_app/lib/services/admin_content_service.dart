import 'package:cloud_firestore/cloud_firestore.dart';

class AdminContentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new course
  Future<String> createCourse({
    required String title,
    required String duration,
    required String level,
    required String description,
    required String createdBy,
  }) async {
    try {
      DocumentReference docRef = await _firestore.collection('courses').add({
        'title': title,
        'duration': duration,
        'level': level,
        'description': description,
        'createdBy': createdBy,
        'enrolledUsers': [],
        'createdAt': Timestamp.now(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating course: $e');
    }
  }

  // Delete course
  Future<void> deleteCourse(String courseId) async {
    try {
      await _firestore.collection('courses').doc(courseId).delete();
    } catch (e) {
      throw Exception('Error deleting course: $e');
    }
  }

  // Create a new internship
  Future<String> createInternship({
    required String role,
    required String company,
    required String location,
    required String type,
    required String description,
    required String postedBy,
  }) async {
    try {
      DocumentReference docRef = await _firestore.collection('internships').add({
        'role': role,
        'company': company,
        'location': location,
        'type': type,
        'description': description,
        'postedBy': postedBy,
        'postedAt': Timestamp.now(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating internship: $e');
    }
  }

  // Delete internship
  Future<void> deleteInternship(String internshipId) async {
    try {
      await _firestore.collection('internships').doc(internshipId).delete();
    } catch (e) {
      throw Exception('Error deleting internship: $e');
    }
  }

  // Get all pending applications
  Stream<QuerySnapshot> getPendingApplications() {
    return _firestore
        .collection('applications')
        .where('status', isEqualTo: 'pending')
        .orderBy('submittedAt', descending: true)
        .snapshots();
  }

  // Approve application
  Future<void> approveApplication(String applicationId) async {
    try {
      await _firestore
          .collection('applications')
          .doc(applicationId)
          .update({'status': 'accepted'});
    } catch (e) {
      throw Exception('Error approving application: $e');
    }
  }

  // Reject application
  Future<void> rejectApplication(String applicationId) async {
    try {
      await _firestore
          .collection('applications')
          .doc(applicationId)
          .update({'status': 'rejected'});
    } catch (e) {
      throw Exception('Error rejecting application: $e');
    }
  }

  // Set user as admin
  Future<void> setUserAsAdmin(String userId, String email) async {
    try {
      await _firestore.collection('admins').doc(userId).set({
        'email': email,
        'role': 'admin',
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Error setting admin: $e');
    }
  }
}
