import 'package:flutter/material.dart';
import '../services/feedback_service.dart';
import '../models/feedback_model.dart';

class AdminFeedbackScreen extends StatefulWidget {
  const AdminFeedbackScreen({super.key});

  @override
  State<AdminFeedbackScreen> createState() => _AdminFeedbackScreenState();
}

class _AdminFeedbackScreenState extends State<AdminFeedbackScreen> {
  final _feedbackService = FeedbackService();
  String _selectedStatus = 'all';
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback (Admin)'),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: StreamBuilder<List<FeedbackModel>>(
              stream: _feedbackService.getAllFeedback(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final feedbackList = (snapshot.data ?? [])
                    .where(_filterFeedback)
                    .toList();
                if (feedbackList.isEmpty) {
                  return const Center(child: Text('No feedback yet'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: feedbackList.length,
                  itemBuilder: (context, index) {
                    final fb = feedbackList[index];
                    return _feedbackCard(fb);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All')),
                DropdownMenuItem(value: 'new', child: Text('New')),
                DropdownMenuItem(value: 'in_review', child: Text('In Review')),
                DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
              ],
              onChanged: (value) => setState(() => _selectedStatus = value ?? 'all'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All')),
                DropdownMenuItem(value: 'app', child: Text('App')),
                DropdownMenuItem(value: 'course', child: Text('Courses')),
                DropdownMenuItem(value: 'internship', child: Text('Internships')),
                DropdownMenuItem(value: 'support', child: Text('Support')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (value) => setState(() => _selectedCategory = value ?? 'all'),
            ),
          ),
        ],
      ),
    );
  }

  bool _filterFeedback(FeedbackModel fb) {
    final statusMatch = _selectedStatus == 'all' || fb.status == _selectedStatus;
    final categoryMatch = _selectedCategory == 'all' || fb.category == _selectedCategory;
    return statusMatch && categoryMatch;
  }

  Widget _feedbackCard(FeedbackModel fb) {
    final statusColor = _statusColor(fb.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showFeedbackDetail(fb),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fb.userName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(fb.message, maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      fb.status.toUpperCase(),
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 11),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Chip(
                    label: Text(fb.category.toUpperCase()),
                    backgroundColor: Colors.grey[200],
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      Icon(Icons.star, size: 18, color: Colors.amber[700]),
                      const SizedBox(width: 4),
                      Text(fb.rating.toStringAsFixed(1)),
                    ],
                  ),
                ],
              ),
              if (fb.adminNotes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Admin notes: ${fb.adminNotes}', style: const TextStyle(fontSize: 12)),
              ],
              const SizedBox(height: 6),
              Text(
                'Updated ${fb.updatedAt.toLocal()}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFeedbackDetail(FeedbackModel fb) {
    final notesController = TextEditingController(text: fb.adminNotes);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fb.userName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(fb.message),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(fb.status).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      fb.status.toUpperCase(),
                      style: TextStyle(
                        color: _statusColor(fb.status),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('New'),
                    selected: fb.status == 'new',
                    onSelected: (_) => _updateStatus(fb, 'new', notesController.text),
                  ),
                  ChoiceChip(
                    label: const Text('In Review'),
                    selected: fb.status == 'in_review',
                    onSelected: (_) => _updateStatus(fb, 'in_review', notesController.text),
                  ),
                  ChoiceChip(
                    label: const Text('Resolved'),
                    selected: fb.status == 'resolved',
                    onSelected: (_) => _updateStatus(fb, 'resolved', notesController.text),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Admin notes',
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _updateNotes(fb, notesController.text),
                  icon: const Icon(Icons.save),
                  label: const Text('Save Notes'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateStatus(FeedbackModel fb, String status, String notes) async {
    await _feedbackService.updateStatus(
      feedbackId: fb.feedbackId,
      status: status,
      adminNotes: notes,
    );
    if (mounted) Navigator.pop(context);
  }

  Future<void> _updateNotes(FeedbackModel fb, String notes) async {
    await _feedbackService.updateAdminNotes(fb.feedbackId, notes);
    if (mounted) Navigator.pop(context);
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
