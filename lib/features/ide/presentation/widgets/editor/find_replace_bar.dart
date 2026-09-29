import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';

class FindReplaceBar extends StatefulWidget {
  final void Function(String query, {bool matchCase, bool isRegex}) onFind;
  final void Function(String query, String replacement) onReplaceAll;
  final VoidCallback onClose;

  const FindReplaceBar({
    super.key,
    required this.onFind,
    required this.onReplaceAll,
    required this.onClose,
  });

  @override
  State<FindReplaceBar> createState() => _FindReplaceBarState();
}

class _FindReplaceBarState extends State<FindReplaceBar> {
  final _findController = TextEditingController();
  final _replaceController = TextEditingController();
  bool _matchCase = false;
  bool _isRegex = false;
  bool _showReplace = false;

  @override
  void dispose() {
    _findController.dispose();
    _replaceController.dispose();
    super.dispose();
  }

  void _triggerFind() {
    widget.onFind(
      _findController.text,
      matchCase: _matchCase,
      isRegex: _isRegex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          bottom: BorderSide(color: AppColors.surfaceBorder, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  _showReplace ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24),
                onPressed: () => setState(() => _showReplace = !_showReplace),
              ),
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: TextField(
                    controller: _findController,
                    onChanged: (_) => _triggerFind(),
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Find in file...',
                      hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildOptionChip('Aa', _matchCase, () {
                            setState(() => _matchCase = !_matchCase);
                            _triggerFind();
                          }),
                          _buildOptionChip('.*', _isRegex, () {
                            setState(() => _isRegex = !_isRegex);
                            _triggerFind();
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
                constraints: const BoxConstraints(minWidth: 28),
                onPressed: widget.onClose,
              ),
            ],
          ),
          if (_showReplace) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const SizedBox(width: 24),
                Expanded(
                  child: SizedBox(
                    height: 32,
                    child: TextField(
                      controller: _replaceController,
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Replace with...',
                        hintStyle: TextStyle(fontSize: 12, color: AppColors.textMuted),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_findController.text.isNotEmpty) {
                      widget.onReplaceAll(_findController.text, _replaceController.text);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceLight,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    elevation: 0,
                    minimumSize: const Size(0, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                      side: const BorderSide(color: AppColors.surfaceBorder),
                    ),
                  ),
                  child: const Text('Replace All', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionChip(String label, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withValues(alpha: 0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: active ? AppColors.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: active ? AppColors.primaryLight : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
