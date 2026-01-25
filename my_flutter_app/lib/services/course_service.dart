import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';
import 'enrollment_service.dart';

class CourseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'courses';

  // Get all courses
  Stream<List<CourseModel>> getAllCourses() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CourseModel.fromFirestore(doc))
            .toList());
  }

  // Get course by ID
  Future<CourseModel?> getCourseById(String courseId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(courseId)
          .get();

      if (doc.exists) {
        return CourseModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching course: $e');
    }
  }

  // Get courses by level
  Stream<List<CourseModel>> getCoursesByLevel(String level) {
    return _firestore
        .collection(_collection)
        .where('level', isEqualTo: level)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CourseModel.fromFirestore(doc))
            .toList());
  }

  // Create new course
  Future<String> createCourse(CourseModel course) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_collection)
          .add(course.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating course: $e');
    }
  }

  // Update course
  Future<void> updateCourse(String courseId, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(courseId)
          .update(updates);
    } catch (e) {
      throw Exception('Error updating course: $e');
    }
  }

  // Delete course
  Future<void> deleteCourse(String courseId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(courseId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting course: $e');
    }
  }

  // Enroll user in course
  Future<void> enrollUserInCourse(String courseId, String userId) async {
    try {
      final enrollmentService = EnrollmentService();
      final already = await enrollmentService.isEnrolled(userId, courseId);
      if (already) return;

      // Create enrollment doc first to ensure uniqueness
      await enrollmentService.createEnrollment(userId, courseId);

      // Then update aggregates for quick UI checks
      await _firestore.runTransaction((transaction) async {
        // Add user to course's enrolledUsers
        final courseRef = _firestore.collection(_collection).doc(courseId);
        transaction.update(courseRef, {
          'enrolledUsers': FieldValue.arrayUnion([userId])
        });

        // Add course to user's enrolledCourses
        final userRef = _firestore.collection('users').doc(userId);
        transaction.update(userRef, {
          'enrolledCourses': FieldValue.arrayUnion([courseId])
        });
      });
    } catch (e) {
      throw Exception('Error enrolling in course: $e');
    }
  }

  // Unenroll user from course
  Future<void> unenrollUserFromCourse(String courseId, String userId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Remove user from course's enrolledUsers
        DocumentReference courseRef = _firestore.collection(_collection).doc(courseId);
        transaction.update(courseRef, {
          'enrolledUsers': FieldValue.arrayRemove([userId])
        });

        // Remove course from user's enrolledCourses
        DocumentReference userRef = _firestore.collection('users').doc(userId);
        transaction.update(userRef, {
          'enrolledCourses': FieldValue.arrayRemove([courseId])
        });
      });
    } catch (e) {
      throw Exception('Error unenrolling from course: $e');
    }
  }

  // Get enrolled courses for user
  Stream<List<CourseModel>> getEnrolledCoursesForUser(String userId) {
    return _firestore
        .collection(_collection)
        .where('enrolledUsers', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CourseModel.fromFirestore(doc))
            .toList());
  }

  // Get course count
  Future<int> getCourseCount() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection(_collection).get();
      return snapshot.size;
    } catch (e) {
      throw Exception('Error getting course count: $e');
    }
  }
}
