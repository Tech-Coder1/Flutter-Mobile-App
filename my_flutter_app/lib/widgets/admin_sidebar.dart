import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AdminSidebar extends StatefulWidget {
  final String currentRoute;

  const AdminSidebar({super.key, required this.currentRoute});

  @override
  State<AdminSidebar> createState() => _AdminSidebarState();
}

class _AdminSidebarState extends State<AdminSidebar> {
  bool isCollapsed = false;
  final authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isCollapsed ? 80 : 260,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.1),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Admin Identity Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFF2A2A2A), width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4169E1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<String>(
                          future: _getAdminName(),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data ?? 'Admin',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                        const Text(
                          'Administrator',
                          style: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Navigation Menu
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _buildMenuItem(
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  route: '/admin_dashboard',
                ),
                _buildMenuItem(
                  icon: Icons.assignment_outlined,
                  label: 'Applications',
                  route: '/admin_application_review',
                ),
                _buildMenuItem(
                  icon: Icons.book_outlined,
                  label: 'Courses',
                  route: '/admin_courses',
                ),
                _buildMenuItem(
                  icon: Icons.work_outline,
                  label: 'Internships',
                  route: '/admin_internships',
                ),
                _buildMenuItem(
                  icon: Icons.people_outline,
                  label: 'Users',
                  route: '/admin_users',
                ),
                _buildMenuItem(
                  icon: Icons.analytics_outlined,
                  label: 'Analytics',
                  route: '/admin_analytics',
                ),
                _buildMenuItem(
                  icon: Icons.support_agent_outlined,
                  label: 'Support',
                  route: '/admin_support_tickets',
                ),
                _buildMenuItem(
                  icon: Icons.feedback_outlined,
                  label: 'Feedback',
                  route: '/admin_feedback',
                ),
                const SizedBox(height: 12),
                Divider(
                  color: const Color(0xFF2A2A2A),
                  indent: isCollapsed ? 16 : 20,
                  endIndent: isCollapsed ? 16 : 20,
                ),
                const SizedBox(height: 12),
                _buildMenuItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  route: '/admin_settings',
                ),
                _buildMenuItem(
                  icon: Icons.logout,
                  label: 'Logout',
                  route: 'logout',
                  onTap: _handleLogout,
                ),
              ],
            ),
          ),

          // Collapse Toggle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFF2A2A2A), width: 1),
              ),
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  isCollapsed = !isCollapsed;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isCollapsed
                        ? Icons.keyboard_arrow_right
                        : Icons.keyboard_arrow_left,
                    color: const Color(0xFF9CA3AF),
                  ),
                  if (!isCollapsed) ...[
                    const SizedBox(width: 8),
                    const Text(
                      'Collapse',
                      style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required String route,
    VoidCallback? onTap,
  }) {
    final isActive = widget.currentRoute == route;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isCollapsed ? 16 : 12,
        vertical: 4,
      ),
      child: InkWell(
        onTap:
            onTap ??
            () {
              if (route != widget.currentRoute) {
                Navigator.pushReplacementNamed(context, route);
              }
            },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF4169E1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : const Color(0xFF9CA3AF),
                size: 20,
              ),
              if (!isCollapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isActive ? Colors.white : const Color(0xFF9CA3AF),
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<String> _getAdminName() async {
    try {
      final user = authService.currentUser;
      if (user != null) {
        final adminData = await authService.getAdminData(user.uid);
        return adminData?.fullName ?? user.email?.split('@').first ?? 'Admin';
      }
      return 'Admin';
    } catch (e) {
      return 'Admin';
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await authService.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/admin_login',
          (route) => false,
        );
      }
    }
  }
}
