import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import 'certificates_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final authService = AuthService();
  final userService = UserService();

  @override
  Widget build(BuildContext context) {
    final userId = authService.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Profile Header
            StreamBuilder<UserModel?>(
              stream: userService.getUserStream(userId),
              builder: (context, snapshot) {
                final user = snapshot.data;
                final fullName = user?.fullName ?? 'User';
                final email = user?.email ?? 'user@example.com';

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4169E1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Color(0xFF4169E1),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        fullName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CertificatesScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.workspace_premium_outlined),
                label: const Text('View Certificates'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4169E1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // My Learning Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'My Learning',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StreamBuilder<UserModel?>(
                    stream: userService.getUserStream(userId),
                    builder: (context, snapshot) {
                      final certificatesCount = snapshot.data?.certificatesCount ?? 0;
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              const Icon(Icons.book_outlined, size: 32, color: Color(0xFF4169E1)),
                              const SizedBox(height: 12),
                              const Text('Certificates'),
                              const SizedBox(height: 4),
                              Text(
                                '$certificatesCount',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF4169E1),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StreamBuilder<UserModel?>(
                    stream: userService.getUserStream(userId),
                    builder: (context, snapshot) {
                      final applicationsCount = snapshot.data?.applicationsCount ?? 0;
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              const Icon(Icons.work_outline, size: 32, color: Colors.green),
                              const SizedBox(height: 12),
                              const Text('Applications'),
                              const SizedBox(height: 4),
                              Text(
                                '$applicationsCount',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Settings Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Settings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings_outlined, color: Color(0xFF6B7280)),
                    title: const Text('Account Settings'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF6B7280)),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Feature coming soon')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.feedback_outlined, color: Color(0xFF6B7280)),
                    title: const Text('Give Feedback'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF6B7280)),
                    onTap: () => Navigator.pushNamed(context, '/feedback'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Log Out'),
                    textColor: Colors.red,
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Log Out'),
                          content: const Text('Are you sure you want to log out?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                await authService.signOut();
                                if (mounted) {
                                  Navigator.pop(context);
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/login',
                                    (route) => false,
                                  );
                                }
                              },
                              child: const Text('Log Out'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}