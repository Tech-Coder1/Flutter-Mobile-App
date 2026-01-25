import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/certificate_model.dart';

class CertificateService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'certificates';

  // Get all certificates for a user
  Stream<List<CertificateModel>> getUserCertificates(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('issuedDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CertificateModel.fromFirestore(doc))
            .toList());
  }

  // Get certificate by ID
  Future<CertificateModel?> getCertificateById(String certificateId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(_collection).doc(certificateId).get();

      if (doc.exists) {
        return CertificateModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching certificate: $e');
    }
  }

  // Issue a certificate when user completes a course
  Future<String> issueCertificate({
    required String userId,
    required String courseId,
    required String courseTitle,
    required String userName,
    double completionScore = 100.0,
  }) async {
    try {
      // Check if certificate already exists
      final existing = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('courseId', isEqualTo: courseId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        return existing.docs.first.id; // Return existing certificate
      }

      DocumentReference docRef = await _firestore.collection(_collection).add({
        'userId': userId,
        'courseId': courseId,
        'courseTitle': courseTitle,
        'userName': userName,
        'issuedDate': Timestamp.now(),
        'certificateUrl': '',
        'completionScore': completionScore,
      });

      // Update user's certificate count
      await _firestore.collection('users').doc(userId).update({
        'certificatesCount': FieldValue.increment(1),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Error issuing certificate: $e');
    }
  }

  // Get certificate count for user
  Future<int> getUserCertificateCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.size;
    } catch (e) {
      throw Exception('Error getting certificate count: $e');
    }
  }

  // Check if user has certificate for a course
  Future<bool> hasCertificateForCourse(String userId, String courseId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('courseId', isEqualTo: courseId)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Error checking certificate: $e');
    }
  }

  // Delete certificate (admin only)
  Future<void> deleteCertificate(String certificateId, String userId) async {
    try {
      await _firestore.collection(_collection).doc(certificateId).delete();

      // Update user's certificate count
      await _firestore.collection('users').doc(userId).update({
        'certificatesCount': FieldValue.increment(-1),
      });
    } catch (e) {
      throw Exception('Error deleting certificate: $e');
    }
  }

  // Get all certificates (admin view)
  Stream<List<CertificateModel>> getAllCertificates() {
    return _firestore
        .collection(_collection)
        .orderBy('issuedDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CertificateModel.fromFirestore(doc))
            .toList());
  }

  // Get total certificates count
  Future<int> getTotalCertificatesCount() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.size;
    } catch (e) {
      throw Exception('Error getting total certificates: $e');
    }
  }
}
