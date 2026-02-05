import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'notifications';

  // Create new notification
  Future<String> createNotification(NotificationModel notification) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_collection)
          .add(notification.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating notification: $e');
    }
  }

  // Get notifications for user
  Stream<List<NotificationModel>> getNotificationsForUser(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }

  // Get unread notifications count
  Stream<int> getUnreadNotificationCount(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      throw Exception('Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read for user
  Future<void> markAllAsRead(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      WriteBatch batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Error marking all notifications as read: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(notificationId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting notification: $e');
    }
  }

  // Delete all notifications for user
  Future<void> deleteAllNotifications(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      WriteBatch batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Error deleting all notifications: $e');
    }
  }

  // Send notification to user when application is submitted
  Future<void> sendApplicationNotification({
    required String userId,
    required String internshipRole,
  }) async {
    try {
      NotificationModel notification = NotificationModel(
        notificationId: '',
        userId: userId,
        title: 'Application Submitted',
        message: 'Your application for $internshipRole has been submitted successfully.',
        type: 'application',
        createdAt: DateTime.now(),
      );

      await createNotification(notification);
    } catch (e) {
      throw Exception('Error sending notification: $e');
    }
  }

  // Send notification when application is approved
  Future<void> sendApplicationApprovedNotification({
    required String userId,
    required String internshipRole,
    String? additionalMessage,
  }) async {
    try {
      NotificationModel notification = NotificationModel(
        notificationId: '',
        userId: userId,
        title: 'Application Approved! 🎉',
        message: 'Congratulations! Your application for $internshipRole has been approved.${additionalMessage != null ? ' $additionalMessage' : ''}',
        type: 'application',
        createdAt: DateTime.now(),
      );

      await createNotification(notification);
    } catch (e) {
      throw Exception('Error sending approval notification: $e');
    }
  }

  // Send notification when application is rejected
  Future<void> sendApplicationRejectedNotification({
    required String userId,
    required String internshipRole,
    String? reason,
  }) async {
    try {
      NotificationModel notification = NotificationModel(
        notificationId: '',
        userId: userId,
        title: 'Application Status Update',
        message: 'Unfortunately, your application for $internshipRole was not successful at this time.${reason != null ? ' $reason' : ' Please keep looking for other opportunities!'}',
        type: 'application',
        createdAt: DateTime.now(),
      );

      await createNotification(notification);
    } catch (e) {
      throw Exception('Error sending rejection notification: $e');
    }
  }

  // Send notification when course enrollment is successful
  Future<void> sendEnrollmentNotification({
    required String userId,
    required String courseTitle,
  }) async {
    try {
      NotificationModel notification = NotificationModel(
        notificationId: '',
        userId: userId,
        title: 'Course Enrollment Successful',
        message: 'You have successfully enrolled in $courseTitle.',
        type: 'course',
        createdAt: DateTime.now(),
      );

      await createNotification(notification);
    } catch (e) {
      throw Exception('Error sending notification: $e');
    }
  }

  // Send notification when course is completed
  Future<void> sendCourseCompletionNotification({
    required String userId,
    required String courseTitle,
  }) async {
    try {
      NotificationModel notification = NotificationModel(
        notificationId: '',
        userId: userId,
        title: 'Course Completed! 🎓',
        message: 'Congratulations! You have completed $courseTitle. Check your certificates.',
        type: 'course',
        createdAt: DateTime.now(),
      );

      await createNotification(notification);
    } catch (e) {
      throw Exception('Error sending completion notification: $e');
    }
  }

  // Send notification when feedback is responded to
  Future<void> sendFeedbackResponseNotification({
    required String userId,
    required String feedbackTitle,
  }) async {
    try {
      NotificationModel notification = NotificationModel(
        notificationId: '',
        userId: userId,
        title: 'Feedback Response',
        message: 'An admin has responded to your feedback: "$feedbackTitle"',
        type: 'feedback',
        createdAt: DateTime.now(),
      );

      await createNotification(notification);
    } catch (e) {
      throw Exception('Error sending feedback response notification: $e');
    }
  }
}
