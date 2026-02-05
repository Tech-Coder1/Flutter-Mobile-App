import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../services/auth_service.dart';
import '../services/feedback_service.dart';
import '../services/user_service.dart';
import '../models/feedback_model.dart';

class UserFeedbackScreen extends StatefulWidget {
  const UserFeedbackScreen({super.key});

  @override
  State<UserFeedbackScreen> createState() => _UserFeedbackScreenState();
}

class _UserFeedbackScreenState extends State<UserFeedbackScreen> {
  final _feedbackService = FeedbackService();
  final _authService = AuthService();
  final _userService = UserService();
  final _messageController = TextEditingController();

  String _category = 'app';
  double _rating = 4.0;
  bool _isSubmitting = false;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _prefillUserName();
  }

  Future<void> _prefillUserName() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;
    try {
      final user = await _userService.getUserById(userId);
      if (mounted && user != null) {
        setState(() => _userName = user.fullName);
      }
    } catch (_) {
      // Best-effort; ignore errors here
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    final userId = _authService.currentUser?.uid;
    final userEmail = _authService.currentUser?.email ?? '';

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to submit feedback')),
      );
      return;
    }

    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please share your feedback message')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final feedback = FeedbackModel(
        feedbackId: '',
        userId: userId,
        userName: _userName.isNotEmpty ? _userName : userEmail,
        category: _category,
        rating: _rating,
        message: _messageController.text.trim(),
        referenceType: _category,
        referenceId: '',
        status: 'new',
        adminNotes: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _feedbackService.submitFeedback(feedback);

      if (mounted) {
        _messageController.clear();
        setState(() => _rating = 4.0);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thanks! Feedback submitted.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting feedback: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = _authService.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
      ),
      body: userId == null
          ? const Center(child: Text('Please log in to submit feedback.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.feedback, color: Color(0xFF4169E1)),
                              const SizedBox(width: 8),
                              Text(
                                'Share your feedback',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: _category,
                            decoration: const InputDecoration(labelText: 'Category'),
                            items: const [
                              DropdownMenuItem(value: 'app', child: Text('App Experience')),
                              DropdownMenuItem(value: 'course', child: Text('Courses')),
                              DropdownMenuItem(value: 'internship', child: Text('Internships')),
                              DropdownMenuItem(value: 'support', child: Text('Support')),
                              DropdownMenuItem(value: 'other', child: Text('Other')),
                            ],
                            onChanged: (value) => setState(() => _category = value ?? 'app'),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Rate your experience',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          RatingBar.builder(
                            initialRating: _rating,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 32,
                            unratedColor: Colors.grey[300],
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Color(0xFFFFC107),
                            ),
                            onRatingUpdate: (rating) => setState(() => _rating = rating),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _messageController,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              labelText: 'Tell us more',
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submitFeedback,
                              child: _isSubmitting
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Submit Feedback'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'My Feedback',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<List<FeedbackModel>>(
                    stream: _feedbackService.getUserFeedback(userId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(),
                        ));
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      final feedbackList = snapshot.data ?? [];
                      if (feedbackList.isEmpty) {
                        return const Text('No feedback submitted yet.');
                      }
                      return Column(
                        children: feedbackList.map((fb) => _feedbackCard(fb)).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _feedbackCard(FeedbackModel fb) {
    final statusColor = _statusColor(fb.status);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    fb.category.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    fb.status.toUpperCase(),
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber[700], size: 18),
                const SizedBox(width: 4),
                Text(fb.rating.toStringAsFixed(1)),
              ],
            ),
            const SizedBox(height: 8),
            Text(fb.message),
            if (fb.adminNotes.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Admin notes: ${fb.adminNotes}'),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Updated ${fb.updatedAt.toLocal()}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'resolved':
        return Colors.green;
      case 'in_review':
        return Colors.orange;
      default:
        return const Color(0xFF4169E1);
    }
  }
}
