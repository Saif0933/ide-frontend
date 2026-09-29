import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/shared/utils/date_formatter.dart';
import 'package:frontend/features/notifications/controllers/notification_controller.dart';
import 'package:frontend/features/notifications/models/notification_model.dart';
import 'package:frontend/features/chat/presentation/screens/developer_chat_screen.dart';

class NotificationsSheet extends StatelessWidget {
  final NotificationController notificationController;

  const NotificationsSheet({
    super.key,
    required this.notificationController,
  });

  static void show(BuildContext context, NotificationController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => NotificationsSheet(notificationController: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: notificationController,
      builder: (context, _) {
        final notifications = notificationController.notifications;

        return SafeArea(
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(Icons.notifications_rounded, color: AppColors.primaryLight, size: 22),
                    const SizedBox(width: 8),
                    const Text(
                      'Notifications',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    if (notifications.any((n) => !n.isRead))
                      TextButton(
                        onPressed: notificationController.markAllAsRead,
                        child: const Text('Mark all read', style: TextStyle(fontSize: 12, color: AppColors.primaryLight)),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: notifications.isEmpty
                      ? const Center(
                          child: Text(
                            'No notifications at the moment.',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        )
                      : ListView.separated(
                          itemCount: notifications.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final notif = notifications[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                              leading: _buildNotifIcon(notif.type),
                              title: Text(
                                notif.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: notif.isRead ? FontWeight.w400 : FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 2),
                                  Text(
                                    notif.body,
                                    style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormatter.timeAgo(notif.createdAt),
                                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                              onTap: () {
                                notificationController.markAsRead(notif.id);
                                if (notif.projectId != null) {
                                  Navigator.pop(context);
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (ctx) => DeveloperChatScreen(
                                        projectId: notif.projectId!,
                                        projectName: 'Project Support',
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotifIcon(NotificationType type) {
    switch (type) {
      case NotificationType.chatReply:
        return CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.accentPurple.withValues(alpha: 0.2),
          child: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.accentPurple, size: 16),
        );
      case NotificationType.executionCompleted:
        return CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.statusSuccess.withValues(alpha: 0.2),
          child: const Icon(Icons.check_circle_outline_rounded, color: AppColors.statusSuccess, size: 16),
        );
      case NotificationType.executionFailed:
        return CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.statusFailed.withValues(alpha: 0.2),
          child: const Icon(Icons.error_outline_rounded, color: AppColors.statusFailed, size: 16),
        );
      case NotificationType.systemAlert:
        return CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.accentAmber.withValues(alpha: 0.2),
          child: const Icon(Icons.info_outline_rounded, color: AppColors.accentAmber, size: 16),
        );
    }
  }
}
