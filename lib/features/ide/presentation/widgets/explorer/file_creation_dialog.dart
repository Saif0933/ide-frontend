import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/shared/widgets/custom_button.dart';
import 'package:frontend/shared/widgets/custom_text_field.dart';
import 'package:frontend/features/ide/controllers/ide_controller.dart';

class FileCreationDialog extends StatefulWidget {
  final IdeController ideController;
  final String? parentId;
  final bool isFolder;

  const FileCreationDialog({
    super.key,
    required this.ideController,
    this.parentId,
    this.isFolder = false,
  });

  static Future<void> show(
    BuildContext context,
    IdeController controller, {
    String? parentId,
    bool isFolder = false,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => FileCreationDialog(
        ideController: controller,
        parentId: parentId,
        isFolder: isFolder,
      ),
    );
  }

  @override
  State<FileCreationDialog> createState() => _FileCreationDialogState();
}

class _FileCreationDialogState extends State<FileCreationDialog> {
  final _nameController = TextEditingController();
  String? _errorText;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = 'Name cannot be empty');
      return;
    }

    if (name.contains('..') || name.contains('/') || name.contains('\\')) {
      setState(() => _errorText = 'Invalid name. Avoid slashes or ".."');
      return;
    }

    setState(() {
      _errorText = null;
      _isLoading = true;
    });

    try {
      if (widget.isFolder) {
        await widget.ideController.createNewFolder(name, parentId: widget.parentId);
      } else {
        final fileName = name.contains('.') ? name : '$name.py';
        await widget.ideController.createNewFile(fileName, parentId: widget.parentId);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _errorText = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isFolder ? 'Create New Folder' : 'Create New Python File';

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            widget.isFolder ? Icons.create_new_folder_rounded : Icons.note_add_rounded,
            color: widget.isFolder ? AppColors.accentAmber : AppColors.primaryLight,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: _nameController,
            hintText: widget.isFolder ? 'e.g. services' : 'e.g. solver.py',
            autofocus: true,
            onSubmitted: (_) => _handleSubmit(),
          ),
          if (_errorText != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorText!,
              style: const TextStyle(color: AppColors.accentRed, fontSize: 11),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
        ),
        CustomButton(
          label: 'Create',
          isLoading: _isLoading,
          height: 36,
          onPressed: _handleSubmit,
        ),
      ],
    );
  }
}
