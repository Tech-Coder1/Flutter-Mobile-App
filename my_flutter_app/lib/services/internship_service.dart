import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/internship_model.dart';

class InternshipService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'internships';

  // Get open internships only
  Stream<List<InternshipModel>> getAllInternships() {
    return _firestore
        .collection(_collection)
        .where('isOpen', isEqualTo: true)
        .orderBy('postedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InternshipModel.fromFirestore(doc))
            .toList());
  }

  // Get internship by ID
  Future<InternshipModel?> getInternshipById(String internshipId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(internshipId)
          .get();

      if (doc.exists) {
        return InternshipModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching internship: $e');
    }
  }

  // Get internships by type
  Stream<List<InternshipModel>> getInternshipsByType(String type) {
    return _firestore
        .collection(_collection)
        .where('type', isEqualTo: type)
        .orderBy('postedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InternshipModel.fromFirestore(doc))
            .toList());
  }

  // Get internships by company
  Stream<List<InternshipModel>> getInternshipsByCompany(String company) {
    return _firestore
        .collection(_collection)
        .where('company', isEqualTo: company)
        .orderBy('postedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InternshipModel.fromFirestore(doc))
            .toList());
  }

  // Create new internship
  Future<String> createInternship(InternshipModel internship) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_collection)
          .add(internship.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating internship: $e');
    }
  }

  // Update internship
  Future<void> updateInternship(String internshipId, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(internshipId)
          .update(updates);
    } catch (e) {
      throw Exception('Error updating internship: $e');
    }
  }

  // Delete internship
  Future<void> deleteInternship(String internshipId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(internshipId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting internship: $e');
    }
  }

  // Get internship count
  Future<int> getInternshipCount() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection(_collection).get();
      return snapshot.size;
    } catch (e) {
      throw Exception('Error getting internship count: $e');
    }
  }

  // Search internships
  Stream<List<InternshipModel>> searchInternships(String query) {
    return _firestore
        .collection(_collection)
        .orderBy('postedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InternshipModel.fromFirestore(doc))
            .where((internship) =>
                internship.role.toLowerCase().contains(query.toLowerCase()) ||
                internship.company.toLowerCase().contains(query.toLowerCase()) ||
                internship.location.toLowerCase().contains(query.toLowerCase()))
            .toList());
  }

  // Get all applications for a specific internship
  Future<List<Map<String, dynamic>>> getInternshipApplications(String internshipId) async {
    try {
      final snapshot = await _firestore
          .collection('applications')
          .where('internshipId', isEqualTo: internshipId)
          .orderBy('submittedAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => {
        'applicationId': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      throw Exception('Error getting internship applications: $e');
    }
  }

  // Get application count for an internship
  Future<int> getApplicationCount(String internshipId) async {
    try {
      final snapshot = await _firestore
          .collection('applications')
          .where('internshipId', isEqualTo: internshipId)
          .get();
      return snapshot.size;
    } catch (e) {
      throw Exception('Error getting application count: $e');
    }
  }

  // Toggle internship status (open/closed for applications)
  Future<void> toggleInternshipStatus(String internshipId, bool isOpen) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(internshipId)
          .update({
            'isOpen': isOpen,
            'updatedAt': Timestamp.now(),
          });
    } catch (e) {
      throw Exception('Error toggling internship status: $e');
    }
  }

  // Get internships by date range (for reports)
  Future<List<InternshipModel>> getInternshipsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('postedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('postedAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('postedAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => InternshipModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Error fetching internships by date range: $e');
    }
  }

  // Get popular internships (by application count)
  Future<List<Map<String, dynamic>>> getPopularInternships({int limit = 5}) async {
    try {
      final internships = await _firestore
          .collection(_collection)
          .orderBy('postedAt', descending: true)
          .limit(50)
          .get();

      List<Map<String, dynamic>> internshipsWithCounts = [];
      
      for (var doc in internships.docs) {
        final count = await getApplicationCount(doc.id);
        internshipsWithCounts.add({
          'internship': InternshipModel.fromFirestore(doc),
          'applicationCount': count,
        });
      }

      internshipsWithCounts.sort((a, b) => 
        (b['applicationCount'] as int).compareTo(a['applicationCount'] as int));

      return internshipsWithCounts.take(limit).toList();
    } catch (e) {
      throw Exception('Error getting popular internships: $e');
    }
  }
}
