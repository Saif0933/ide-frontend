import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../features/execution/models/execution_job.dart';

class StatusPill extends StatelessWidget {
  final ExecutionStatus status;
  final bool showIcon;
  final double fontSize;

  const StatusPill({
    super.key,
    required this.status,
    this.showIcon = true,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String label;

    switch (status) {
      case ExecutionStatus.queued:
        color = AppColors.statusQueued;
        icon = Icons.schedule_rounded;
        label = 'Queued';
        break;
      case ExecutionStatus.running:
        color = AppColors.statusRunning;
        icon = Icons.sync_rounded;
        label = 'Running';
        break;
      case ExecutionStatus.completed:
        color = AppColors.statusSuccess;
        icon = Icons.check_circle_rounded;
        label = 'Success';
        break;
      case ExecutionStatus.failed:
        color = AppColors.statusFailed;
        icon = Icons.error_rounded;
        label = 'Failed';
        break;
      case ExecutionStatus.timedOut:
        color = AppColors.statusTimedOut;
        icon = Icons.timer_off_rounded;
        label = 'Timed Out';
        break;
      case ExecutionStatus.cancelled:
        color = AppColors.statusCancelled;
        icon = Icons.cancel_rounded;
        label = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(icon, size: fontSize + 2, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
