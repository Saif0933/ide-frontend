import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/features/ide/controllers/ide_controller.dart';
import 'package:frontend/features/chat/models/message_context.dart';

class ContextAttachmentSheet extends StatelessWidget {
  final IdeController ideController;
  final void Function(MessageContext context) onSelectContext;

  const ContextAttachmentSheet({
    super.key,
    required this.ideController,
    required this.onSelectContext,
  });

  static void show(
    BuildContext context,
    IdeController ideController,
    void Function(MessageContext context) onSelectContext,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => ContextAttachmentSheet(
        ideController: ideController,
        onSelectContext: (c) {
          Navigator.pop(ctx);
          onSelectContext(c);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeTab = ideController.activeTab;
    final lastExecution = ideController.currentExecution;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
            const SizedBox(height: 14),
            const Text(
              'Attach Context to Developer Chat',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            const Text(
              'Share live code, error traces, or file references with your mentor.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),

            // Option 1: Current Active File
            if (activeTab != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accentCyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.code_rounded, color: AppColors.accentCyan, size: 20),
                ),
                title: Text('Current File: ${activeTab.title}', style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                subtitle: Text('Lines 1-${activeTab.currentContent.split('\n').length} • ${activeTab.path}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                onTap: () {
                  onSelectContext(
                    MessageContext(
                      id: 'ctx_${DateTime.now().millisecondsSinceEpoch}',
                      projectId: ideController.project.id,
                      fileId: activeTab.fileId,
                      fileName: activeTab.title,
                      lineStart: 1,
                      lineEnd: activeTab.currentContent.split('\n').length,
                      codeSnippet: activeTab.currentContent,
                      type: MessageContextType.fullFile,
                    ),
                  );
                },
              ),

            // Option 2: Execution Error Traceback
            if (lastExecution?.stderr != null || ideController.terminalLogs.any((l) => l.stream.name == 'stderr'))
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accentRed.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.error_outline_rounded, color: AppColors.accentRed, size: 20),
                ),
                title: const Text('Latest Execution Error', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                subtitle: const Text('Includes Python stderr traceback and line numbers', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                onTap: () {
                  onSelectContext(ideController.buildErrorContext());
                },
              ),

            // Option 3: Cursor Line Context
            if (activeTab != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accentPurple.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.pin_drop_outlined, color: AppColors.accentPurple, size: 20),
                ),
                title: Text('Cursor Line: Line ${activeTab.cursorLine}', style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                subtitle: const Text('Focus developer attention on your current cursor position', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                onTap: () {
                  onSelectContext(
                    MessageContext(
                      id: 'ctx_cur_${DateTime.now().millisecondsSinceEpoch}',
                      projectId: ideController.project.id,
                      fileId: activeTab.fileId,
                      fileName: activeTab.title,
                      lineStart: activeTab.cursorLine,
                      lineEnd: activeTab.cursorLine,
                      codeSnippet: activeTab.currentContent,
                      type: MessageContextType.fileSnippet,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
