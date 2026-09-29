import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/features/ide/models/diagnostic_issue.dart';
import 'package:frontend/features/ide/controllers/ide_controller.dart';

class ProblemsPanel extends StatelessWidget {
  final IdeController ideController;

  const ProblemsPanel({
    super.key,
    required this.ideController,
  });

  @override
  Widget build(BuildContext context) {
    final issues = ideController.diagnostics;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.surfaceBorder, width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: AppColors.surfaceLight,
            child: Row(
              children: [
                const Icon(Icons.bug_report_rounded, size: 16, color: AppColors.accentRed),
                const SizedBox(width: 8),
                Text(
                  'PROBLEMS (${issues.length})',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textSecondary),
                  tooltip: 'Close Problems',
                  constraints: const BoxConstraints(minWidth: 28),
                  padding: EdgeInsets.zero,
                  onPressed: ideController.toggleProblems,
                ),
              ],
            ),
          ),

          // Problem List
          Expanded(
            child: issues.isEmpty
                ? const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 16, color: AppColors.statusSuccess),
                        SizedBox(width: 8),
                        Text(
                          'No problems detected in the current file.',
                          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: issues.length,
                    itemBuilder: (context, index) {
                      final issue = issues[index];
                      return ListTile(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        leading: Icon(
                          issue.severity == DiagnosticSeverity.error
                              ? Icons.error_outline_rounded
                              : Icons.warning_amber_rounded,
                          size: 18,
                          color: issue.severity == DiagnosticSeverity.error
                              ? AppColors.accentRed
                              : AppColors.accentAmber,
                        ),
                        title: Text(
                          issue.message,
                          style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
                        ),
                        subtitle: Text(
                          '${issue.filePath} [Line ${issue.line}, Col ${issue.column}] • ${issue.source}',
                          style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
