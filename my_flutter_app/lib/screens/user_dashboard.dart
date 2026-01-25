import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/course_service.dart';
import '../services/internship_service.dart';
import '../services/notification_service.dart';
import '../services/progress_service.dart';
import '../models/user_model.dart';
import '../models/notification_model.dart';
import '../models/course_model.dart';
import '../models/progress_model.dart';
import 'courses_screen.dart';
import 'internships_screen.dart';
import 'profile_screen.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CoursesScreen(),
    const InternshipsScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Internships',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {  Widget _progressSummaryCard(
    BuildContext context, {
    required int pending,
    required int inProgress,
    required int completed,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _summaryItem('Pending', pending, Colors.orange),
            const SizedBox(width: 12),
            _summaryItem('In Progress', inProgress, const Color(0xFF4169E1)),
            const SizedBox(width: 12),
            _summaryItem('Completed', completed, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String label, int value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _courseListSection(
    BuildContext context, {
    required String title,
    required List<MapEntry<CourseModel, ProgressModel?>> items,
    required bool showProgress,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        ...items.map((entry) {
          final course = entry.key;
          final progress = entry.value;
          final percent = progress?.completionPercentage ?? 0;
          return Card(
            child: ListTile(
              title: Text(course.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.duration),
                  if (showProgress)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LinearProgressIndicator(
                            value: percent / 100,
                            backgroundColor: Colors.grey[300],
                            valueColor: const AlwaysStoppedAnimation(Color(0xFF4169E1)),
                          ),
                          const SizedBox(height: 4),
                          Text('$percent% completed',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                        ],
                      ),
                    ),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(
                context,
                '/course_detail',
                arguments: course,
              ),
            ),
          );
        }),
      ],
    );
  }
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final userService = UserService();
    final courseService = CourseService();
    final internshipService = InternshipService();
    final notificationService = NotificationService();
    final progressService = ProgressService();
    final userId = authService.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Excelerate'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => Navigator.pushNamed(context, '/inbox'),
              ),
              StreamBuilder<int>(
                stream: notificationService.getUnreadNotificationCount(userId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == 0) {
                    return const SizedBox.shrink();
                  }
                  return Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Text(
                        '${snapshot.data}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<UserModel?>(
              stream: userService.getUserStream(userId),
              builder: (context, snapshot) {
                final userName = snapshot.data?.fullName ?? 'User';
                return Text(
                  'Welcome back, $userName!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A1A),
                      ),
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              'Explore Opportunities',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StreamBuilder<int>(
                    stream: courseService.getAllCourses().map((courses) => courses.length),
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? 0;
                      return GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/courses'),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                const Icon(Icons.book_outlined, size: 32, color: Color(0xFF4169E1)),
                                const SizedBox(height: 12),
                                const Text('Courses'),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4169E1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StreamBuilder<int>(
                    stream: internshipService.getAllInternships().map((internships) => internships.length),
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? 0;
                      return GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/internships'),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                            children: [
                              const Icon(Icons.work_outline, size: 32, color: Color(0xFF4169E1)),
                              const SizedBox(height: 12),
                              const Text('Internships'),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4169E1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$count',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // My Courses with progress tracking
            Text(
              'My Courses',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<CourseModel>>(
              stream: courseService.getAllCourses(),
              builder: (context, courseSnap) {
                if (courseSnap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final courses = courseSnap.data ?? [];
                final enrolledCourses = courses
                    .where((c) => c.enrolledUsers.contains(userId))
                    .toList();

                if (enrolledCourses.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: const [
                          Icon(Icons.book_outlined, color: Color(0xFF4169E1)),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text('You have not enrolled in any courses yet'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return StreamBuilder<List<ProgressModel>>(
                  stream: progressService.getUserProgressList(userId),
                  builder: (context, progSnap) {
                    if (progSnap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final progressMap = {
                      for (final p in progSnap.data ?? []) p.courseId: p
                    };

                    final inProgress = <MapEntry<CourseModel, ProgressModel?>>[];
                    final pending = <CourseModel>[];
                    final completed = <MapEntry<CourseModel, ProgressModel?>>[];

                    for (final course in enrolledCourses) {
                      final p = progressMap[course.courseId];
                      final percent = p?.completionPercentage ?? 0;
                      if (percent >= 100) {
                        completed.add(MapEntry(course, p));
                      } else if (percent > 0) {
                        inProgress.add(MapEntry(course, p));
                      } else {
                        pending.add(course);
                      }
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _progressSummaryCard(
                          context,
                          pending: pending.length,
                          inProgress: inProgress.length,
                          completed: completed.length,
                        ),
                        const SizedBox(height: 12),
                        if (inProgress.isNotEmpty)
                          _courseListSection(
                            context,
                            title: 'In Progress',
                            items: inProgress,
                            showProgress: true,
                          ),
                        if (pending.isNotEmpty)
                          _courseListSection(
                            context,
                            title: 'Pending',
                            items: pending
                                .map((c) => MapEntry<CourseModel, ProgressModel?>(c, null))
                                .toList(),
                            showProgress: false,
                          ),
                        if (completed.isNotEmpty)
                          _courseListSection(
                            context,
                            title: 'Completed',
                            items: completed,
                            showProgress: true,
                          ),
                      ],
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 32),
            Text(
              'Recent Notifications',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<NotificationModel>>(
              stream: notificationService.getNotificationsForUser(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final notifications = snapshot.data ?? [];
                final recentNotifications = notifications.take(5).toList();

                if (recentNotifications.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.notifications_none, size: 48, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              'No notifications yet',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children: recentNotifications.map((notification) {
                    final icon = notification.type == 'course' ? Icons.school : Icons.work;
                    final color = notification.type == 'course' ? const Color(0xFF4169E1) : Colors.green;

                    return Card(
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(icon, color: color),
                        ),
                        title: Text(notification.title),
                        subtitle: Text(notification.message),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        onTap: () async {
                          if (!notification.isRead) {
                            await notificationService.markAsRead(notification.notificationId);
                          }
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}