import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/utils/responsive.dart';
import 'package:frontend/shared/widgets/glass_container.dart';
import 'package:frontend/shared/widgets/custom_button.dart';
import 'package:frontend/shared/utils/date_formatter.dart';
import 'package:frontend/features/projects/controllers/project_controller.dart';
import 'package:frontend/features/projects/models/project_model.dart';
import 'package:frontend/features/ide/presentation/screens/ide_workspace_screen.dart';

class ProjectsListScreen extends StatelessWidget {
  final ProjectController projectController;

  const ProjectsListScreen({
    super.key,
    required this.projectController,
  });

  Future<void> _handleCreateFromFile(BuildContext context) async {
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

  Future<void> _handleCreateFromFolder(BuildContext context) async {
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
      animation: projectController,
      builder: (context, _) {
        final projects = projectController.projects;
        final isMobile = Responsive.isMobile(context);
        final isDesktop = Responsive.isDesktop(context);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('All Projects'),
            actions: [
              IconButton(
                icon: const Icon(Icons.drive_folder_upload_rounded, color: AppColors.accentAmber),
                tooltip: 'Open Folder from Device',
                onPressed: () => _handleCreateFromFolder(context),
              ),
              IconButton(
                icon: const Icon(Icons.file_open_rounded, color: AppColors.accentCyan),
                tooltip: 'Open File from Device',
                onPressed: () => _handleCreateFromFile(context),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                children: [
                  // Search & Filter Bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: TextField(
                      onChanged: (val) => projectController.setSearchQuery(val),
                      style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search Python projects...',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textMuted),
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.surfaceBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.surfaceBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                      ),
                    ),
                  ),

                  // Project List / Grid
                  Expanded(
                    child: projectController.isLoading
                        ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                        : projects.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.folder_open_rounded, size: 48, color: AppColors.textMuted),
                                    const SizedBox(height: 12),
                                    const Text('No projects found', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 14),
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      alignment: WrapAlignment.center,
                                      children: [
                                        CustomButton(
                                          label: 'Open File from Device',
                                          icon: Icons.file_open_rounded,
                                          isGradient: true,
                                          onPressed: () => _handleCreateFromFile(context),
                                        ),
                                        CustomButton(
                                          label: 'Open Folder from Device',
                                          icon: Icons.drive_folder_upload_rounded,
                                          isSecondary: true,
                                          onPressed: () => _handleCreateFromFolder(context),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            : isMobile
                                ? ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    itemCount: projects.length,
                                    itemBuilder: (context, index) {
                                      final project = projects[index];
                                      return _buildProjectTile(context, project);
                                    },
                                  )
                                : GridView.builder(
                                    padding: const EdgeInsets.all(16),
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: isDesktop ? 3 : 2,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: isDesktop ? 1.7 : 1.55,
                                    ),
                                    itemCount: projects.length,
                                    itemBuilder: (context, index) {
                                      final project = projects[index];
                                      return _buildProjectCard(context, project);
                                    },
                                  ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: isMobile
              ? FloatingActionButton.extended(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.file_open_rounded),
                  label: const Text('Open File from Device', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => _handleCreateFromFile(context),
                )
              : null,
        );
      },
    );
  }

  Widget _buildProjectTile(BuildContext context, ProjectModel project) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => IdeWorkspaceScreen(project: project),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentCyan.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.code_rounded, color: AppColors.accentCyan, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      project.name,
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Python 3.12',
                        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: AppColors.accentCyan),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  project.description.isNotEmpty ? project.description : 'Clean Python environment',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded, size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      'Edited ${DateFormatter.timeAgo(project.updatedAt)}',
                      style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.insert_drive_file_outlined, size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      '${project.fileCount} files',
                      style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.textMuted),
            onPressed: () {
              projectController.deleteProject(project.id);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, ProjectModel project) {
    return GlassContainer(
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
                  border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.3)),
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
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
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
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.textMuted),
                onPressed: () => projectController.deleteProject(project.id),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            project.description.isNotEmpty ? project.description : 'Clean Python development environment',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const Spacer(),
          const Divider(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Edited ${DateFormatter.timeAgo(project.updatedAt)}',
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
}
