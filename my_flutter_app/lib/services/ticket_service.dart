import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ticket_model.dart';

class TicketService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'support_tickets';

  Future<String> createTicket(TicketModel ticket) async {
    final docRef = _firestore.collection(_collection).doc();
    final payload = ticket.copyWith(
      ticketId: docRef.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: ticket.status.isNotEmpty ? ticket.status : 'open',
    );
    await docRef.set(payload.toFirestore());
    return docRef.id;
  }

  Stream<List<TicketModel>> getUserTickets(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TicketModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<TicketModel>> getAllTickets() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TicketModel.fromFirestore(doc))
            .toList());
  }

  Future<TicketModel?> getTicketDetails(String ticketId) async {
    final doc = await _firestore.collection(_collection).doc(ticketId).get();
    if (doc.exists) {
      return TicketModel.fromFirestore(doc);
    }
    return null;
  }

  Future<void> updateTicketStatus(String ticketId, String status) async {
    await _firestore.collection(_collection).doc(ticketId).update({
      'status': status,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> assignTicket(String ticketId, String adminId) async {
    await _firestore.collection(_collection).doc(ticketId).update({
      'assignedTo': adminId,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> addMessage({
    required String ticketId,
    required String senderId,
    required String senderName,
    required bool isAdmin,
    required String message,
  }) async {
    final messagesRef = _firestore
        .collection(_collection)
        .doc(ticketId)
        .collection('messages')
        .doc();

    final payload = TicketMessage(
      messageId: messagesRef.id,
      senderId: senderId,
      senderName: senderName,
      isAdmin: isAdmin,
      message: message,
      timestamp: DateTime.now(),
    );

    await messagesRef.set(payload.toFirestore());
    await _firestore.collection(_collection).doc(ticketId).update({
      'updatedAt': Timestamp.now(),
    });
  }

  Stream<List<TicketMessage>> getMessagesStream(String ticketId) {
    return _firestore
        .collection(_collection)
        .doc(ticketId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TicketMessage.fromFirestore(doc))
            .toList());
  }
}
