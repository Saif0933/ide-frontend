import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/chat/models/message_context.dart';

class ContextPreviewCard extends StatefulWidget {
  final MessageContext contextAttachment;

  const ContextPreviewCard({
    super.key,
    required this.contextAttachment,
  });

  @override
  State<ContextPreviewCard> createState() => _ContextPreviewCardState();
}

class _ContextPreviewCardState extends State<ContextPreviewCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final ctx = widget.contextAttachment;
    final isError = ctx.type == MessageContextType.executionError;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isError
            ? AppColors.accentRed.withValues(alpha: 0.1)
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isError
              ? AppColors.accentRed.withValues(alpha: 0.3)
              : AppColors.surfaceBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isError ? Icons.error_outline_rounded : Icons.code_rounded,
                size: 15,
                color: isError ? AppColors.accentRed : AppColors.accentCyan,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isError
                      ? 'Error Context (${ctx.fileName ?? 'main.py'})'
                      : 'File Context: ${ctx.fileName ?? 'main.py'} (Ln ${ctx.lineStart ?? 1}-${ctx.lineEnd ?? 1})',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isError ? AppColors.accentRed : AppColors.primaryLight,
                  ),
                ),
              ),
              if (ctx.codeSnippet != null || ctx.errorTraceback != null)
                InkWell(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Text(
                    _isExpanded ? 'Hide' : 'View Code',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
            ],
          ),
          if (ctx.errorSummary != null) ...[
            const SizedBox(height: 4),
            Text(
              ctx.errorSummary!,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: AppColors.textPrimary,
              ),
            ),
          ],
          if (_isExpanded && (ctx.errorTraceback != null || ctx.codeSnippet != null)) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.editorBackground,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: SelectableText(
                (ctx.errorTraceback ?? ctx.codeSnippet)!,
                style: AppTheme.codeStyle(
                  fontSize: 11,
                  color: isError ? AppColors.terminalStderr : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
