import 'package:cloud_firestore/cloud_firestore.dart';

class TicketModel {
  final String ticketId;
  final String userId;
  final String title;
  final String description;
  final String category; // course_access, technical, payment, other
  final String status; // open, in_progress, resolved
  final String priority; // low, medium, high
  final List<String> attachments;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String assignedTo; // admin user id

  TicketModel({
    required this.ticketId,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.priority,
    this.attachments = const [],
    required this.createdAt,
    required this.updatedAt,
    this.assignedTo = '',
  });

  factory TicketModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TicketModel(
      ticketId: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'other',
      status: data['status'] ?? 'open',
      priority: data['priority'] ?? 'medium',
      attachments: List<String>.from(data['attachments'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      assignedTo: data['assignedTo'] ?? '',
    );
  }

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      ticketId: json['ticketId'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'other',
      status: json['status'] ?? 'open',
      priority: json['priority'] ?? 'medium',
      attachments: List<String>.from(json['attachments'] ?? []),
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(json['updatedAt']),
      assignedTo: json['assignedTo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticketId': ticketId,
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'status': status,
      'priority': priority,
      'attachments': attachments,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'assignedTo': assignedTo,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'status': status,
      'priority': priority,
      'attachments': attachments,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'assignedTo': assignedTo,
    };
  }

  TicketModel copyWith({
    String? ticketId,
    String? userId,
    String? title,
    String? description,
    String? category,
    String? status,
    String? priority,
    List<String>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? assignedTo,
  }) {
    return TicketModel(
      ticketId: ticketId ?? this.ticketId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      assignedTo: assignedTo ?? this.assignedTo,
    );
  }
}

class TicketMessage {
  final String messageId;
  final String senderId;
  final String senderName;
  final bool isAdmin;
  final String message;
  final DateTime timestamp;

  TicketMessage({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.isAdmin,
    required this.message,
    required this.timestamp,
  });

  factory TicketMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TicketMessage(
      messageId: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      isAdmin: data['isAdmin'] ?? false,
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'isAdmin': isAdmin,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
