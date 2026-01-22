import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String feedbackId;
  final String userId;
  final String userName;
  final String category; // ui, course, internship, support, other
  final double rating; // 1-5
  final String message;
  final String referenceType; // app, course, internship
  final String referenceId; // optional context id
  final String status; // new, in_review, resolved
  final String adminNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  FeedbackModel({
    required this.feedbackId,
    required this.userId,
    required this.userName,
    required this.category,
    required this.rating,
    required this.message,
    this.referenceType = 'app',
    this.referenceId = '',
    this.status = 'new',
    this.adminNotes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory FeedbackModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FeedbackModel(
      feedbackId: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      category: data['category'] ?? 'other',
      rating: (data['rating'] ?? 0).toDouble(),
      message: data['message'] ?? '',
      referenceType: data['referenceType'] ?? 'app',
      referenceId: data['referenceId'] ?? '',
      status: data['status'] ?? 'new',
      adminNotes: data['adminNotes'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      feedbackId: json['feedbackId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      category: json['category'] ?? 'other',
      rating: (json['rating'] ?? 0).toDouble(),
      message: json['message'] ?? '',
      referenceType: json['referenceType'] ?? 'app',
      referenceId: json['referenceId'] ?? '',
      status: json['status'] ?? 'new',
      adminNotes: json['adminNotes'] ?? '',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'feedbackId': feedbackId,
      'userId': userId,
      'userName': userName,
      'category': category,
      'rating': rating,
      'message': message,
      'referenceType': referenceType,
      'referenceId': referenceId,
      'status': status,
      'adminNotes': adminNotes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'category': category,
      'rating': rating,
      'message': message,
      'referenceType': referenceType,
      'referenceId': referenceId,
      'status': status,
      'adminNotes': adminNotes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  FeedbackModel copyWith({
    String? feedbackId,
    String? userId,
    String? userName,
    String? category,
    double? rating,
    String? message,
    String? referenceType,
    String? referenceId,
    String? status,
    String? adminNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FeedbackModel(
      feedbackId: feedbackId ?? this.feedbackId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      message: message ?? this.message,
      referenceType: referenceType ?? this.referenceType,
      referenceId: referenceId ?? this.referenceId,
      status: status ?? this.status,
      adminNotes: adminNotes ?? this.adminNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
