import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final notificationService = NotificationService();
    final userId = auth.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        actions: [
          TextButton(
            onPressed: () => notificationService.markAllAsRead(userId),
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: notificationService.getNotificationsForUser(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final notifications = snapshot.data ?? [];
          if (notifications.isEmpty) {
            return const Center(child: Text('No messages'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final n = notifications[index];
              final icon = n.type == 'course' ? Icons.school : Icons.work_outline;
              final color = n.isRead ? const Color(0xFF6B7280) : const Color(0xFF4169E1);
              return Card(
                child: ListTile(
                  leading: Icon(icon, color: color),
                  title: Text(n.title),
                  subtitle: Text(n.message),
                  trailing: IconButton(
                    icon: Icon(n.isRead ? Icons.mark_email_read : Icons.mark_email_unread, color: color),
                    onPressed: () async {
                      if (!n.isRead) {
                        await notificationService.markAsRead(n.notificationId);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
