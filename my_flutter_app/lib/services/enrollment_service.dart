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
}
