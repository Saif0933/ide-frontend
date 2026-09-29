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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: projectController,
      builder: (context, _) {
        final projects = projectController.projects;
        final isMobile = Responsive.isMobile(context);
        final isDesktop = Responsive.isDesktop(context);

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            title: Text(
              'All Projects',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF111827),
                fontWeight: FontWeight.bold,
              ),
            ),
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
                      cursorColor: const Color(0xFFE53935),
                      style: TextStyle(
                        fontSize: 13.5,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search Python projects...',
                        hintStyle: TextStyle(
                          color: isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF),
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF9CA3AF),
                        ),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5),
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
                                    Icon(
                                      Icons.folder_open_rounded,
                                      size: 48,
                                      color: isDark ? const Color(0xFF64748B) : Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No projects found',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1F2937),
                                      ),
                                    ),
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
                                      return _buildProjectTile(context, project, isDark);
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
                                      return _buildProjectCard(context, project, isDark);
                                    },
                                  ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: isMobile
              ? FloatingActionButton.extended(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.file_open_rounded),
                  label: const Text('Open File', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => _handleCreateFromFile(context),
                )
              : null,
        );
      },
    );
  }

  Widget _buildProjectTile(BuildContext context, ProjectModel project, bool isDark) {
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
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
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
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 12,
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Edited ${DateFormatter.timeAgo(project.updatedAt)}',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.insert_drive_file_outlined,
                      size: 12,
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${project.fileCount} files',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              size: 18,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
            onPressed: () {
              projectController.deleteProject(project.id);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, ProjectModel project, bool isDark) {
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
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF111827),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${project.defaultFile} • ${project.fileCount} files',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                ),
                onPressed: () => projectController.deleteProject(project.id),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            project.description.isNotEmpty ? project.description : 'Clean Python development environment',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const Spacer(),
          Divider(
            height: 12,
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Edited ${DateFormatter.timeAgo(project.updatedAt)}',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                ),
              ),
              const Row(
                children: [
                  Text(
                    'Open IDE',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFE53935)),
                  ),
                  Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFFE53935)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
