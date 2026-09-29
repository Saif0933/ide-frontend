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

    return AnimatedBuilder(
      animation: projectController,
      builder: (context, _) {
        final projects = projectController.projects;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Developer Collaboration'),
            centerTitle: false,
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: projects.isEmpty
                  ? const Center(
                      child: Text(
                        'No active project chats yet.\nCreate a project to start collaborating!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    )
                  : isMobile
                      ? ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: projects.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final project = projects[index];
                            return _buildChatListTile(context, project);
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
                            return _buildChatCard(context, project);
                          },
                        ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatListTile(BuildContext context, dynamic project) {
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
                border: Border.all(color: AppColors.surface, width: 2),
              ),
            ),
          ),
        ],
      ),
      title: Text(
        project.name,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        project.description.isNotEmpty
            ? project.description
            : 'Developer support thread for ${project.name}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
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

  Widget _buildChatCard(BuildContext context, dynamic project) {
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
                    border: Border.all(color: AppColors.surface, width: 1.5),
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
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  project.description.isNotEmpty ? project.description : 'Developer support thread',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
        ],
      ),
    );
  }
}
