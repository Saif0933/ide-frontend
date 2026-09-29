import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';

class EditorQuickKeys extends StatelessWidget {
  final void Function(String text, {int cursorOffset}) onInsertText;
  final VoidCallback onTab;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback? onSave;

  const EditorQuickKeys({
    super.key,
    required this.onInsertText,
    required this.onTab,
    required this.onUndo,
    required this.onRedo,
    this.onSave,
  });

  static const List<Map<String, dynamic>> _keys = [
    {'label': 'Tab', 'action': 'tab'},
    {'label': ':', 'insert': ':'},
    {'label': '(', 'insert': '()', 'offset': 1},
    {'label': ')', 'insert': ')'},
    {'label': '"', 'insert': '""', 'offset': 1},
    {'label': "'", 'insert': "''", 'offset': 1},
    {'label': '=', 'insert': ' = '},
    {'label': '[', 'insert': '[]', 'offset': 1},
    {'label': ']', 'insert': ']'},
    {'label': '{', 'insert': '{}', 'offset': 1},
    {'label': '}', 'insert': '}'},
    {'label': '#', 'insert': '# '},
    {'label': '_', 'insert': '_'},
    {'label': '.', 'insert': '.'},
    {'label': 'def', 'insert': 'def ():\\n    ', 'offset': 4},
    {'label': 'print', 'insert': 'print()', 'offset': 6},
    {'label': 'if', 'insert': 'if :\\n    ', 'offset': 3},
    {'label': 'for', 'insert': 'for  in :\\n    ', 'offset': 4},
    {'label': 'return', 'insert': 'return '},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.surfaceBorder, width: 1),
          bottom: BorderSide(color: AppColors.surfaceBorder, width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.undo_rounded, size: 18, color: AppColors.textSecondary),
            tooltip: 'Undo',
            padding: const EdgeInsets.symmetric(horizontal: 8),
            constraints: const BoxConstraints(minWidth: 36),
            onPressed: onUndo,
          ),
          IconButton(
            icon: const Icon(Icons.redo_rounded, size: 18, color: AppColors.textSecondary),
            tooltip: 'Redo',
            padding: const EdgeInsets.symmetric(horizontal: 8),
            constraints: const BoxConstraints(minWidth: 36),
            onPressed: onRedo,
          ),
          if (onSave != null)
            IconButton(
              icon: const Icon(Icons.save_rounded, size: 18, color: AppColors.statusSuccess),
              tooltip: 'Save (Ctrl+S)',
              padding: const EdgeInsets.symmetric(horizontal: 8),
              constraints: const BoxConstraints(minWidth: 36),
              onPressed: onSave,
            ),
          Container(width: 1, height: 20, color: AppColors.surfaceBorder),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              itemCount: _keys.length,
              itemBuilder: (context, index) {
                final item = _keys[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
                  child: InkWell(
                    onTap: () {
                      if (item['action'] == 'tab') {
                        onTab();
                      } else {
                        final insert = item['insert'] as String;
                        final offset = item['offset'] as int? ?? insert.length;
                        onInsertText(insert, cursorOffset: offset);
                      }
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.surfaceBorder, width: 0.8),
                      ),
                      child: Text(
                        item['label'] as String,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
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
