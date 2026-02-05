import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserLevelModel {
  final String userId;
  final int level;
  final int totalXP;
  final int xpToNextLevel;
  final String title;
  final DateTime lastUpdated;

  UserLevelModel({
    required this.userId,
    this.level = 1,
    this.totalXP = 0,
    required this.xpToNextLevel,
    required this.title,
    required this.lastUpdated,
  });

  factory UserLevelModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserLevelModel(
      userId: doc.id,
      level: data['level'] ?? 1,
      totalXP: data['totalXP'] ?? 0,
      xpToNextLevel: data['xpToNextLevel'] ?? 100,
      title: data['title'] ?? 'Novice',
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'level': level,
      'totalXP': totalXP,
      'xpToNextLevel': xpToNextLevel,
      'title': title,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  static String getTitleForLevel(int level) {
    if (level < 5) return 'Novice';
    if (level < 10) return 'Learner';
    if (level < 20) return 'Scholar';
    if (level < 35) return 'Expert';
    if (level < 50) return 'Master';
    return 'Grand Master';
  }

  static int getXPForLevel(int level) {
    return (level * 100 * 1.2).round();
  }
}

class BadgeModel {
  final String badgeId;
  final String name;
  final String description;
  final String iconEmoji;
  final BadgeRarity rarity;
  final DateTime? earnedAt;

  BadgeModel({
    required this.badgeId,
    required this.name,
    required this.description,
    required this.iconEmoji,
    this.rarity = BadgeRarity.common,
    this.earnedAt,
  });

  factory BadgeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BadgeModel(
      badgeId: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      iconEmoji: data['iconEmoji'] ?? '🏆',
      rarity: BadgeRarity.values.firstWhere(
        (r) => r.toString().split('.').last == data['rarity'],
        orElse: () => BadgeRarity.common,
      ),
      earnedAt: (data['earnedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'iconEmoji': iconEmoji,
      'rarity': rarity.toString().split('.').last,
      'earnedAt': earnedAt != null ? Timestamp.fromDate(earnedAt!) : null,
    };
  }

  Color get rarityColor {
    switch (rarity) {
      case BadgeRarity.common:
        return const Color(0xFF9CA3AF);
      case BadgeRarity.rare:
        return const Color(0xFF3B82F6);
      case BadgeRarity.epic:
        return const Color(0xFF8B5CF6);
      case BadgeRarity.legendary:
        return const Color(0xFFF59E0B);
    }
  }
}

enum BadgeRarity {
  common,
  rare,
  epic,
  legendary,
}

class XPAction {
  static const int completeLesson = 10;
  static const int completeQuiz = 20;
  static const int perfectQuiz = 50;
  static const int completeCourse = 100;
  static const int submitFeedback = 5;
  static const int dailyLogin = 5;
  static const int weekStreak = 25;
  static const int helpPeer = 15;
}
