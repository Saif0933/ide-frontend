import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/shared/widgets/custom_button.dart';
import 'package:frontend/shared/widgets/custom_text_field.dart';
import 'package:frontend/features/projects/models/template_model.dart';
import 'package:frontend/features/projects/models/project_model.dart';
import 'package:frontend/features/projects/controllers/project_controller.dart';
import 'package:frontend/features/ide/presentation/screens/ide_workspace_screen.dart';

class CreateProjectDialog extends StatefulWidget {
  final ProjectController projectController;

  const CreateProjectDialog({
    super.key,
    required this.projectController,
  });

  static void show(BuildContext context, ProjectController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => CreateProjectDialog(projectController: controller),
    );
  }

  @override
  State<CreateProjectDialog> createState() => _CreateProjectDialogState();
}

class _CreateProjectDialogState extends State<CreateProjectDialog> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedTemplateId = 'empty_python';
  ProjectVisibility _visibility = ProjectVisibility.privateProject;
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = 'Project name is required');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final newProject = await widget.projectController.createProject(
      name: name,
      description: _descController.text.trim(),
      templateId: _selectedTemplateId,
      visibility: _visibility,
    );

    setState(() => _isLoading = false);

    if (newProject != null && mounted) {
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => IdeWorkspaceScreen(project: newProject),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
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
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.add_box_rounded, color: AppColors.primaryLight, size: 22),
                SizedBox(width: 8),
                Text(
                  'Create New Python Project',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            CustomTextField(
              label: 'Project Name *',
              hintText: 'e.g. Data Analytics Engine',
              controller: _nameController,
              autofocus: true,
            ),
            const SizedBox(height: 12),

            CustomTextField(
              label: 'Description (Optional)',
              hintText: 'Short summary of the project...',
              controller: _descController,
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            const Text(
              'Select Starter Template',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),

            ...TemplateModel.defaultTemplates.map((template) {
              final isSelected = _selectedTemplateId == template.id;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.surfaceBorder,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: ListTile(
                  dense: true,
                  leading: Icon(
                    template.id == 'empty_python' ? Icons.code_rounded : (template.id == 'python_starter' ? Icons.rocket_launch_rounded : Icons.terminal_rounded),
                    color: isSelected ? AppColors.primaryLight : AppColors.textMuted,
                  ),
                  title: Text(
                    template.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primaryLight : AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    template.description,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18)
                      : null,
                  onTap: () => setState(() => _selectedTemplateId = template.id),
                ),
              );
            }),

            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Visibility: ', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ChoiceChip(
                  label: const Text('Private'),
                  selected: _visibility == ProjectVisibility.privateProject,
                  selectedColor: AppColors.primary.withValues(alpha: 0.3),
                  onSelected: (_) => setState(() => _visibility = ProjectVisibility.privateProject),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Public'),
                  selected: _visibility == ProjectVisibility.publicProject,
                  selectedColor: AppColors.primary.withValues(alpha: 0.3),
                  onSelected: (_) => setState(() => _visibility = ProjectVisibility.publicProject),
                ),
              ],
            ),

            if (_errorText != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorText!,
                style: const TextStyle(color: AppColors.accentRed, fontSize: 11.5),
              ),
            ],

            const SizedBox(height: 20),
            CustomButton(
              label: 'Create & Launch IDE',
              isGradient: true,
              isLoading: _isLoading,
              onPressed: _handleCreate,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
