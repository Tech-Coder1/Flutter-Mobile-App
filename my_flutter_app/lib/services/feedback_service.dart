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
}
