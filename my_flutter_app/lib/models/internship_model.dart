import 'package:cloud_firestore/cloud_firestore.dart';

class InternshipModel {
  final String internshipId;
  final String role;
  final String company;
  final String location;
  final String type;
  final String description;
  final String jobDescription;
  final List<String> requirements;
  final List<String> benefits;
  final bool isOpen;
  final int applicantsCount;
  final int activeInterns;
  final int waitlist;
  final String postedBy;
  final DateTime postedAt;

  InternshipModel({
    required this.internshipId,
    required this.role,
    required this.company,
    required this.location,
    required this.type,
    required this.description,
    this.jobDescription = '',
    this.requirements = const [],
    this.benefits = const [],
    this.isOpen = true,
    this.applicantsCount = 0,
    this.activeInterns = 0,
    this.waitlist = 0,
    required this.postedBy,
    required this.postedAt,
  });

  // Factory constructor to create InternshipModel from Firestore document
  factory InternshipModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return InternshipModel(
      internshipId: doc.id,
      role: data['role'] ?? '',
      company: data['company'] ?? '',
      location: data['location'] ?? '',
      type: data['type'] ?? '',
      description: data['description'] ?? '',
      jobDescription: data['jobDescription'] ?? '',
      requirements: List<String>.from(data['requirements'] ?? []),
      benefits: List<String>.from(data['benefits'] ?? []),
      isOpen: data['isOpen'] ?? true,
      applicantsCount: data['applicantsCount'] ?? 0,
      activeInterns: data['activeInterns'] ?? 0,
      waitlist: data['waitlist'] ?? 0,
      postedBy: data['postedBy'] ?? '',
      postedAt: (data['postedAt'] as Timestamp).toDate(),
    );
  }

  // Factory constructor to create InternshipModel from JSON
  factory InternshipModel.fromJson(Map<String, dynamic> json) {
    return InternshipModel(
      internshipId: json['internshipId'] ?? '',
      role: json['role'] ?? '',
      company: json['company'] ?? '',
      location: json['location'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      jobDescription: json['jobDescription'] ?? '',
      requirements: List<String>.from(json['requirements'] ?? []),
      benefits: List<String>.from(json['benefits'] ?? []),
      isOpen: json['isOpen'] ?? true,
      applicantsCount: json['applicantsCount'] ?? 0,
      activeInterns: json['activeInterns'] ?? 0,
      waitlist: json['waitlist'] ?? 0,
      postedBy: json['postedBy'] ?? '',
      postedAt: json['postedAt'] is Timestamp
          ? (json['postedAt'] as Timestamp).toDate()
          : DateTime.parse(json['postedAt']),
    );
  }

  // Convert InternshipModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'internshipId': internshipId,
      'role': role,
      'company': company,
      'location': location,
      'type': type,
      'description': description,
      'jobDescription': jobDescription,
      'requirements': requirements,
      'benefits': benefits,
      'isOpen': isOpen,
      'applicantsCount': applicantsCount,
      'activeInterns': activeInterns,
      'waitlist': waitlist,
      'postedBy': postedBy,
      'postedAt': Timestamp.fromDate(postedAt),
    };
  }

  // Convert InternshipModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'role': role,
      'company': company,
      'location': location,
      'type': type,
      'description': description,
      'jobDescription': jobDescription,
      'requirements': requirements,
      'benefits': benefits,
      'isOpen': isOpen,
      'applicantsCount': applicantsCount,
      'activeInterns': activeInterns,
      'waitlist': waitlist,
      'postedBy': postedBy,
      'postedAt': Timestamp.fromDate(postedAt),
    };
  }

  // Create a copy with updated fields
  InternshipModel copyWith({
    String? internshipId,
    String? role,
    String? company,
    String? location,
    String? type,
    String? description,
    String? jobDescription,
    List<String>? requirements,
    List<String>? benefits,
    bool? isOpen,
    int? applicantsCount,
    int? activeInterns,
    int? waitlist,
    String? postedBy,
    DateTime? postedAt,
  }) {
    return InternshipModel(
      internshipId: internshipId ?? this.internshipId,
      role: role ?? this.role,
      company: company ?? this.company,
      location: location ?? this.location,
      type: type ?? this.type,
      description: description ?? this.description,
      jobDescription: jobDescription ?? this.jobDescription,
      requirements: requirements ?? this.requirements,
      benefits: benefits ?? this.benefits,
      isOpen: isOpen ?? this.isOpen,
      applicantsCount: applicantsCount ?? this.applicantsCount,
      activeInterns: activeInterns ?? this.activeInterns,
      waitlist: waitlist ?? this.waitlist,
      postedBy: postedBy ?? this.postedBy,
      postedAt: postedAt ?? this.postedAt,
    );
  }
}
