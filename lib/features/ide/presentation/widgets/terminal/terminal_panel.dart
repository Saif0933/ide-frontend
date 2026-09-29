import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 16),
            SizedBox(width: 8),
            Text('Terminal output copied to clipboard', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exec = widget.ideController.currentExecution;
    final hasErrors = widget.ideController.terminalLogs.any((l) => l.stream == LogStreamType.stderr);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF090D16),
        border: Border(
          top: BorderSide(color: Color(0xFF1E293B), width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Responsive Terminal Toolbar Header (No Overflow Guaranteed)
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              border: Border(
                bottom: BorderSide(color: Color(0xFF1E293B), width: 1),
              ),
            ),
            child: Row(
              children: [
                // Left: Title & Status
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.terminal_rounded, size: 14, color: Color(0xFF38BDF8)),
                ),
                const SizedBox(width: 6),
                const Text(
                  'TERMINAL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 6),
                if (widget.ideController.isExecuting)
                  const StatusPill(status: ExecutionStatus.running, fontSize: 9.5)
                else if (exec != null)
                  StatusPill(status: exec.status, fontSize: 9.5),

                // Right Actions inside SingleChildScrollView to prevent any overflow on small devices
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Ask Developer CTA (Gradient Pill for AI Debugging)
                          if (hasErrors || exec?.hasFailed == true)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: InkWell(
                                onTap: widget.onAskDeveloper,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.auto_awesome_rounded, size: 12, color: Colors.white),
                                      SizedBox(width: 4),
                                      Text(
                                        'Ask Developer',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          // Quick Action Buttons
                          _buildHeaderIconBtn(
                            icon: Icons.copy_rounded,
                            tooltip: 'Copy Logs',
                            onTap: _copyTerminalLogs,
                          ),
                          _buildHeaderIconBtn(
                            icon: Icons.block_rounded,
                            tooltip: 'Clear Output',
                            onTap: widget.ideController.clearTerminal,
                          ),
                          _buildHeaderIconBtn(
                            icon: Icons.keyboard_arrow_down_rounded,
                            tooltip: 'Minimize Terminal',
                            onTap: widget.ideController.toggleTerminal,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Execution Metadata Bar
          if (exec != null && !widget.ideController.isExecuting)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              color: const Color(0xFF0F172A).withValues(alpha: 0.6),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: exec.exitCode == 0
                            ? const Color(0xFF10B981).withValues(alpha: 0.15)
                            : const Color(0xFFEF4444).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Exit Code: ${exec.exitCode ?? 0}',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: exec.exitCode == 0 ? const Color(0xFF34D399) : const Color(0xFFF87171),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (exec.durationMs != null)
                      Text(
                        '⏱ ${exec.durationMs}ms',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    const SizedBox(width: 8),
                    if (exec.memoryUsage != null)
                      Text(
                        '⚡ ${exec.memoryUsage}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // Terminal Log Output
          Expanded(
            child: widget.ideController.terminalLogs.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Python 3.12.2 Sandbox ready.',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11.5,
                                color: Color(0xFF38BDF8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tap "Run" in top bar to execute script.',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    physics: const BouncingScrollPhysics(),
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

  Widget _buildHeaderIconBtn({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        child: Icon(icon, size: 15, color: const Color(0xFF94A3B8)),
      ),
    );
  }

  Widget _buildLogLine(ExecutionLog log) {
    Color textColor = const Color(0xFFE2E8F0);
    FontWeight weight = FontWeight.w400;

    if (log.stream == LogStreamType.stderr) {
      textColor = const Color(0xFFF87171);
      weight = FontWeight.w500;
    } else if (log.stream == LogStreamType.system) {
      textColor = const Color(0xFF38BDF8);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: SelectableText(
        log.content,
        style: AppTheme.codeStyle(
          fontSize: 11.5,
          color: textColor,
          fontWeight: weight,
          height: 1.35,
        ),
      ),
    );
  }
}
