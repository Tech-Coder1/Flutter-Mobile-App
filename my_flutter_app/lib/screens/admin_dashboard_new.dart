import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/course_service.dart';
import '../services/internship_service.dart';
import '../services/application_service.dart';
import '../services/admin_statistics_service.dart';
import '../widgets/admin_sidebar.dart';
import '../models/activity_log_model.dart';

class AdminDashboardNew extends StatefulWidget {
  const AdminDashboardNew({super.key});

  @override
  State<AdminDashboardNew> createState() => _AdminDashboardNewState();
}

class _AdminDashboardNewState extends State<AdminDashboardNew> {
  final authService = AuthService();
  final userService = UserService();
  final courseService = CourseService();
  final internshipService = InternshipService();
  final applicationService = ApplicationService();
  final adminStatisticsService = AdminStatisticsService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AdminSidebar(currentRoute: '/admin_dashboard'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dashboard Overview',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1A1A1A),
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Monitor your platform performance',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: const Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                      Text(
                        _getGreeting(),
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // KPI Cards Row
                  _buildKPICards(),
                  const SizedBox(height: 32),

                  // Action Required Section
                  _buildActionRequiredSection(),
                  const SizedBox(height: 32),

                  // Charts Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildEnrollmentTrendChart()),
                      const SizedBox(width: 24),
                      Expanded(child: _buildApplicationStatusPieChart()),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Recent Activity
                  _buildRecentActivity(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPICards() {
    return Row(
      children: [
        Expanded(
          child: _buildCompactKPICard(
            title: 'Total Users',
            icon: Icons.people_outline,
            color: const Color(0xFF4169E1),
            future: userService.getUserCount(),
            route: '/admin_users',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildCompactKPICard(
            title: 'Active Courses',
            icon: Icons.book_outlined,
            color: const Color(0xFF10B981),
            future: courseService.getCourseCount(),
            route: '/admin_courses',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildCompactKPICard(
            title: 'Active Internships',
            icon: Icons.work_outline,
            color: const Color(0xFF8B5CF6),
            future: internshipService.getInternshipCount(),
            route: '/admin_internships',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildCompactKPICard(
            title: 'Pending Applications',
            icon: Icons.pending_actions_outlined,
            color: const Color(0xFFF59E0B),
            future: _countApplicationsByStatus('pending'),
            route: '/admin_application_review',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FutureBuilder<double>(
            future: _getApprovalRate(),
            builder: (context, snapshot) {
              return _buildCompactKPICard(
                title: 'Approval Rate',
                icon: Icons.trending_up,
                color: const Color(0xFF06B6D4),
                value: snapshot.hasData
                    ? '${snapshot.data!.toStringAsFixed(1)}%'
                    : '...',
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCompactKPICard({
    required String title,
    required IconData icon,
    required Color color,
    Future<int>? future,
    String? value,
    String? route,
  }) {
    return InkWell(
      onTap: route != null
          ? () => Navigator.pushReplacementNamed(context, route)
          : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                if (route != null)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: const Color(0xFF9CA3AF),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            if (value != null)
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              )
            else if (future != null)
              FutureBuilder<int>(
                future: future,
                builder: (context, snapshot) {
                  return Text(
                    snapshot.hasData ? '${snapshot.data}' : '...',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRequiredSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4169E1).withValues(alpha: 0.05),
            const Color(0xFF8B5CF6).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4169E1).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.notifications_active_outlined,
                color: const Color(0xFF4169E1),
              ),
              const SizedBox(width: 12),
              const Text(
                'Action Required',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildActionItem(
                  'Pending Applications',
                  _countApplicationsByStatus('pending'),
                  Icons.assignment_outlined,
                  const Color(0xFFF59E0B),
                  '/admin_application_review',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionItem(
                  'New Support Tickets',
                  _countOpenTickets(),
                  Icons.support_agent_outlined,
                  const Color(0xFFEF4444),
                  '/admin_support_tickets',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionItem(
                  'New Feedback',
                  _countNewFeedback(),
                  Icons.feedback_outlined,
                  const Color(0xFF8B5CF6),
                  '/admin_feedback',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    String title,
    Future<int> countFuture,
    IconData icon,
    Color color,
    String route,
  ) {
    return FutureBuilder<int>(
      future: countFuture,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return InkWell(
          onTap: () => Navigator.pushReplacementNamed(context, route),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: const Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnrollmentTrendChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enrollment Trend',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Last 6 months',
            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 24),
          FutureBuilder<List<dynamic>>(
            future: adminStatisticsService.getEnrollmentTrend(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox(
                  height: 200,
                  child: Center(
                    child: Text(
                      'No enrollment data yet',
                      style: TextStyle(color: Color(0xFF9CA3AF)),
                    ),
                  ),
                );
              }

              final trendData = snapshot.data!;
              return SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY:
                        (trendData
                            .fold<int>(
                              0,
                              (max, item) => item.enrollments > max
                                  ? item.enrollments
                                  : max,
                            )
                            .toDouble() +
                        10),
                    barTouchData: BarTouchData(enabled: true),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() < trendData.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  trendData[value.toInt()].month,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF6B7280),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: const Color(0xFFE5E7EB),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(
                      trendData.length,
                      (index) => BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: trendData[index].enrollments.toDouble(),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4169E1), Color(0xFF8B5CF6)],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            width: 20,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationStatusPieChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Applications',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Status distribution',
            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 24),
          FutureBuilder<Map<String, int>>(
            future: _getApplicationStats(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (!snapshot.hasData) {
                return const SizedBox(
                  height: 200,
                  child: Center(
                    child: Text(
                      'No application data',
                      style: TextStyle(color: Color(0xFF9CA3AF)),
                    ),
                  ),
                );
              }

              final stats = snapshot.data!;
              final total = stats.values.fold<int>(0, (sum, val) => sum + val);

              if (total == 0) {
                return const SizedBox(
                  height: 200,
                  child: Center(
                    child: Text(
                      'No applications yet',
                      style: TextStyle(color: Color(0xFF9CA3AF)),
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 200,
                child: Row(
                  children: [
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: [
                            PieChartSectionData(
                              value: stats['pending']!.toDouble(),
                              title:
                                  '${((stats['pending']! / total) * 100).toInt()}%',
                              color: const Color(0xFFF59E0B),
                              radius: 50,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              value: stats['approved']!.toDouble(),
                              title:
                                  '${((stats['approved']! / total) * 100).toInt()}%',
                              color: const Color(0xFF10B981),
                              radius: 50,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              value: stats['rejected']!.toDouble(),
                              title:
                                  '${((stats['rejected']! / total) * 100).toInt()}%',
                              color: const Color(0xFFEF4444),
                              radius: 50,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLegendItem(
                          'Pending',
                          stats['pending']!,
                          const Color(0xFFF59E0B),
                        ),
                        const SizedBox(height: 8),
                        _buildLegendItem(
                          'Approved',
                          stats['approved']!,
                          const Color(0xFF10B981),
                        ),
                        const SizedBox(height: 8),
                        _buildLegendItem(
                          'Rejected',
                          stats['rejected']!,
                          const Color(0xFFEF4444),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
        const SizedBox(width: 4),
        Text(
          '($count)',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              TextButton(
                onPressed: () {
                  // View all activity
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<ActivityLogModel>>(
            stream: adminStatisticsService.getActivityLog(limit: 8),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Text(
                      'No recent activity',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                );
              }

              final activities = snapshot.data!;
              return Column(
                children: activities
                    .map((activity) => _buildActivityItem(activity))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(ActivityLogModel activity) {
    IconData icon;
    Color color;

    switch (activity.type) {
      case 'user_signup':
        icon = Icons.person_add_outlined;
        color = const Color(0xFF4169E1);
        break;
      case 'course_enrollment':
        icon = Icons.bookmark_add_outlined;
        color = const Color(0xFF10B981);
        break;
      case 'internship_application':
        icon = Icons.work_outline;
        color = const Color(0xFFF59E0B);
        break;
      case 'course_completion':
        icon = Icons.verified_outlined;
        color = const Color(0xFF8B5CF6);
        break;
      default:
        icon = Icons.info_outlined;
        color = const Color(0xFF6B7280);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.action,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity.userName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatTime(activity.timestamp),
            style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning ☀️';
    if (hour < 17) return 'Good afternoon 🌤️';
    return 'Good evening 🌙';
  }

  Future<int> _countApplicationsByStatus(String status) async {
    try {
      final applicationsStream = applicationService.getAllApplications();
      final firstEmission = await applicationsStream.first;
      return firstEmission.where((app) => app.status == status).length;
    } catch (e) {
      debugPrint('Error counting applications: $e');
      return 0;
    }
  }

  Future<double> _getApprovalRate() async {
    try {
      final applicationsStream = applicationService.getAllApplications();
      final firstEmission = await applicationsStream.first;
      final total = firstEmission.length;
      if (total == 0) return 0.0;
      final approved = firstEmission
          .where((app) => app.status == 'approved')
          .length;
      return (approved / total) * 100;
    } catch (e) {
      debugPrint('Error calculating approval rate: $e');
      return 0.0;
    }
  }

  Future<Map<String, int>> _getApplicationStats() async {
    try {
      final applicationsStream = applicationService.getAllApplications();
      final firstEmission = await applicationsStream.first;
      return {
        'pending': firstEmission.where((app) => app.status == 'pending').length,
        'approved': firstEmission
            .where((app) => app.status == 'approved')
            .length,
        'rejected': firstEmission
            .where((app) => app.status == 'rejected')
            .length,
      };
    } catch (e) {
      debugPrint('Error getting application stats: $e');
      return {'pending': 0, 'approved': 0, 'rejected': 0};
    }
  }

  Future<int> _countOpenTickets() async {
    // Placeholder - implement when ticket service is available
    return 0;
  }

  Future<int> _countNewFeedback() async {
    // Placeholder - implement when feedback service is available
    return 0;
  }
}
