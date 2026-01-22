import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/progress_model.dart';

class ProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'user_progress';

  Stream<ProgressModel?> getUserProgress(String userId, String courseId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('courseId', isEqualTo: courseId)
        .limit(1)
        .snapshots()
        .map((snap) => snap.docs.isNotEmpty
            ? ProgressModel.fromFirestore(snap.docs.first)
            : null);
  }

  Stream<List<ProgressModel>> getUserProgressList(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProgressModel.fromFirestore(doc))
            .toList());
  }

  Future<void> startCourse({
    required String userId,
    required String courseId,
    int totalVideos = 0,
  }) async {
    final doc = _firestore.collection(_collection).doc();
    final payload = ProgressModel(
      progressId: doc.id,
      userId: userId,
      courseId: courseId,
      completionPercentage: 0,
      videosWatched: 0,
      totalVideos: totalVideos,
      startedAt: DateTime.now(),
      lastAccessedAt: DateTime.now(),
    );
    await doc.set({
      ...payload.toFirestore(),
      'progressId': doc.id,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> updateProgress({
    required String progressId,
    required int completionPercentage,
    int? videosWatched,
    int? totalVideos,
  }) async {
    await _firestore.collection(_collection).doc(progressId).update({
      'completionPercentage': completionPercentage,
      if (videosWatched != null) 'videosWatched': videosWatched,
      if (totalVideos != null) 'totalVideos': totalVideos,
      'updatedAt': Timestamp.now(),
      'lastAccessedAt': Timestamp.now(),
    });
  }

  Future<void> completeCourse(String progressId) async {
    await _firestore.collection(_collection).doc(progressId).update({
      'completionPercentage': 100,
      'completedAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
      'lastAccessedAt': Timestamp.now(),
    });
  }

  Future<void> upsertProgress({
    required String userId,
    required String courseId,
    required int completionPercentage,
    int? videosWatched,
    int? totalVideos,
  }) async {
    final query = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('courseId', isEqualTo: courseId)
        .limit(1)
        .get();
    if (query.docs.isEmpty) {
      final doc = _firestore.collection(_collection).doc();
      await doc.set({
        'progressId': doc.id,
        'userId': userId,
        'courseId': courseId,
        'completionPercentage': completionPercentage,
        'videosWatched': videosWatched ?? 0,
        'totalVideos': totalVideos ?? 0,
        'startedAt': Timestamp.now(),
        'lastAccessedAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
    } else {
      await updateProgress(
        progressId: query.docs.first.id,
        completionPercentage: completionPercentage,
        videosWatched: videosWatched,
        totalVideos: totalVideos,
      );
    }
  }
}
