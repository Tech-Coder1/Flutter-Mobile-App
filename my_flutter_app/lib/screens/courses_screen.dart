import 'package:flutter/material.dart';
import '../services/course_service.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../models/course_model.dart';
import 'course_detail_screen.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final CourseService _courseService = CourseService();
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedLevel = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = _authService.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Courses'),
        backgroundColor: const Color(0xFF4169E1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search & Filter header
          Container(
            color: const Color(0xFF4169E1),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search courses...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Beginner'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Intermediate'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Advanced'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // List content
          Expanded(
            child: StreamBuilder<List<CourseModel>>(
              stream: _courseService.getAllCourses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                      ],
                    ),
                  );
                }

                final allCourses = snapshot.data ?? [];
                if (allCourses.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school_outlined, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No courses available yet'),
                      ],
                    ),
                  );
                }

                final filteredCourses = allCourses.where((course) {
                  final q = _searchQuery.trim().toLowerCase();
                  final matchesSearch = q.isEmpty ||
                      course.title.toLowerCase().contains(q) ||
                      course.description.toLowerCase().contains(q);
                  final matchesLevel = _selectedLevel == 'All' || course.level == _selectedLevel;
                  return matchesSearch && matchesLevel;
                }).toList();

                if (filteredCourses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No courses match your search',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(24.0),
                  itemCount: filteredCourses.length,
                  itemBuilder: (context, index) {
                    final course = filteredCourses[index];
                    final isEnrolled = userId != null && course.enrolledUsers.contains(userId);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CourseDetailScreen(course: course),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      course.title,
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF1A1A1A),
                                          ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _getLevelColor(course.level),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      course.level,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.schedule, size: 16, color: Color(0xFF6B7280)),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Duration: ${course.duration}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: const Color(0xFF6B7280),
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                course.description,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: const Color(0xFF374151),
                                    ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CourseDetailScreen(course: course),
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Color(0xFF4169E1)),
                                      ),
                                      child: const Text('View Details'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: isEnrolled ? null : () => _enrollInCourse(course),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            isEnrolled ? Colors.grey : const Color(0xFF4169E1),
                                      ),
                                      child: Text(isEnrolled ? 'Enrolled' : 'Enroll Now'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  Future<void> _enrollInCourse(CourseModel course) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to enroll'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    try {
      await _courseService.enrollUserInCourse(course.courseId, userId);
      await _notificationService.sendEnrollmentNotification(
        userId: userId,
        courseTitle: course.title,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully enrolled in course!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error enrolling: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildFilterChip(String level) {
    final selected = _selectedLevel == level;
    return ChoiceChip(
      label: Text(level),
      selected: selected,
      onSelected: (_) => setState(() => _selectedLevel = level),
      selectedColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? const Color(0xFF4169E1) : Colors.white,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: Colors.white.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      pressElevation: 0,
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Beginner':
        return Colors.green;
      case 'Intermediate':
        return Colors.orange;
      case 'Advanced':
        return Colors.red;
      default:
        return const Color(0xFF4169E1);
    }
  }
}