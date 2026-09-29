import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/utils/responsive.dart';
import 'package:frontend/shared/widgets/custom_button.dart';
import 'package:frontend/shared/widgets/glass_container.dart';
import 'package:frontend/features/auth/controllers/auth_controller.dart';
import 'package:frontend/features/auth/presentation/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final AuthController authController;

  const ProfileScreen({
    super.key,
    required this.authController,
  });

  @override
  Widget build(BuildContext context) {
    final user = authController.user;
    final isMobile = Responsive.isMobile(context);

    Widget userHeaderCard = GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary,
            child: Text(
              user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Alex Rivera',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.email ?? 'alex.rivera@dev.io',
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accentCyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'PRO DEVELOPER TIER',
                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.accentCyan),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    Widget quotaCard = GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.speed_rounded, size: 18, color: AppColors.accentAmber),
              SizedBox(width: 8),
              Text('Cloud Execution Quotas', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
            ],
          ),
          const SizedBox(height: 14),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Daily Compute Time', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Text('18.4 / 120.0 mins', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.15,
              minHeight: 6,
              backgroundColor: AppColors.surfaceLight,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentCyan),
            ),
          ),
          const SizedBox(height: 14),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sandbox Memory Limit', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Text('128 MB / job', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );

    Widget settingsCard = GlassContainer(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.palette_outlined, color: AppColors.primaryLight),
            title: const Text('IDE Syntax & Editor Theme', style: TextStyle(fontSize: 13.5)),
            subtitle: const Text('Dark Obsidian, VS Modern, Monokai', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.security_rounded, color: AppColors.accentPurple),
            title: const Text('Security & Sandboxing Policy', style: TextStyle(fontSize: 13.5)),
            subtitle: const Text('Isolated microVM execution with strict timeouts', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.notifications_none_rounded, color: AppColors.accentAmber),
            title: const Text('Push & Chat Notifications', style: TextStyle(fontSize: 13.5)),
            subtitle: const Text('Execution alerts and mentor messages', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.cloud_sync_rounded, color: AppColors.accentCyan),
            title: const Text('Device Storage & File Sync', style: TextStyle(fontSize: 13.5)),
            subtitle: const Text('Direct device folder imports & auto-save', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            onTap: () {},
          ),
        ],
      ),
    );

    Widget logoutButton = CustomButton(
      label: 'Sign Out',
      isDestructive: true,
      icon: Icons.logout_rounded,
      width: double.infinity,
      onPressed: () async {
        await authController.logout();
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (ctx) => LoginScreen(authController: authController)),
            (route) => false,
          );
        }
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Account & Settings'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: isMobile
                ? Column(
                    children: [
                      userHeaderCard,
                      const SizedBox(height: 16),
                      quotaCard,
                      const SizedBox(height: 16),
                      settingsCard,
                      const SizedBox(height: 24),
                      logoutButton,
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            userHeaderCard,
                            const SizedBox(height: 16),
                            quotaCard,
                            const SizedBox(height: 20),
                            logoutButton,
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 6,
                        child: settingsCard,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
