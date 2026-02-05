import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/enrollment_model.dart';

class EnrollmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'enrollments';

  String _enrollmentId(String userId, String courseId) => '${userId}_$courseId';

  Future<bool> isEnrolled(String userId, String courseId) async {
    final doc = await _firestore.collection(_collection).doc(_enrollmentId(userId, courseId)).get();
    return doc.exists;
  }

  Future<void> createEnrollment(String userId, String courseId) async {
    final id = _enrollmentId(userId, courseId);
    final docRef = _firestore.collection(_collection).doc(id);
    final existing = await docRef.get();
    if (existing.exists) return; // already enrolled
    final enrollment = EnrollmentModel(
      enrollmentId: id,
      userId: userId,
      courseId: courseId,
      enrolledAt: DateTime.now(),
    );
    await docRef.set(enrollment.toFirestore());
  }

  Stream<List<EnrollmentModel>> getUserEnrollments(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((s) => s.docs.map((d) => EnrollmentModel.fromFirestore(d)).toList());
  }

  // Get enrollment by ID
  Future<EnrollmentModel?> getEnrollmentById(String enrollmentId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(enrollmentId).get();
      if (doc.exists) {
        return EnrollmentModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching enrollment: $e');
    }
  }

  // Get all enrollments for admin
  Stream<List<EnrollmentModel>> getAllEnrollments() {
    return _firestore
        .collection(_collection)
        .orderBy('enrolledAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => EnrollmentModel.fromFirestore(d)).toList());
  }

  // Get enrollments for a specific course
  Stream<List<EnrollmentModel>> getEnrollmentsByCourse(String courseId) {
    return _firestore
        .collection(_collection)
        .where('courseId', isEqualTo: courseId)
        .orderBy('enrolledAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => EnrollmentModel.fromFirestore(d)).toList());
  }

  // Get enrollment count for a course
  Future<int> getCourseEnrollmentCount(String courseId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('courseId', isEqualTo: courseId)
          .get();
      return snapshot.size;
    } catch (e) {
      throw Exception('Error getting enrollment count: $e');
    }
  }

  // Delete enrollment (unenroll)
  Future<void> deleteEnrollment(String userId, String courseId) async {
    try {
      final id = _enrollmentId(userId, courseId);
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Error deleting enrollment: $e');
    }
  }

  // Get enrollments by date range (for reports)
  Future<List<EnrollmentModel>> getEnrollmentsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('enrolledAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('enrolledAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('enrolledAt', descending: true)
          .get();
      return snapshot.docs.map((d) => EnrollmentModel.fromFirestore(d)).toList();
    } catch (e) {
      throw Exception('Error fetching enrollments by date range: $e');
    }
  }

  // Get total enrollment count
  Future<int> getTotalEnrollmentCount() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.size;
    } catch (e) {
      throw Exception('Error getting total enrollment count: $e');
    }
  }
}
