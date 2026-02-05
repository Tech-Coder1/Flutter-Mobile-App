import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/gamification_service.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
import '../models/gamification_model.dart';
import 'dart:math' as math;

class LevelScreen extends StatelessWidget {
  const LevelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final gamificationService = GamificationService();
    final userId = authService.currentUser?.uid ?? '';
    final isDark = Provider.of<ThemeService>(context).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Level & Progress'),
        elevation: 0,
      ),
      body: StreamBuilder<UserLevelModel>(
        stream: gamificationService.getUserLevel(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userLevel = snapshot.data;
          if (userLevel == null) {
            return const Center(child: Text('No level data available'));
          }

          final progress = userLevel.totalXP / userLevel.xpToNextLevel;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Level Circle with Progress Ring
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Progress Ring
                      CustomPaint(
                        size: const Size(200, 200),
                        painter: _ProgressRingPainter(
                          progress: progress.clamp(0.0, 1.0),
                          ringColor: const Color(0xFF4169E1),
                          backgroundColor: isDark
                              ? const Color(0xFF2C3440)
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      // Level Number
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Level',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.white70 : Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${userLevel.level}',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4169E1),
                            ),
                          ),
                          Text(
                            userLevel.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white70 : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // XP Progress Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'XP Progress',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${userLevel.totalXP} / ${userLevel.xpToNextLevel} XP',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? Colors.white70 : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            minHeight: 12,
                            backgroundColor: isDark
                                ? const Color(0xFF2C3440)
                                : const Color(0xFFE5E7EB),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF4169E1),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${userLevel.xpToNextLevel - userLevel.totalXP} XP to Level ${userLevel.level + 1}',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white60 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // XP Actions Guide
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Earn XP by:',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildXPActionCard(
                  icon: Icons.play_lesson_outlined,
                  title: 'Complete a Lesson',
                  xp: XPAction.completeLesson,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _buildXPActionCard(
                  icon: Icons.quiz_outlined,
                  title: 'Complete a Quiz',
                  xp: XPAction.completeQuiz,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _buildXPActionCard(
                  icon: Icons.star_outline,
                  title: 'Perfect Quiz Score',
                  xp: XPAction.perfectQuiz,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _buildXPActionCard(
                  icon: Icons.school_outlined,
                  title: 'Complete a Course',
                  xp: XPAction.completeCourse,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _buildXPActionCard(
                  icon: Icons.login_outlined,
                  title: 'Daily Login',
                  xp: XPAction.dailyLogin,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _buildXPActionCard(
                  icon: Icons.feedback_outlined,
                  title: 'Submit Feedback',
                  xp: XPAction.submitFeedback,
                  isDark: isDark,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildXPActionCard({
    required IconData icon,
    required String title,
    required int xp,
    required bool isDark,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF4169E1).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF4169E1)),
        ),
        title: Text(title),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF4169E1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '+$xp XP',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color ringColor;
  final Color backgroundColor;

  _ProgressRingPainter({
    required this.progress,
    required this.ringColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 12.0;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2; // Start from top
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.ringColor != ringColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
