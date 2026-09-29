import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/utils/responsive.dart';
import 'package:frontend/shared/widgets/glass_container.dart';
import 'package:frontend/features/projects/controllers/project_controller.dart';
import 'developer_chat_screen.dart';

class ConversationsListScreen extends StatelessWidget {
  final ProjectController projectController;

  const ConversationsListScreen({
    super.key,
    required this.projectController,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final isMobile = Responsive.isMobile(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: projectController,
      builder: (context, _) {
        final projects = projectController.projects;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            title: Text(
              'Developer Collaboration',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF111827),
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: false,
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: projects.isEmpty
                  ? Center(
                      child: Text(
                        'No active project chats yet.\nCreate a project to start collaborating!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    )
                  : isMobile
                      ? ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: projects.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                          ),
                          itemBuilder: (context, index) {
                            final project = projects[index];
                            return _buildChatListTile(context, project, isDark);
                          },
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isDesktop ? 3 : 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: isDesktop ? 2.2 : 2.0,
                          ),
                          itemCount: projects.length,
                          itemBuilder: (context, index) {
                            final project = projects[index];
                            return _buildChatCard(context, project, isDark);
                          },
                        ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatListTile(BuildContext context, dynamic project, bool isDark) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.accentPurple.withValues(alpha: 0.2),
            child: const Icon(Icons.code_rounded, color: AppColors.accentPurple, size: 20),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.statusSuccess,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
      title: Text(
        project.name,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF111827),
        ),
      ),
      subtitle: Text(
        project.description.isNotEmpty
            ? project.description
            : 'Developer support thread for ${project.name}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => DeveloperChatScreen(
              projectId: project.id,
              projectName: project.name,
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatCard(BuildContext context, dynamic project, bool isDark) {
    return GlassContainer(
      padding: const EdgeInsets.all(14),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => DeveloperChatScreen(
              projectId: project.id,
              projectName: project.name,
            ),
          ),
        );
      },
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.accentPurple.withValues(alpha: 0.2),
                child: const Icon(Icons.code_rounded, color: AppColors.accentPurple, size: 20),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: AppColors.statusSuccess,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  project.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF111827),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  project.description.isNotEmpty ? project.description : 'Developer support thread',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            size: 20,
          ),
        ],
      ),
    );
  }
}
