import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/features/ide/controllers/ide_controller.dart';
import 'file_tree_node_view.dart';
import 'file_creation_dialog.dart';

class ProjectExplorerDrawer extends StatelessWidget {
  final IdeController ideController;

  const ProjectExplorerDrawer({
    super.key,
    required this.ideController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(color: AppColors.surfaceBorder, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Explorer Header
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.surfaceBorder, width: 1),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.folder_open_rounded, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                const Text(
                  'EXPLORER',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.note_add_outlined, size: 16, color: AppColors.primaryLight),
                  tooltip: 'New Python File',
                  constraints: const BoxConstraints(minWidth: 26),
                  padding: EdgeInsets.zero,
                  onPressed: () => FileCreationDialog.show(context, ideController, isFolder: false),
                ),
                IconButton(
                  icon: const Icon(Icons.create_new_folder_outlined, size: 16, color: AppColors.accentAmber),
                  tooltip: 'New Folder',
                  constraints: const BoxConstraints(minWidth: 26),
                  padding: EdgeInsets.zero,
                  onPressed: () => FileCreationDialog.show(context, ideController, isFolder: true),
                ),
                IconButton(
                  icon: const Icon(Icons.download_rounded, size: 16, color: AppColors.statusSuccess),
                  tooltip: 'Save Active File to Device',
                  constraints: const BoxConstraints(minWidth: 26),
                  padding: EdgeInsets.zero,
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final ok = await ideController.saveActiveFileToDevice();
                    if (ok && context.mounted) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('File saved to Phone/Desktop storage!')),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.file_open_outlined, size: 16, color: AppColors.accentCyan),
                  tooltip: 'Open File from Device',
                  constraints: const BoxConstraints(minWidth: 26),
                  padding: EdgeInsets.zero,
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final ok = await ideController.importExternalFiles();
                    if (ok && context.mounted) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('File imported and opened successfully!')),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.drive_folder_upload_outlined, size: 16, color: AppColors.textSecondary),
                  tooltip: 'Open Folder from Device',
                  constraints: const BoxConstraints(minWidth: 26),
                  padding: EdgeInsets.zero,
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final ok = await ideController.importExternalFolder();
                    if (ok && context.mounted) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Folder imported successfully!')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          // Project Name Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.inventory_2_outlined, size: 14, color: AppColors.accentCyan),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    ideController.project.name.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tree List
          Expanded(
            child: ideController.isLoadingTree
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : ideController.fileTree.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.folder_open_rounded, size: 36, color: AppColors.textMuted),
                              const SizedBox(height: 8),
                              const Text(
                                'No files yet in project.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () => ideController.importExternalFiles(),
                                icon: const Icon(Icons.file_open_rounded, size: 14),
                                label: const Text('Open from File Manager', style: TextStyle(fontSize: 11)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.surfaceLight,
                                  foregroundColor: AppColors.accentCyan,
                                  minimumSize: const Size(0, 32),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    side: const BorderSide(color: AppColors.surfaceBorder),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        itemCount: ideController.fileTree.length,
                        itemBuilder: (context, index) {
                          return FileTreeNodeView(
                            node: ideController.fileTree[index],
                            ideController: ideController,
                          );
                        },
                      ),
          ),

          // Bottom Quick Device File Manager Actions Bar
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.surfaceLight,
              border: Border(
                top: BorderSide(color: AppColors.surfaceBorder, width: 1),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final ok = await ideController.saveActiveFileToDevice();
                    if (ok && context.mounted) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Active file saved to Phone/Desktop!')),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.download_rounded, size: 15, color: AppColors.statusSuccess),
                        SizedBox(width: 6),
                        Text(
                          'Save Active File to Device',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final ok = await ideController.exportEntireProjectToDevice();
                    if (ok && context.mounted) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Project exported to Phone/Desktop folder!')),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_zip_rounded, size: 15, color: AppColors.accentPurple),
                        SizedBox(width: 6),
                        Text(
                          'Export Project to Device',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final ok = await ideController.importExternalFiles();
                          if (ok && context.mounted) {
                            messenger.showSnackBar(
                              const SnackBar(content: Text('File imported from device!')),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.surfaceBorder),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.file_open_rounded, size: 14, color: AppColors.accentCyan),
                              SizedBox(width: 4),
                              Text(
                                'Open File',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final ok = await ideController.importExternalFolder();
                          if (ok && context.mounted) {
                            messenger.showSnackBar(
                              const SnackBar(content: Text('Folder imported from device!')),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.surfaceBorder),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.drive_folder_upload_rounded, size: 14, color: AppColors.accentAmber),
                              SizedBox(width: 4),
                              Text(
                                'Open Folder',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
