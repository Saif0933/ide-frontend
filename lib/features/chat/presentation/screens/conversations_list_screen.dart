import 'package:flutter/material.dart';
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
    final activeProject = projectController.projects.isNotEmpty
        ? projectController.projects.first
        : null;

    return DeveloperChatScreen(
      projectId: activeProject?.id ?? 'proj_001',
      projectName: activeProject?.name ?? 'Algorithm Sandbox',
    );
  }
}
