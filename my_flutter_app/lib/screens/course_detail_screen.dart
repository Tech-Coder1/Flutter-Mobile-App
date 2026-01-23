import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/course_model.dart';
import '../services/course_service.dart';
import '../services/auth_service.dart';

class CourseDetailScreen extends StatefulWidget {
  final CourseModel course;

  const CourseDetailScreen({
    Key? key,
    required this.course,
  }) : super(key: key);

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final CourseService courseService = CourseService();
  late CourseModel course;
  bool isEnrolled = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    course = widget.course;
    _checkEnrollmentStatus();
  }

  Future<void> _checkEnrollmentStatus() async {
    try {
      final currentUser = AuthService().currentUser;
      final userId = currentUser?.uid;
      if (userId != null) {
        final enrolled = course.enrolledUsers.contains(userId);
        setState(() => isEnrolled = enrolled);
      }
    } catch (e) {
      debugPrint('Error checking enrollment: $e');
    }
  }

  Future<void> _enrollCourse() async {
    setState(() => isLoading = true);
    try {
      final currentUser = AuthService().currentUser;
      final userId = currentUser?.uid;
      if (userId != null) {
        // Add user to enrolled list
        final updatedCourse = course.copyWith(
          enrolledUsers: [...course.enrolledUsers, userId],
        );
        
        await courseService.updateCourse(course.courseId, updatedCourse.toFirestore());
        
        setState(() {
          course = updatedCourse;
          isEnrolled = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Enrolled successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Details'),
        backgroundColor: const Color(0xFF4169E1),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gradient background
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF4169E1),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    spacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha:0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          course.level.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha:0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          course.duration,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Rating
                  if (course.rating > 0)
                    Row(
                      spacing: 8,
                      children: [
                        RatingBarIndicator(
                          rating: course.rating,
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 18,
                          unratedColor: Colors.white.withValues(alpha:0.3),
                        ),
                        Text(
                          '${course.rating.toStringAsFixed(1)}/5.0',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 24,
                children: [
                  // Instructor info
                  if (course.instructorName.isNotEmpty)
                    _buildInfoCard(
                      title: 'Instructor',
                      icon: Icons.person_outline,
                      content: course.instructorName,
                    ),
                  
                  // Daily learning time
                  if (course.dailyLearningTime > 0)
                    _buildInfoCard(
                      title: 'Daily Learning Time',
                      icon: Icons.schedule,
                      content: '${course.dailyLearningTime} hours per day',
                    ),

                  // Description
                  _buildSection(
                    title: 'About Course',
                    child: Text(
                      course.description,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Color(0xFF555555),
                      ),
                    ),
                  ),

                  // Skills
                  if (course.skills.isNotEmpty)
                    _buildSection(
                      title: 'Skills You\'ll Learn',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: course.skills
                            .map(
                              (skill) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4169E1)
                                      .withValues(alpha:0.1),
                                  border: Border.all(
                                    color: const Color(0xFF4169E1),
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  skill,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF4169E1),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),

                  // Prerequisites
                  if (course.prerequisites.isNotEmpty)
                    _buildExpandableSection(
                      title: 'Prerequisites',
                      items: course.prerequisites,
                    ),

                  // Syllabus
                  if (course.syllabus.isNotEmpty)
                    _buildExpandableSection(
                      title: 'Course Syllabus',
                      items: course.syllabus,
                    ),

                  // Enrollment info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4169E1).withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      spacing: 8,
                      children: [
                        const Icon(
                          Icons.people_outline,
                          color: Color(0xFF4169E1),
                          size: 18,
                        ),
                        Text(
                          '${course.enrolledUsers.length} students enrolled',
                          style: const TextStyle(
                            color: Color(0xFF4169E1),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Enroll button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading || isEnrolled ? null : _enrollCourse,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isEnrolled
                            ? Colors.green
                            : const Color(0xFF4169E1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        isLoading
                            ? 'Enrolling...'
                            : isEnrolled
                                ? 'Already Enrolled ✓'
                                : 'Enroll Now',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Row(
      spacing: 12,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF4169E1).withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF4169E1),
            size: 20,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        child,
      ],
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required List<String> items,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: Color(0xFF555555),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
