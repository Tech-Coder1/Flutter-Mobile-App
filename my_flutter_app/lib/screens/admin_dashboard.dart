import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/course_service.dart';
import '../services/internship_service.dart';
import '../services/application_service.dart';
import '../services/admin_statistics_service.dart';
import '../services/admin_content_service.dart';
import '../models/activity_log_model.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final authService = AuthService();
  final userService = UserService();
  final courseService = CourseService();
  final internshipService = InternshipService();
  final applicationService = ApplicationService();
  final adminStatisticsService = AdminStatisticsService();
  final adminContentService = AdminContentService();

  // Quick add controllers
  final _courseTitleController = TextEditingController();
  final _courseDurationController = TextEditingController();
  final _courseLevelController = TextEditingController();
  final _courseDescriptionController = TextEditingController();

  final _internRoleController = TextEditingController();
  final _internCompanyController = TextEditingController();
  final _internLocationController = TextEditingController();
  final _internTypeController = TextEditingController();
  final _internDescriptionController = TextEditingController();

  bool _creatingCourse = false;
  bool _creatingInternship = false;

  @override
  void dispose() {
    _courseTitleController.dispose();
    _courseDurationController.dispose();
    _courseLevelController.dispose();
    _courseDescriptionController.dispose();
    _internRoleController.dispose();
    _internCompanyController.dispose();
    _internLocationController.dispose();
    _internTypeController.dispose();
    _internDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Text(
              'Platform Analytics',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Real-time dashboard metrics and insights',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B7280)),
            ),
            const SizedBox(height: 32),

            // Statistics Cards - 2x2 Grid
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStatCard(
                  title: 'Total Users',
                  icon: Icons.people_outline,
                  color: const Color(0xFF4169E1),
                  future: userService.getUserCount(),
                ),
                _buildStatCard(
                  title: 'Total Courses',
                  icon: Icons.book_outlined,
                  color: const Color(0xFFFF6B6B),
                  future: courseService.getCourseCount(),
                ),
                _buildStatCard(
                  title: 'Total Internships',
                  icon: Icons.work_outline,
                  color: const Color(0xFF51CF66),
                  future: internshipService.getInternshipCount(),
                ),
                _buildStatCard(
                  title: 'Total Enrollments',
                  icon: Icons.check_circle_outline,
                  color: const Color(0xFFFFA94D),
                  future: _getTotalEnrollments(),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Application Status Overview
            Text(
              'Application Status',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatusCard(
                    label: 'Pending',
                    color: Colors.orange,
                    future: _countApplicationsByStatus('pending'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatusCard(
                    label: 'Approved',
                    color: Colors.green,
                    future: _countApplicationsByStatus('approved'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatusCard(
                    label: 'Rejected',
                    color: Colors.red,
                    future: _countApplicationsByStatus('rejected'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Enrollment Trend Chart
            Text(
              'Enrollment Trend (Last 6 Months)',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FutureBuilder<List<dynamic>>(
                  future: adminStatisticsService.getEnrollmentTrend(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 250,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const SizedBox(
                        height: 250,
                        child: Center(child: Text('No data available')),
                      );
                    }

                    final trendData = snapshot.data!;
                    return SizedBox(
                      height: 250,
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
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() < trendData.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        trendData[value.toInt()].month,
                                        style: const TextStyle(fontSize: 12),
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
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(fontSize: 10),
                                  );
                                },
                              ),
                            ),
                          ),
                          gridData: const FlGridData(show: true),
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(
                            trendData.length,
                            (index) => BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: trendData[index].enrollments.toDouble(),
                                  color: const Color(0xFF4169E1),
                                  width: 16,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Recent Activity Feed
            Text(
              'Recent Activity',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<ActivityLogModel>>(
              stream: adminStatisticsService.getActivityLog(limit: 10),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(
                          'No activity yet',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  );
                }

                final activities = snapshot.data!;
                return Column(
                  children: activities.map((activity) {
                    return _buildActivityItem(context, activity);
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 32),

            // Content creation shortcuts
            Text(
              'Add Content',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;
                return Flex(
                  direction: isWide ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildCreateCourseCard()),
                    if (isWide)
                      const SizedBox(width: 16)
                    else
                      const SizedBox(height: 16),
                    Expanded(child: _buildCreateInternshipCard()),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            // Admin Actions
            Text(
              'Quick Actions',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    Navigator.pushNamed(context, '/admin_application_review'),
                icon: const Icon(Icons.assessment_outlined),
                label: const Text('Review Applications'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF4169E1),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    Navigator.pushNamed(context, '/admin_support_tickets'),
                icon: const Icon(Icons.support_agent_outlined),
                label: const Text('View Support Tickets'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF51CF66),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required IconData icon,
    required Color color,
    required Future<int> future,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280)),
            ),
            const SizedBox(height: 8),
            FutureBuilder<int>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text(
                    '...',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  );
                }
                return Text(
                  '${snapshot.data ?? 0}',
                  style: const TextStyle(
                    fontSize: 24,
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

  Widget _buildStatusCard({
    required String label,
    required Color color,
    required Future<int> future,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FutureBuilder<int>(
              future: future,
              builder: (context, snapshot) {
                return Text(
                  '${snapshot.data ?? 0}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, ActivityLogModel activity) {
    IconData icon;
    Color color;

    switch (activity.type) {
      case 'user_signup':
        icon = Icons.person_add_outlined;
        color = Colors.blue;
        break;
      case 'course_enrollment':
        icon = Icons.check_circle_outline;
        color = Colors.green;
        break;
      case 'internship_application':
        icon = Icons.work_outline;
        color = Colors.orange;
        break;
      case 'course_completion':
        icon = Icons.done_all_outlined;
        color = Colors.purple;
        break;
      default:
        icon = Icons.info_outlined;
        color = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(activity.action),
        subtitle: Text(
          '${activity.userName} • ${_formatTime(activity.timestamp)}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Text(
          activity.type.replaceAll('_', ' ').toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
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

  Future<int> _getTotalEnrollments() async {
    try {
      final courseStream = courseService.getAllCourses();
      final firstEmission = await courseStream.first;
      int total = 0;
      for (var course in firstEmission) {
        total += course.enrolledUsers.length;
      }
      return total;
    } catch (e) {
      debugPrint('Error getting total enrollments: $e');
      return 0;
    }
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

  Widget _buildCreateCourseCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Create Course',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Icon(Icons.book_outlined, color: Color(0xFF4169E1)),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _courseTitleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _courseDurationController,
              decoration: const InputDecoration(
                labelText: 'Duration (e.g., 6 weeks)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _courseLevelController,
              decoration: const InputDecoration(
                labelText: 'Level (Beginner / Intermediate / Advanced)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _courseDescriptionController,
              decoration: const InputDecoration(labelText: 'Short description'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _creatingCourse ? null : _handleCreateCourse,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: const Color(0xFF4169E1),
                  foregroundColor: Colors.white,
                ),
                child: _creatingCourse
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Publish Course'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCreateCourse() async {
    if (_courseTitleController.text.trim().isEmpty ||
        _courseDurationController.text.trim().isEmpty ||
        _courseLevelController.text.trim().isEmpty ||
        _courseDescriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all course fields')),
      );
      return;
    }

    setState(() => _creatingCourse = true);
    try {
      await adminContentService.createCourse(
        title: _courseTitleController.text.trim(),
        duration: _courseDurationController.text.trim(),
        level: _courseLevelController.text.trim(),
        description: _courseDescriptionController.text.trim(),
        createdBy: authService.currentUser?.uid ?? 'admin',
      );

      _courseTitleController.clear();
      _courseDurationController.clear();
      _courseLevelController.clear();
      _courseDescriptionController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course created successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create course: $e')));
    } finally {
      if (mounted) setState(() => _creatingCourse = false);
    }
  }

  Widget _buildCreateInternshipCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Create Internship',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Icon(Icons.work_outline, color: Color(0xFF51CF66)),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _internRoleController,
              decoration: const InputDecoration(labelText: 'Role'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _internCompanyController,
              decoration: const InputDecoration(labelText: 'Company'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _internLocationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _internTypeController,
              decoration: const InputDecoration(
                labelText: 'Type (Remote / Onsite / Hybrid)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _internDescriptionController,
              decoration: const InputDecoration(labelText: 'Short description'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _creatingInternship ? null : _handleCreateInternship,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: const Color(0xFF51CF66),
                  foregroundColor: Colors.white,
                ),
                child: _creatingInternship
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Publish Internship'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCreateInternship() async {
    if (_internRoleController.text.trim().isEmpty ||
        _internCompanyController.text.trim().isEmpty ||
        _internLocationController.text.trim().isEmpty ||
        _internTypeController.text.trim().isEmpty ||
        _internDescriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all internship fields')),
      );
      return;
    }

    setState(() => _creatingInternship = true);
    try {
      await adminContentService.createInternship(
        role: _internRoleController.text.trim(),
        company: _internCompanyController.text.trim(),
        location: _internLocationController.text.trim(),
        type: _internTypeController.text.trim(),
        description: _internDescriptionController.text.trim(),
        postedBy: authService.currentUser?.uid ?? 'admin',
      );

      _internRoleController.clear();
      _internCompanyController.clear();
      _internLocationController.clear();
      _internTypeController.clear();
      _internDescriptionController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Internship created successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create internship: $e')),
      );
    } finally {
      if (mounted) setState(() => _creatingInternship = false);
    }
  }
}
