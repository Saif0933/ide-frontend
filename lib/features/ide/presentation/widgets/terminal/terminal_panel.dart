import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/execution/models/execution_log.dart';
import 'package:frontend/features/execution/models/execution_job.dart';
import 'package:frontend/features/ide/controllers/ide_controller.dart';
import 'package:frontend/shared/widgets/status_pill.dart';

class TerminalPanel extends StatefulWidget {
  final IdeController ideController;
  final VoidCallback onAskDeveloper;

  const TerminalPanel({
    super.key,
    required this.ideController,
    required this.onAskDeveloper,
  });

  @override
  State<TerminalPanel> createState() => _TerminalPanelState();
}

class _TerminalPanelState extends State<TerminalPanel> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant TerminalPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ideController.terminalLogs.length != oldWidget.ideController.terminalLogs.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _copyTerminalLogs() {
    final text = widget.ideController.terminalLogs.map((l) => l.content).join('\n');
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Terminal output copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exec = widget.ideController.currentExecution;
    final hasErrors = widget.ideController.terminalLogs
        .any((l) => l.stream == LogStreamType.stderr);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.terminalBackground,
        border: Border(
          top: BorderSide(color: AppColors.surfaceBorder, width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Terminal Toolbar Header
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: AppColors.surface,
            child: Row(
              children: [
                const Icon(Icons.terminal_rounded, size: 16, color: AppColors.accentCyan),
                const SizedBox(width: 8),
                const Text(
                  'TERMINAL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                if (widget.ideController.isExecuting)
                  const StatusPill(status: ExecutionStatus.running, fontSize: 10)
                else if (exec != null)
                  StatusPill(status: exec.status, fontSize: 10),

                const Spacer(),

                // Ask Developer CTA (High Priority Button when error occurs)
                if (hasErrors || exec?.hasFailed == true)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ElevatedButton.icon(
                      onPressed: widget.onAskDeveloper,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentPurple.withValues(alpha: 0.2),
                        foregroundColor: AppColors.accentPurple,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: const Size(0, 26),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                          side: const BorderSide(color: AppColors.accentPurple, width: 0.8),
                        ),
                      ),
                      icon: const Icon(Icons.contact_support_rounded, size: 13),
                      label: const Text(
                        'Ask Developer',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 15, color: AppColors.textSecondary),
                  tooltip: 'Copy Output',
                  constraints: const BoxConstraints(minWidth: 28),
                  padding: EdgeInsets.zero,
                  onPressed: _copyTerminalLogs,
                ),
                IconButton(
                  icon: const Icon(Icons.block_rounded, size: 15, color: AppColors.textSecondary),
                  tooltip: 'Clear Output',
                  constraints: const BoxConstraints(minWidth: 28),
                  padding: EdgeInsets.zero,
                  onPressed: widget.ideController.clearTerminal,
                ),
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.textSecondary),
                  tooltip: 'Minimize',
                  constraints: const BoxConstraints(minWidth: 28),
                  padding: EdgeInsets.zero,
                  onPressed: widget.ideController.toggleTerminal,
                ),
              ],
            ),
          ),

          // Execution Metadata Bar
          if (exec != null && !widget.ideController.isExecuting)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              color: AppColors.surfaceLight.withValues(alpha: 0.5),
              child: Row(
                children: [
                  Text(
                    'Exit Code: ${exec.exitCode ?? 0}',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: exec.exitCode == 0 ? AppColors.statusSuccess : AppColors.statusFailed,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (exec.durationMs != null)
                    Text(
                      'Duration: ${exec.durationMs}ms',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  const SizedBox(width: 12),
                  if (exec.memoryUsage != null)
                    Text(
                      'Mem: ${exec.memoryUsage}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                ],
              ),
            ),

          // Terminal Log Output
          Expanded(
            child: widget.ideController.terminalLogs.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Python 3.12.2 Sandbox ready.\nPress "Run" to execute your script.',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(10),
                    itemCount: widget.ideController.terminalLogs.length,
                    itemBuilder: (context, index) {
                      final log = widget.ideController.terminalLogs[index];
                      return _buildLogLine(log);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogLine(ExecutionLog log) {
    Color textColor = AppColors.terminalStdout;
    FontWeight weight = FontWeight.w400;

    if (log.stream == LogStreamType.stderr) {
      textColor = AppColors.terminalStderr;
      weight = FontWeight.w500;
    } else if (log.stream == LogStreamType.system) {
      textColor = AppColors.accentCyan;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: SelectableText(
        log.content,
        style: AppTheme.codeStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: weight,
          height: 1.4,
        ),
      ),
    );
  }
}
