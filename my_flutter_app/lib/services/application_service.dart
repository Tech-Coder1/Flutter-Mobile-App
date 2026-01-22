import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/application_model.dart';

class ApplicationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'applications';

  // Submit new application
  Future<String> submitApplication(ApplicationModel application) async {
    try {
      // Create application document
      DocumentReference docRef = await _firestore
          .collection(_collection)
          .add(application.toFirestore());

      // Update user's application count
      await _firestore.collection('users').doc(application.userId).update({
        'applicationsCount': FieldValue.increment(1)
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Error submitting application: $e');
    }
  }

  // Get application by ID
  Future<ApplicationModel?> getApplicationById(String applicationId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(applicationId)
          .get();

      if (doc.exists) {
        return ApplicationModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching application: $e');
    }
  }

  // Get all applications for a user
  Stream<List<ApplicationModel>> getApplicationsForUser(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ApplicationModel.fromFirestore(doc))
            .toList());
  }

  // Get all applications for an internship
  Stream<List<ApplicationModel>> getApplicationsForInternship(String internshipId) {
    return _firestore
        .collection(_collection)
        .where('internshipId', isEqualTo: internshipId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ApplicationModel.fromFirestore(doc))
            .toList());
  }

  // Get all applications (for admin)
  Stream<List<ApplicationModel>> getAllApplications() {
    return _firestore
        .collection(_collection)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ApplicationModel.fromFirestore(doc))
            .toList());
  }

  // Get applications by status
  Stream<List<ApplicationModel>> getApplicationsByStatus(String status) {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: status)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ApplicationModel.fromFirestore(doc))
            .toList());
  }

  // Update application status
  Future<void> updateApplicationStatus(String applicationId, String status) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(applicationId)
          .update({'status': status});
    } catch (e) {
      throw Exception('Error updating application status: $e');
    }
  }

  // Delete application
  Future<void> deleteApplication(String applicationId, String userId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Delete application
        DocumentReference appRef = _firestore.collection(_collection).doc(applicationId);
        transaction.delete(appRef);

        // Decrease user's application count
        DocumentReference userRef = _firestore.collection('users').doc(userId);
        transaction.update(userRef, {
          'applicationsCount': FieldValue.increment(-1)
        });
      });
    } catch (e) {
      throw Exception('Error deleting application: $e');
    }
  }

  // Get application count
  Future<int> getApplicationCount() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection(_collection).get();
      return snapshot.size;
    } catch (e) {
      throw Exception('Error getting application count: $e');
    }
  }

  // Check if user has already applied for internship
  Future<bool> hasUserApplied(String userId, String internshipId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('internshipId', isEqualTo: internshipId)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Error checking application: $e');
    }
  }
}
