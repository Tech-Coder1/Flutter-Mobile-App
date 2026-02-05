import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';
import '../models/feedback_model.dart';
import '../services/course_service.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/progress_service.dart';
import '../services/feedback_service.dart';

class CourseDetailScreen extends StatefulWidget {
  final CourseModel course;

  const CourseDetailScreen({
    super.key,
    required this.course,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final CourseService courseService = CourseService();
  final NotificationService notificationService = NotificationService();
  final ProgressService progressService = ProgressService();
  final FeedbackService feedbackService = FeedbackService();
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
        // Use the proper service method that updates both course and user
        await courseService.enrollUserInCourse(course.courseId, userId);
        
        // Start progress tracking
        await progressService.startCourse(
          userId: userId,
          courseId: course.courseId,
          totalVideos: course.syllabus.length,
        );
        
        // Send enrollment notification
        await notificationService.sendEnrollmentNotification(
          userId: userId,
          courseTitle: course.title,
        );
        
        setState(() => isEnrolled = true);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully enrolled in course!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Enrollment failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
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

                  // Course Reviews and Ratings Section
                  if (isEnrolled) ...[
                    const Divider(height: 48),
                    _buildSection(
                      title: 'Course Reviews',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 16,
                        children: [
                          // Average Rating Display
                          FutureBuilder<double>(
                            future: feedbackService.getAverageCourseRating(course.courseId),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const SizedBox.shrink();
                              }
                              final avgRating = snapshot.data ?? 0.0;
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4169E1).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  spacing: 16,
                                  children: [
                                    Column(
                                      spacing: 4,
                                      children: [
                                        Text(
                                          avgRating.toStringAsFixed(1),
                                          style: const TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF4169E1),
                                          ),
                                        ),
                                        RatingBarIndicator(
                                          rating: avgRating,
                                          itemBuilder: (context, index) => const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          ),
                                          itemCount: 5,
                                          itemSize: 20.0,
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                      child: FutureBuilder<int>(
                                        future: feedbackService.getCourseRatingCount(course.courseId),
                                        builder: (context, countSnapshot) {
                                          final count = countSnapshot.data ?? 0;
                                          return Text(
                                            'Based on $count ${count == 1 ? 'review' : 'reviews'}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF555555),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: _showFeedbackDialog,
                                      icon: const Icon(Icons.rate_review, size: 18),
                                      label: const Text('Write Review'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF4169E1),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          // Reviews List
                          StreamBuilder<List<FeedbackModel>>(
                            stream: feedbackService.getFeedbackByCourse(course.courseId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              if (snapshot.hasError) {
                                return Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text(
                                    'Error loading reviews: ${snapshot.error}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                );
                              }

                              final reviews = snapshot.data ?? [];
                              
                              if (reviews.isEmpty) {
                                return Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'No reviews yet. Be the first to review this course!',
                                      style: TextStyle(
                                        color: Color(0xFF555555),
                                      ),
                                    ),
                                  ),
                                );
                              }

                              return Column(
                                spacing: 12,
                                children: reviews.map((review) {
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      spacing: 8,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            RatingBarIndicator(
                                              rating: review.rating.toDouble(),
                                              itemBuilder: (context, index) => const Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                              ),
                                              itemCount: 5,
                                              itemSize: 18.0,
                                            ),
                                            Text(
                                              _formatDate(review.createdAt),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (review.message.isNotEmpty)
                                          Text(
                                            review.message,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              height: 1.5,
                                              color: Color(0xFF333333),
                                            ),
                                          ),
                                        if (review.status != 'new')
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(review.status),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              review.status.toUpperCase(),
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
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

  // Show feedback/review dialog
  void _showFeedbackDialog() {
    double rating = 5.0;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Write a Review'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              const Text(
                'Rate this course:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              StatefulBuilder(
                builder: (context, setState) => RatingBar.builder(
                  initialRating: rating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (newRating) {
                    setState(() => rating = newRating);
                  },
                ),
              ),
              const Text(
                'Your comment:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextField(
                controller: commentController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Share your experience with this course...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _submitFeedback(rating.toInt(), commentController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4169E1),
            ),
            child: const Text('Submit Review'),
          ),
        ],
      ),
    );
  }

  // Submit course feedback
  Future<void> _submitFeedback(int rating, String comment) async {
    try {
      final currentUser = AuthService().currentUser;
      if (currentUser == null) return;

      // Get user details
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final userName = userDoc.data()?['fullName'] ?? 'User';

      final feedback = FeedbackModel(
        feedbackId: '',
        userId: currentUser.uid,
        userName: userName,
        category: 'course',
        rating: rating.toDouble(),
        message: comment,
        referenceType: 'course',
        referenceId: course.courseId,
        status: 'new',
        adminNotes: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await feedbackService.submitFeedback(feedback);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit review: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Format date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else {
      return '${(difference.inDays / 365).floor()} years ago';
    }
  }

  // Get status color for feedback
  Color _getStatusColor(String status) {
    switch (status) {
      case 'new':
        return Colors.blue;
      case 'in_progress':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
}

