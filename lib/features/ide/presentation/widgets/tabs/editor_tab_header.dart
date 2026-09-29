import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/features/ide/controllers/ide_controller.dart';
import '../explorer/file_creation_dialog.dart';

class EditorTabHeader extends StatelessWidget {
  final IdeController ideController;

  const EditorTabHeader({
    super.key,
    required this.ideController,
  });

  @override
  Widget build(BuildContext context) {
    if (ideController.openTabs.isEmpty) {
      return Container(
        height: 38,
        color: AppColors.surface,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            const Text(
              'No file open',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.note_add_outlined, size: 16, color: AppColors.primaryLight),
              tooltip: 'New Python File',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28),
              onPressed: () => FileCreationDialog.show(context, ideController, isFolder: false),
            ),
            IconButton(
              icon: const Icon(Icons.create_new_folder_outlined, size: 16, color: AppColors.accentAmber),
              tooltip: 'New Folder',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28),
              onPressed: () => FileCreationDialog.show(context, ideController, isFolder: true),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 38,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.surfaceBorder, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: ideController.openTabs.length,
              itemBuilder: (context, index) {
                final tab = ideController.openTabs[index];
                final isActive = index == ideController.activeTabIndex;

                return InkWell(
                  onTap: () => ideController.switchTab(index),
                  child: Container(
                    padding: const EdgeInsets.only(left: 12, right: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.editorBackground : AppColors.surface,
                      border: Border(
                        top: BorderSide(
                          color: isActive ? AppColors.primary : Colors.transparent,
                          width: 2,
                        ),
                        right: const BorderSide(color: AppColors.surfaceBorder, width: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tab.title.endsWith('.py') ? Icons.code : Icons.description_outlined,
                          size: 14,
                          color: tab.title.endsWith('.py') ? AppColors.accentCyan : AppColors.textMuted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          tab.title,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                            color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (tab.isDirty)
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(right: 4),
                            decoration: const BoxDecoration(
                              color: AppColors.statusQueued,
                              shape: BoxShape.circle,
                            ),
                          ),
                        InkWell(
                          onTap: () => ideController.closeTab(index),
                          borderRadius: BorderRadius.circular(4),
                          child: const Padding(
                            padding: EdgeInsets.all(3),
                            child: Icon(Icons.close_rounded, size: 13, color: AppColors.textMuted),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.note_add_outlined, size: 16, color: AppColors.primaryLight),
            tooltip: 'New Python File',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28),
            onPressed: () => FileCreationDialog.show(context, ideController, isFolder: false),
          ),
          IconButton(
            icon: const Icon(Icons.create_new_folder_outlined, size: 16, color: AppColors.accentAmber),
            tooltip: 'New Folder',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28),
            onPressed: () => FileCreationDialog.show(context, ideController, isFolder: true),
          ),
        ],
      ),
    );
  }
}
