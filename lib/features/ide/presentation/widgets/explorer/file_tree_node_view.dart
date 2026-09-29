import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/features/ide/models/file_node_model.dart';
import 'package:frontend/features/ide/controllers/ide_controller.dart';
import 'file_creation_dialog.dart';

class FileTreeNodeView extends StatefulWidget {
  final FileNodeModel node;
  final IdeController ideController;
  final int depth;

  const FileTreeNodeView({
    super.key,
    required this.node,
    required this.ideController,
    this.depth = 0,
  });

  @override
  State<FileTreeNodeView> createState() => _FileTreeNodeViewState();
}

class _FileTreeNodeViewState extends State<FileTreeNodeView> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final node = widget.node;
    final isActive = !node.isFolder &&
        widget.ideController.activeTab?.fileId == node.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            if (node.isFolder) {
              setState(() => _isExpanded = !_isExpanded);
            } else {
              widget.ideController.openFile(node);
            }
          },
          onLongPress: () => _showContextMenu(context, node),
          borderRadius: BorderRadius.circular(6),
          hoverColor: AppColors.surfaceHover,
          child: Container(
            height: 32,
            padding: EdgeInsets.only(left: 12.0 + (widget.depth * 14.0), right: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: isActive
                  ? Border.all(color: AppColors.primary.withValues(alpha: 0.4))
                  : null,
            ),
            child: Row(
              children: [
                if (node.isFolder) ...[
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_right_rounded,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.folder_rounded, size: 16, color: AppColors.accentAmber),
                ] else ...[
                  const SizedBox(width: 4),
                  _buildFileIcon(node.name),
                ],
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    node.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive ? AppColors.primaryLight : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (!node.isFolder && node.version > 1)
                  Text(
                    'v${node.version}',
                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                  ),
              ],
            ),
          ),
        ),
        if (node.isFolder && _isExpanded && node.children.isNotEmpty)
          ...node.children.map(
            (child) => FileTreeNodeView(
              node: child,
              ideController: widget.ideController,
              depth: widget.depth + 1,
            ),
          ),
      ],
    );
  }

  Widget _buildFileIcon(String filename) {
    if (filename.endsWith('.py')) {
      return const Icon(Icons.code_rounded, size: 15, color: AppColors.accentCyan);
    } else if (filename.endsWith('.md')) {
      return const Icon(Icons.description_rounded, size: 15, color: AppColors.accentPurple);
    } else if (filename.endsWith('.json') || filename.endsWith('.yaml')) {
      return const Icon(Icons.data_object_rounded, size: 15, color: AppColors.accentAmber);
    }
    return const Icon(Icons.insert_drive_file_rounded, size: 15, color: AppColors.textMuted);
  }

  void _showContextMenu(BuildContext context, FileNodeModel node) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              if (!node.isFolder) ...[
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.download_rounded, color: AppColors.accentCyan),
                  title: const Text('Save to Phone / Desktop'),
                  subtitle: const Text('Export file to device storage', style: TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(ctx);
                    final ok = await widget.ideController.saveFileNodeToDevice(node);
                    if (ok && mounted) {
                      messenger.showSnackBar(
                        SnackBar(content: Text('${node.name} saved to device storage!')),
                      );
                    }
                  },
                ),
              ],
              if (node.isFolder) ...[
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.note_add_outlined, color: AppColors.primaryLight),
                  title: const Text('New File inside folder'),
                  onTap: () {
                    Navigator.pop(ctx);
                    FileCreationDialog.show(context, widget.ideController, parentId: node.id, isFolder: false);
                  },
                ),
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.create_new_folder_outlined, color: AppColors.accentAmber),
                  title: const Text('New Folder inside folder'),
                  onTap: () {
                    Navigator.pop(ctx);
                    FileCreationDialog.show(context, widget.ideController, parentId: node.id, isFolder: true);
                  },
                ),
              ],
              ListTile(
                dense: true,
                leading: const Icon(Icons.drive_file_rename_outline, color: AppColors.textPrimary),
                title: Text('Rename ${node.name}'),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.copy_rounded, color: AppColors.textPrimary),
                title: const Text('Copy Relative Path'),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.delete_outline_rounded, color: AppColors.accentRed),
                title: const Text('Delete', style: TextStyle(color: AppColors.accentRed)),
                onTap: () {
                  Navigator.pop(ctx);
                  widget.ideController.deleteNode(node.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
