import 'package:flutter/material.dart';
import '../services/application_service.dart';
import '../models/application_model.dart';
import '../widgets/admin_sidebar.dart';

class AdminApplicationReviewScreen extends StatefulWidget {
  const AdminApplicationReviewScreen({super.key});

  @override
  State<AdminApplicationReviewScreen> createState() =>
      _AdminApplicationReviewScreenState();
}

class _AdminApplicationReviewScreenState
    extends State<AdminApplicationReviewScreen>
    with SingleTickerProviderStateMixin {
  final _applicationService = ApplicationService();
  String _searchQuery = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Row(
        children: [
          const AdminSidebar(currentRoute: '/admin_application_review'),
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildApplicationsList('all'),
                      _buildApplicationsList('pending'),
                      _buildApplicationsList('approved'),
                      _buildApplicationsList('rejected'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Application Reviews',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Review and manage all internship and course applications',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) {
              setState(() => _searchQuery = value.toLowerCase());
            },
            decoration: InputDecoration(
              hintText: 'Search by name or email...',
              prefixIcon: const Icon(Icons.search, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF4169E1),
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: const Color(0xFF4169E1),
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        tabs: const [
          Tab(text: 'All Applications'),
          Tab(text: 'Pending'),
          Tab(text: 'Approved'),
          Tab(text: 'Rejected'),
        ],
      ),
    );
  }

  Widget _buildApplicationsList(String filter) {
    return StreamBuilder<List<ApplicationModel>>(
      stream: _getFilteredApplicationsStream(filter),
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

        final applications = snapshot.data ?? [];

        // Filter by search query
        final filteredApplications = applications.where((app) {
          if (_searchQuery.isEmpty) return true;
          return app.fullName.toLowerCase().contains(_searchQuery) ||
              app.email.toLowerCase().contains(_searchQuery);
        }).toList();

        if (filteredApplications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty
                      ? 'No applications found'
                      : 'No applications match your search',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  _searchQuery.isEmpty
                      ? 'Applications will appear here once students submit them'
                      : 'Try adjusting your search terms',
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredApplications.length,
          itemBuilder: (context, index) {
            return _buildApplicationCard(filteredApplications[index]);
          },
        );
      },
    );
  }

  Stream<List<ApplicationModel>> _getFilteredApplicationsStream(String filter) {
    if (filter == 'all') {
      return _applicationService.getAllApplications();
    } else {
      return _applicationService.getApplicationsByStatus(filter);
    }
  }

  Widget _buildApplicationCard(ApplicationModel application) {
    final statusColor = _getStatusColor(application.status);
    final statusIcon = _getStatusIcon(application.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: () => _showApplicationDetails(application),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and status
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4169E1).withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        application.fullName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF4169E1),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          application.email,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withValues(alpha:0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 6),
                        Text(
                          application.status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Additional info
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          application.phone,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (application.resumeUrl.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.picture_as_pdf,
                          size: 18,
                          color: Colors.red[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Resume',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(width: 16),
                  Icon(Icons.chevron_right, size: 20, color: Colors.grey[400]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showApplicationDetails(ApplicationModel application) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Application Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Candidate info
              _buildDetailSection('Candidate Information', [
                _buildDetailRow('Full Name', application.fullName),
                _buildDetailRow('Email', application.email),
                _buildDetailRow('Phone', application.phone),
              ]),
              const SizedBox(height: 20),
              // Application details
              _buildDetailSection('Application Details', [
                _buildDetailRow('LinkedIn URL', application.linkedInUrl),
                _buildDetailRow(
                  'Skills & Experience',
                  application.skillsExperience,
                  multiline: true,
                ),
              ]),
              const SizedBox(height: 20),
              // Resume section
              if (application.resumeUrl.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resume',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _openResume(application.resumeUrl),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.picture_as_pdf,
                              color: Colors.red,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    application.resumeFileName.isEmpty
                                        ? 'resume.pdf'
                                        : application.resumeFileName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Tap to view',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.open_in_new, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              // Status badge
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(application.status).withValues(alpha:0.1),
                  border: Border.all(
                    color: _getStatusColor(application.status),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(application.status),
                      color: _getStatusColor(application.status),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Status: ${application.status.toUpperCase()}',
                        style: TextStyle(
                          color: _getStatusColor(application.status),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Action buttons
              if (application.status == 'pending') ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _updateApplicationStatus(
                          application.applicationId,
                          'rejected',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _updateApplicationStatus(
                          application.applicationId,
                          'approved',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Approve'),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                ElevatedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.lock),
                  label: const Text('Application Already Reviewed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[400],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Divider(color: Colors.grey[300], height: 16),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool multiline = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 13),
          maxLines: multiline ? 4 : 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  Future<void> _updateApplicationStatus(
    String applicationId,
    String newStatus,
  ) async {
    try {
      await _applicationService.updateApplicationStatus(
        applicationId,
        newStatus,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Application ${newStatus == 'approved' ? 'approved' : 'rejected'} successfully',
            ),
            backgroundColor: newStatus == 'approved'
                ? Colors.green
                : Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _openResume(String url) {
    // Show a simple dialog indicating the resume URL
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resume'),
        content: const Text(
          'Resume link available. To implement full PDF viewing, '
          'add a PDF viewer package like pdf or google_mlkit_document_scanner.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
