import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/utils/responsive.dart';
import 'package:frontend/shared/widgets/glass_container.dart';
import 'package:frontend/shared/widgets/status_pill.dart';
import 'package:frontend/shared/utils/date_formatter.dart';
import 'package:frontend/features/auth/controllers/auth_controller.dart';
import 'package:frontend/features/projects/controllers/project_controller.dart';
import 'package:frontend/features/notifications/controllers/notification_controller.dart';
import 'package:frontend/features/projects/models/project_model.dart';
import 'package:frontend/features/execution/models/execution_job.dart';
import 'package:frontend/features/ide/presentation/screens/ide_workspace_screen.dart';
import 'package:frontend/features/notifications/presentation/screens/notifications_sheet.dart';

class DashboardScreen extends StatelessWidget {
  final AuthController authController;
  final ProjectController projectController;
  final NotificationController notificationController;
  final VoidCallback onNavigateToProjects;
  final VoidCallback onNavigateToChat;

  const DashboardScreen({
    super.key,
    required this.authController,
    required this.projectController,
    required this.notificationController,
    required this.onNavigateToProjects,
    required this.onNavigateToChat,
  });

  Future<void> _handleCreateProjectFromFile(BuildContext context) async {
    final navigator = Navigator.of(context);
    final newProject = await projectController.createProjectFromFileManager(pickFolder: false);
    if (newProject != null) {
      navigator.push(
        MaterialPageRoute(
          builder: (ctx) => IdeWorkspaceScreen(project: newProject),
        ),
      );
    }
  }

  Future<void> _handleCreateProjectFromFolder(BuildContext context) async {
    final navigator = Navigator.of(context);
    final newProject = await projectController.createProjectFromFileManager(pickFolder: true);
    if (newProject != null) {
      navigator.push(
        MaterialPageRoute(
          builder: (ctx) => IdeWorkspaceScreen(project: newProject),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([projectController, notificationController]),
      builder: (context, _) {
        final projects = projectController.recentProjects;
        final unreadCount = notificationController.unreadCount;
        final isMobile = Responsive.isMobile(context);
        final isDesktop = Responsive.isDesktop(context);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            title: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.terminal_rounded, size: 18, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PyStudio Cloud',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    Text(
                      authController.user?.email ?? 'Developer Workspace',
                      style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded, size: 22),
                    tooltip: 'Notifications',
                    onPressed: () => NotificationsSheet.show(context, notificationController),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await projectController.fetchProjects();
              await notificationController.fetchNotifications();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ResponsiveContainer(
                maxWidth: 1200,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // High-Impact CTA Banner
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(isMobile ? 18 : 24),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: isMobile
                          ? _buildBannerContentMobile(context)
                          : _buildBannerContentDesktop(context),
                    ),
                    const SizedBox(height: 20),

                    // Quick Stats Grid
                    _buildStatsRow(context, isMobile),
                    const SizedBox(height: 24),

                    // Recent Projects Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Projects',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        TextButton(
                          onPressed: onNavigateToProjects,
                          child: const Text('View All', style: TextStyle(fontSize: 13, color: AppColors.primaryLight)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Projects List / Grid
                    if (projects.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 36),
                          child: Column(
                            children: [
                              const Icon(Icons.folder_open_rounded, size: 48, color: AppColors.textMuted),
                              const SizedBox(height: 10),
                              const Text('No projects yet', style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
                              const SizedBox(height: 14),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                alignment: WrapAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () => _handleCreateProjectFromFile(context),
                                    icon: const Icon(Icons.file_open_rounded, size: 16),
                                    label: const Text('Open File from Device'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    ),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () => _handleCreateProjectFromFolder(context),
                                    icon: const Icon(Icons.drive_folder_upload_rounded, size: 16, color: AppColors.accentAmber),
                                    label: const Text('Open Folder', style: TextStyle(color: AppColors.textPrimary)),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: AppColors.surfaceBorder),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (isMobile)
                      ...projects.map((project) => _buildProjectCard(context, project))
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isDesktop ? 3 : 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: isDesktop ? 1.55 : 1.45,
                        ),
                        itemCount: projects.length,
                        itemBuilder: (context, index) {
                          return _buildProjectCard(context, projects[index]);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBannerContentMobile(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt_rounded, size: 12, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Python 3.12 Cloud Runner',
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Write, Execute & Collaborate',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Isolated sandboxes with real-time logs and 1-tap developer assistance.',
          style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.3),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton.icon(
              onPressed: () => _handleCreateProjectFromFile(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryDark,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              icon: const Icon(Icons.file_open_rounded, size: 17),
              label: const Text(
                'Open File from Device',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _handleCreateProjectFromFolder(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white70),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              icon: const Icon(Icons.drive_folder_upload_rounded, size: 17),
              label: const Text(
                'Open Folder',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBannerContentDesktop(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt_rounded, size: 14, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'Python 3.12 Sandboxed Cloud Runtime',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Write, Execute & Collaborate in Real-Time',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'High-performance Python cloud editor with sub-second execution, diagnostics, and full device storage integration.',
                style: TextStyle(fontSize: 13.5, color: Colors.white70, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ElevatedButton.icon(
              onPressed: () => _handleCreateProjectFromFile(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryDark,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              ),
              icon: const Icon(Icons.file_open_rounded, size: 18),
              label: const Text(
                'Open File from Device',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _handleCreateProjectFromFolder(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white70, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
              icon: const Icon(Icons.drive_folder_upload_rounded, size: 18),
              label: const Text(
                'Open Folder from Device',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context, bool isMobile) {
    final stats = [
      _buildStatCard('Total Projects', '${projectController.projects.length}', Icons.folder_rounded, AppColors.primaryLight),
      _buildStatCard('Sandbox State', 'Online', Icons.check_circle_rounded, AppColors.statusSuccess),
      if (!isMobile) ...[
        _buildStatCard('Runtime Engine', 'Python 3.12', Icons.memory_rounded, AppColors.accentCyan),
        _buildStatCard('Execution Quota', '101.6 mins left', Icons.speed_rounded, AppColors.accentAmber),
      ],
    ];

    if (isMobile) {
      return Row(
        children: [
          Expanded(child: stats[0]),
          const SizedBox(width: 10),
          Expanded(child: stats[1]),
        ],
      );
    }

    return Row(
      children: stats.map((stat) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: stat,
        ),
      )).toList(),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color == AppColors.statusSuccess ? color : AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, ProjectModel project) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => IdeWorkspaceScreen(project: project),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentCyan.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.code_rounded, color: AppColors.accentCyan, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${project.defaultFile} • ${project.fileCount} files',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              _buildExecutionStatusBadge(project.lastExecutionStatus),
            ],
          ),
          if (project.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              project.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
          const Spacer(),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Updated ${DateFormatter.timeAgo(project.updatedAt)}',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              const Row(
                children: [
                  Text(
                    'Open IDE',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryLight),
                  ),
                  Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.primaryLight),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExecutionStatusBadge(ProjectExecutionStatus status) {
    switch (status) {
      case ProjectExecutionStatus.success:
        return const StatusPill(status: ExecutionStatus.completed, fontSize: 10);
      case ProjectExecutionStatus.failed:
        return const StatusPill(status: ExecutionStatus.failed, fontSize: 10);
      case ProjectExecutionStatus.running:
        return const StatusPill(status: ExecutionStatus.running, fontSize: 10);
      case ProjectExecutionStatus.idle:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text('Python', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
        );
    }
  }
}
