import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/application_service.dart';
import '../services/notification_service.dart';
import '../services/user_service.dart';
import '../models/application_model.dart';
import '../models/internship_model.dart';

class ApplicationForm extends StatefulWidget {
  final InternshipModel? internship;

  const ApplicationForm({super.key, this.internship});

  @override
  State<ApplicationForm> createState() => _ApplicationFormState();
}

class _ApplicationFormState extends State<ApplicationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _skillsController = TextEditingController();

  final _authService = AuthService();
  final _applicationService = ApplicationService();
  final _notificationService = NotificationService();
  final _userService = UserService();

  String _resumeUrl = '';
  String _resumeFileName = '';
  bool _isUploadingResume = false;

  bool _isLoading = false;
  late InternshipModel _internship;

  @override
  void initState() {
    super.initState();
    _internship = widget.internship ?? InternshipModel(
      internshipId: '',
      role: 'Internship Position',
      company: 'Company',
      location: 'Location',
      type: 'Remote',
      description: '',
      postedBy: '',
      postedAt: DateTime.now(),
    );

    // Pre-fill email from authenticated user
    if (_authService.currentUser != null) {
      _emailController.text = _authService.currentUser!.email ?? '';
    }

    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    try {
      final user = await _userService.getUserById(userId);
      if (user != null && mounted) {
        setState(() {
          if (_nameController.text.isEmpty) {
            _nameController.text = user.fullName;
          }
          if (_phoneController.text.isEmpty && user.phoneNumber != null) {
            _phoneController.text = user.phoneNumber!;
          }
          if (_linkedinController.text.isEmpty && user.linkedInUrl != null) {
            _linkedinController.text = user.linkedInUrl!;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to prefill profile: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _pickAndUploadResume() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to upload your resume'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;
      final Uint8List? fileBytes = file.bytes;

      if (fileBytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to read the selected file'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      setState(() => _isUploadingResume = true);

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('resumes/$userId/${DateTime.now().millisecondsSinceEpoch}_${file.name}');

      await storageRef.putData(
        fileBytes,
        SettableMetadata(contentType: 'application/pdf'),
      );

      final url = await storageRef.getDownloadURL();

      if (mounted) {
        setState(() {
          _resumeUrl = url;
          _resumeFileName = file.name;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resume uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading resume: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingResume = false);
      }
    }
  }

  Future<void> _submitApplication() async {
    if (_formKey.currentState!.validate()) {
      if (_resumeUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload your resume (PDF)'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final userId = _authService.currentUser?.uid;
        if (userId == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please log in to apply'),
                backgroundColor: Colors.orange,
              ),
            );
            setState(() => _isLoading = false);
          }
          return;
        }

        // Check if user has already applied for this internship
        final alreadyApplied = await _applicationService.hasUserApplied(
          userId,
          _internship.internshipId,
        );

        if (alreadyApplied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('You have already applied for this position'),
                backgroundColor: Colors.orange,
              ),
            );
            setState(() => _isLoading = false);
          }
          return;
        }

        // Create application
        final application = ApplicationModel(
          applicationId: '',
          userId: userId,
          internshipId: _internship.internshipId,
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          linkedInUrl: _linkedinController.text.trim(),
          skillsExperience: _skillsController.text.trim(),
          resumeUrl: _resumeUrl,
          resumeFileName: _resumeFileName,
          status: 'pending',
          submittedAt: DateTime.now(),
        );

        await _applicationService.submitApplication(application);

        // Send notification
        await _notificationService.sendApplicationNotification(
          userId: userId,
          internshipRole: _internship.role,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Application submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
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
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply Now'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Apply for ${_internship.role}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A1A),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_internship.company} • ${_internship.location}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF6B7280),
                        ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    readOnly: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _linkedinController,
                    decoration: const InputDecoration(
                      labelText: 'LinkedIn URL',
                      prefixIcon: Icon(Icons.link),
                    ),
                    keyboardType: TextInputType.url,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your LinkedIn profile URL';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _skillsController,
                    decoration: const InputDecoration(
                      labelText: 'Skills & Experience',
                      prefixIcon: Icon(Icons.code),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your skills';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Resume (PDF)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.picture_as_pdf, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _resumeFileName.isNotEmpty
                                    ? _resumeFileName
                                    : 'No resume selected',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                _resumeUrl.isNotEmpty
                                    ? 'Uploaded'
                                    : 'Upload a PDF resume',
                                style: TextStyle(
                                  color: _resumeUrl.isNotEmpty
                                      ? Colors.green
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _isUploadingResume ? null : _pickAndUploadResume,
                          icon: _isUploadingResume
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.upload_file),
                          label: Text(_resumeUrl.isNotEmpty ? 'Replace' : 'Upload'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitApplication,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Submit Application'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}