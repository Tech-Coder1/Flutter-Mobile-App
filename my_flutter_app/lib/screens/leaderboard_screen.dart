import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/gamification_service.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final GamificationService _gamificationService = GamificationService();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  List<Map<String, dynamic>> _leaderboardData = [];
  int _currentUserRank = 0;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);
    try {
      final userId = _authService.currentUser?.uid ?? '';
      final data = await _gamificationService.getLeaderboard(limit: 50);
      final rank = await _gamificationService.getUserRank(userId);
      
      setState(() {
        _leaderboardData = data;
        _currentUserRank = rank;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading leaderboard: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeService>(context).isDarkMode;
    final currentUserId = _authService.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLeaderboard,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadLeaderboard,
              child: Column(
                children: [
                  // Current User Rank Card
                  if (_currentUserRank > 0)
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4169E1), Color(0xFF5B7FE8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4169E1).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Your Rank',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '#$_currentUserRank',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.emoji_events,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Leaderboard List
                  Expanded(
                    child: _leaderboardData.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.leaderboard_outlined,
                                  size: 80,
                                  color: isDark ? Colors.white24 : Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No leaderboard data yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: isDark ? Colors.white60 : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: _leaderboardData.length,
                            itemBuilder: (context, index) {
                              final entry = _leaderboardData[index];
                              final rank = index + 1;
                              final userId = entry['userId'] as String;
                              final userName = entry['userName'] as String? ?? 'User';
                              final totalXP = entry['totalXP'] as int? ?? 0;
                              final level = entry['level'] as int? ?? 1;
                              final isCurrentUser = userId == currentUserId;

                              return _buildLeaderboardCard(
                                rank: rank,
                                userName: userName,
                                totalXP: totalXP,
                                level: level,
                                isCurrentUser: isCurrentUser,
                                isDark: isDark,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLeaderboardCard({
    required int rank,
    required String userName,
    required int totalXP,
    required int level,
    required bool isCurrentUser,
    required bool isDark,
  }) {
    Color rankColor;
    IconData? rankIcon;

    if (rank == 1) {
      rankColor = Colors.amber;
      rankIcon = Icons.emoji_events;
    } else if (rank == 2) {
      rankColor = Colors.grey[400]!;
      rankIcon = Icons.emoji_events;
    } else if (rank == 3) {
      rankColor = Colors.brown[300]!;
      rankIcon = Icons.emoji_events;
    } else {
      rankColor = isDark ? Colors.white70 : Colors.grey[600]!;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isCurrentUser ? 4 : 1,
      color: isCurrentUser
          ? (isDark
              ? const Color(0xFF4169E1).withValues(alpha: 0.1)
              : const Color(0xFF4169E1).withValues(alpha: 0.05))
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Rank Badge
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: rankColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: rankIcon != null
                    ? Icon(rankIcon, color: rankColor, size: 24)
                    : Text(
                        '#$rank',
                        style: TextStyle(
                          color: rankColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          userName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: isCurrentUser ? const Color(0xFF4169E1) : null,
                          ),
                        ),
                      ),
                      if (isCurrentUser) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4169E1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'YOU',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Level $level • $totalXP XP',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white60 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Trophy Icon for top 3
            if (rank <= 3)
              Icon(
                Icons.emoji_events,
                color: rankColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
