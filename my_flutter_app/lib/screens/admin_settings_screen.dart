import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/admin_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/admin_sidebar.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final _authService = AuthService();
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _emailNotifications = true;
  bool _pushNotifications = false;
  bool _weeklyReports = true;
  bool _twoFactorAuth = false;

  AdminModel? _currentAdmin;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminData() async {
    final user = _authService.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('admins').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            _currentAdmin = AdminModel.fromFirestore(doc);
            _fullNameController.text = _currentAdmin?.fullName ?? '';
            _emailController.text = _currentAdmin?.email ?? user.email ?? '';
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Row(
        children: [
          const AdminSidebar(currentRoute: '/admin_settings'),
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProfileSection(),
                              const SizedBox(height: 24),
                              _buildNotificationSection(),
                              const SizedBox(height: 24),
                              _buildSecuritySection(),
                              const SizedBox(height: 24),
                              _buildPlatformConfigSection(),
                            ],
                          ),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Settings',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your admin profile and platform preferences',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: Color(0xFF4169E1)),
                const SizedBox(width: 12),
                const Text(
                  'Admin Profile',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4169E1).withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Center(
                    child: Text(
                      _fullNameController.text.isNotEmpty
                          ? _fullNameController.text
                                .substring(0, 1)
                                .toUpperCase()
                          : 'A',
                      style: const TextStyle(
                        color: Color(0xFF4169E1),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _fullNameController.text.isNotEmpty
                            ? _fullNameController.text
                            : 'Admin User',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4169E1).withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Administrator',
                          style: TextStyle(
                            color: Color(0xFF4169E1),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _fullNameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.person_outline),
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
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.email_outlined),
                enabled: false,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4169E1),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications, color: Color(0xFF4169E1)),
              const SizedBox(width: 12),
              const Text(
                'Notification Preferences',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            'Email Notifications',
            'Receive notifications via email',
            _emailNotifications,
            (value) => setState(() => _emailNotifications = value),
          ),
          const Divider(),
          _buildSwitchTile(
            'Push Notifications',
            'Receive push notifications in browser',
            _pushNotifications,
            (value) => setState(() => _pushNotifications = value),
          ),
          const Divider(),
          _buildSwitchTile(
            'Weekly Reports',
            'Get weekly analytics reports via email',
            _weeklyReports,
            (value) => setState(() => _weeklyReports = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.security, color: Color(0xFF4169E1)),
              const SizedBox(width: 12),
              const Text(
                'Security Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            'Two-Factor Authentication',
            'Add an extra layer of security to your account',
            _twoFactorAuth,
            (value) => setState(() => _twoFactorAuth = value),
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.lock_outline, color: Color(0xFF4169E1)),
            title: const Text(
              'Change Password',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: const Text('Update your account password'),
            trailing: OutlinedButton(
              onPressed: _changePassword,
              child: const Text('Change'),
            ),
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.devices, color: Color(0xFF4169E1)),
            title: const Text(
              'Active Sessions',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: const Text('Manage your logged-in devices'),
            trailing: OutlinedButton(
              onPressed: _viewSessions,
              child: const Text('View'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformConfigSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.settings, color: Color(0xFF4169E1)),
              const SizedBox(width: 12),
              const Text(
                'Platform Configuration',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.language, color: Color(0xFF4169E1)),
            title: const Text(
              'Platform Language',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: const Text('Current: English (US)'),
            trailing: OutlinedButton(
              onPressed: _changeLanguage,
              child: const Text('Change'),
            ),
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.palette, color: Color(0xFF4169E1)),
            title: const Text(
              'Theme',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: const Text('Current: Light Mode'),
            trailing: OutlinedButton(
              onPressed: _changeTheme,
              child: const Text('Change'),
            ),
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.backup, color: Color(0xFF4169E1)),
            title: const Text(
              'Data Backup',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: const Text('Last backup: Never'),
            trailing: ElevatedButton.icon(
              onPressed: _backupData,
              icon: const Icon(Icons.cloud_upload, size: 18),
              label: const Text('Backup Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4169E1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeThumbColor: const Color(0xFF4169E1),
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = _authService.currentUser;
        if (user != null) {
          await _firestore.collection('admins').doc(user.uid).update({
            'fullName': _fullNameController.text,
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _changePassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Text(
          'Password change functionality requires Firebase Auth email verification. '
          'You can implement this using Firebase Auth\'s sendPasswordResetEmail method.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () async {
              final user = _authService.currentUser;
              if (user?.email != null) {
                await _authService.resetPassword(user!.email!);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset email sent'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4169E1),
            ),
            child: const Text('Send Reset Email'),
          ),
        ],
      ),
    );
  }

  void _viewSessions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Active Sessions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.computer),
              title: const Text('Current Session'),
              subtitle: const Text('Chrome on macOS'),
              trailing: const Chip(
                label: Text('Active'),
                backgroundColor: Colors.green,
              ),
            ),
          ],
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

  void _changeLanguage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Language settings coming soon...'),
        backgroundColor: Color(0xFF4169E1),
      ),
    );
  }

  void _changeTheme() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Theme settings coming soon...'),
        backgroundColor: Color(0xFF4169E1),
      ),
    );
  }

  void _backupData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data backup initiated...'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
