import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gamification_model.dart';

class GamificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Award XP to user
  Future<Map<String, dynamic>> awardXP(String userId, int points, String action) async {
    try {
      final userLevelRef = _firestore.collection('user_levels').doc(userId);
      final doc = await userLevelRef.get();

      UserLevelModel userLevel;
      if (doc.exists) {
        userLevel = UserLevelModel.fromFirestore(doc);
      } else {
        userLevel = UserLevelModel(
          userId: userId,
          level: 1,
          totalXP: 0,
          xpToNextLevel: UserLevelModel.getXPForLevel(1),
          title: UserLevelModel.getTitleForLevel(1),
          lastUpdated: DateTime.now(),
        );
      }

      final newTotalXP = userLevel.totalXP + points;
      int newLevel = userLevel.level;
      int xpToNext = userLevel.xpToNextLevel;
      bool leveledUp = false;

      // Check for level up
      while (newTotalXP >= xpToNext) {
        newLevel++;
        xpToNext = UserLevelModel.getXPForLevel(newLevel);
        leveledUp = true;
      }

      final updatedLevel = UserLevelModel(
        userId: userId,
        level: newLevel,
        totalXP: newTotalXP,
        xpToNextLevel: xpToNext,
        title: UserLevelModel.getTitleForLevel(newLevel),
        lastUpdated: DateTime.now(),
      );

      await userLevelRef.set(updatedLevel.toFirestore());

      // Log XP gain
      await _firestore.collection('xp_history').add({
        'userId': userId,
        'points': points,
        'action': action,
        'timestamp': Timestamp.now(),
        'levelBefore': userLevel.level,
        'levelAfter': newLevel,
      });

      // Check for badges if leveled up
      if (leveledUp) {
        await _checkLevelBadges(userId, newLevel);
      }

      return {
        'leveledUp': leveledUp,
        'newLevel': newLevel,
        'newTotalXP': newTotalXP,
        'newTitle': updatedLevel.title,
      };
    } catch (e) {
      throw Exception('Error awarding XP: $e');
    }
  }

  // Get user level
  Stream<UserLevelModel> getUserLevel(String userId) {
    return _firestore
        .collection('user_levels')
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return UserLevelModel.fromFirestore(doc);
      }
      return UserLevelModel(
        userId: userId,
        level: 1,
        totalXP: 0,
        xpToNextLevel: UserLevelModel.getXPForLevel(1),
        title: UserLevelModel.getTitleForLevel(1),
        lastUpdated: DateTime.now(),
      );
    });
  }

  // Get user badges
  Stream<List<BadgeModel>> getUserBadges(String userId) {
    return _firestore
        .collection('user_badges')
        .where('userId', isEqualTo: userId)
        .orderBy('earnedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BadgeModel.fromFirestore(doc))
            .toList());
  }

  // Award badge
  Future<void> awardBadge(String userId, String badgeId, String name, String description, String iconEmoji, BadgeRarity rarity) async {
    try {
      // Check if badge already earned
      final existing = await _firestore
          .collection('user_badges')
          .where('userId', isEqualTo: userId)
          .where('badgeId', isEqualTo: badgeId)
          .get();

      if (existing.docs.isEmpty) {
        await _firestore.collection('user_badges').add({
          'userId': userId,
          'badgeId': badgeId,
          'name': name,
          'description': description,
          'iconEmoji': iconEmoji,
          'rarity': rarity.toString().split('.').last,
          'earnedAt': Timestamp.now(),
        });
      }
    } catch (e) {
      throw Exception('Error awarding badge: $e');
    }
  }

  // Check and award level-based badges
  Future<void> _checkLevelBadges(String userId, int level) async {
    final levelBadges = {
      5: {'name': 'Rising Star', 'emoji': '⭐', 'desc': 'Reached Level 5'},
      10: {'name': 'Dedicated Learner', 'emoji': '📚', 'desc': 'Reached Level 10'},
      20: {'name': 'Knowledge Seeker', 'emoji': '🎓', 'desc': 'Reached Level 20'},
      35: {'name': 'Expert Scholar', 'emoji': '🏆', 'desc': 'Reached Level 35'},
      50: {'name': 'Grand Master', 'emoji': '👑', 'desc': 'Reached Level 50'},
    };

    if (levelBadges.containsKey(level)) {
      final badge = levelBadges[level]!;
      await awardBadge(
        userId,
        'level_$level',
        badge['name']!,
        badge['desc']!,
        badge['emoji']!,
        level >= 35 ? BadgeRarity.legendary : 
        level >= 20 ? BadgeRarity.epic :
        level >= 10 ? BadgeRarity.rare : BadgeRarity.common,
      );
    }
  }

  // Check course completion badges
  Future<void> checkCourseCompletionBadges(String userId, int coursesCompleted) async {
    final badges = {
      1: {'name': 'First Steps', 'emoji': '👣', 'desc': 'Completed first course'},
      5: {'name': 'Course Collector', 'emoji': '📖', 'desc': 'Completed 5 courses'},
      10: {'name': 'Course Master', 'emoji': '🎯', 'desc': 'Completed 10 courses'},
      25: {'name': 'Learning Legend', 'emoji': '🌟', 'desc': 'Completed 25 courses'},
    };

    if (badges.containsKey(coursesCompleted)) {
      final badge = badges[coursesCompleted]!;
      await awardBadge(
        userId,
        'courses_$coursesCompleted',
        badge['name']!,
        badge['desc']!,
        badge['emoji']!,
        coursesCompleted >= 25 ? BadgeRarity.legendary : 
        coursesCompleted >= 10 ? BadgeRarity.epic : BadgeRarity.rare,
      );
    }
  }

  // Get leaderboard
  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('user_levels')
          .orderBy('totalXP', descending: true)
          .limit(limit)
          .get();

      final List<Map<String, dynamic>> leaderboard = [];

      for (var doc in snapshot.docs) {
        final levelData = doc.data();
        final userDoc = await _firestore.collection('users').doc(doc.id).get();
        final userData = userDoc.data();

        leaderboard.add({
          'userId': doc.id,
          'userName': userData?['fullName'] ?? 'Anonymous',
          'level': levelData['level'] ?? 1,
          'totalXP': levelData['totalXP'] ?? 0,
          'title': levelData['title'] ?? 'Novice',
        });
      }

      return leaderboard;
    } catch (e) {
      throw Exception('Error fetching leaderboard: $e');
    }
  }

  // Get user rank
  Future<int> getUserRank(String userId) async {
    try {
      final userLevel = await _firestore
          .collection('user_levels')
          .doc(userId)
          .get();

      if (!userLevel.exists) return 0;

      final userXP = userLevel.data()?['totalXP'] ?? 0;

      final higherRanked = await _firestore
          .collection('user_levels')
          .where('totalXP', isGreaterThan: userXP)
          .get();

      return higherRanked.docs.length + 1;
    } catch (e) {
      return 0;
    }
  }
}
