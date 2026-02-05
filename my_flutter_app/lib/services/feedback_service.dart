import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/feedback_model.dart';

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'feedback';

  Future<String> submitFeedback(FeedbackModel feedback) async {
    final docRef = _firestore.collection(_collection).doc();
    final payload = feedback.copyWith(
      feedbackId: docRef.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: feedback.status.isNotEmpty ? feedback.status : 'new',
    );
    await docRef.set(payload.toFirestore());
    return docRef.id;
  }

  Stream<List<FeedbackModel>> getUserFeedback(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FeedbackModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<FeedbackModel>> getAllFeedback() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FeedbackModel.fromFirestore(doc))
            .toList());
  }

  // Get feedback for a specific course
  Stream<List<FeedbackModel>> getFeedbackByCourse(String courseId) {
    return _firestore
        .collection(_collection)
        .where('referenceType', isEqualTo: 'course')
        .where('referenceId', isEqualTo: courseId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FeedbackModel.fromFirestore(doc))
            .toList());
  }

  // Get feedback for a specific internship
  Stream<List<FeedbackModel>> getFeedbackByInternship(String internshipId) {
    return _firestore
        .collection(_collection)
        .where('referenceType', isEqualTo: 'internship')
        .where('referenceId', isEqualTo: internshipId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FeedbackModel.fromFirestore(doc))
            .toList());
  }

  // Get feedback by category
  Stream<List<FeedbackModel>> getFeedbackByCategory(String category) {
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FeedbackModel.fromFirestore(doc))
            .toList());
  }

  // Calculate average rating for a course
  Future<double> getAverageCourseRating(String courseId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('referenceType', isEqualTo: 'course')
          .where('referenceId', isEqualTo: courseId)
          .get();

      if (snapshot.docs.isEmpty) return 0.0;

      double totalRating = 0;
      int count = 0;

      for (var doc in snapshot.docs) {
        final rating = doc.data()['rating'] as num?;
        if (rating != null) {
          totalRating += rating.toDouble();
          count++;
        }
      }

      return count > 0 ? totalRating / count : 0.0;
    } catch (e) {
      throw Exception('Error calculating average rating: $e');
    }
  }

  // Get rating count for a course
  Future<int> getCourseRatingCount(String courseId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('referenceType', isEqualTo: 'course')
          .where('referenceId', isEqualTo: courseId)
          .get();
      return snapshot.size;
    } catch (e) {
      throw Exception('Error getting rating count: $e');
    }
  }

  Future<void> updateStatus({
    required String feedbackId,
    required String status,
    String? adminNotes,
  }) async {
    await _firestore.collection(_collection).doc(feedbackId).update({
      'status': status,
      if (adminNotes != null) 'adminNotes': adminNotes,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> updateAdminNotes(String feedbackId, String adminNotes) async {
    await _firestore.collection(_collection).doc(feedbackId).update({
      'adminNotes': adminNotes,
      'updatedAt': Timestamp.now(),
    });
  }

  // Mark feedback as resolved
  Future<void> markFeedbackAsResolved(String feedbackId) async {
    try {
      await _firestore.collection(_collection).doc(feedbackId).update({
        'status': 'resolved',
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Error marking feedback as resolved: $e');
    }
  }

  // Delete feedback
  Future<void> deleteFeedback(String feedbackId) async {
    try {
      await _firestore.collection(_collection).doc(feedbackId).delete();
    } catch (e) {
      throw Exception('Error deleting feedback: $e');
    }
  }

  // Get feedback statistics
  Future<Map<String, int>> getFeedbackStatistics() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      
      int newCount = 0;
      int inProgressCount = 0;
      int resolvedCount = 0;
      int closedCount = 0;

      for (var doc in snapshot.docs) {
        final status = doc.data()['status'] as String?;
        switch (status) {
          case 'new':
            newCount++;
            break;
          case 'in_progress':
            inProgressCount++;
            break;
          case 'resolved':
            resolvedCount++;
            break;
          case 'closed':
            closedCount++;
            break;
        }
      }

      return {
        'new': newCount,
        'in_progress': inProgressCount,
        'resolved': resolvedCount,
        'closed': closedCount,
        'total': snapshot.size,
      };
    } catch (e) {
      throw Exception('Error getting feedback statistics: $e');
    }
  }
}
