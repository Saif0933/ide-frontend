import 'package:flutter/material.dart';

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
    {'label': 'Tab', 'action': 'tab', 'isSpecial': true},
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
    {'label': '<', 'insert': '<'},
    {'label': '>', 'insert': '>'},
    {'label': '+', 'insert': ' + '},
    {'label': '-', 'insert': ' - '},
    {'label': '*', 'insert': ' * '},
    {'label': '/', 'insert': ' / '},
    {'label': ',', 'insert': ', '},
    {'label': ';', 'insert': ';'},
    {'label': '#', 'insert': '# '},
    {'label': '_', 'insert': '_'},
    {'label': '.', 'insert': '.'},
    {'label': 'def', 'insert': 'def ():\\n    ', 'offset': 4, 'isKeyword': true},
    {'label': 'print', 'insert': 'print()', 'offset': 6, 'isKeyword': true},
    {'label': 'if', 'insert': 'if :\\n    ', 'offset': 3, 'isKeyword': true},
    {'label': 'for', 'insert': 'for  in :\\n    ', 'offset': 4, 'isKeyword': true},
    {'label': 'return', 'insert': 'return ', 'isKeyword': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(
          top: BorderSide(color: Color(0xFF1E293B), width: 1),
          bottom: BorderSide(color: Color(0xFF1E293B), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Action Buttons: Undo, Redo, Save
          _buildActionIcon(
            icon: Icons.undo_rounded,
            tooltip: 'Undo',
            onTap: onUndo,
          ),
          _buildActionIcon(
            icon: Icons.redo_rounded,
            tooltip: 'Redo',
            onTap: onRedo,
          ),
          if (onSave != null)
            _buildActionIcon(
              icon: Icons.save_rounded,
              color: const Color(0xFF10B981),
              tooltip: 'Save',
              onTap: onSave!,
            ),

          // Vertical divider
          Container(
            width: 1,
            height: 22,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            color: const Color(0xFF334155),
          ),

          // Horizontal scrollable keyboard symbols
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
              itemCount: _keys.length,
              itemBuilder: (context, index) {
                final item = _keys[index];
                final isSpecial = item['isSpecial'] == true;
                final isKeyword = item['isKeyword'] == true;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.5),
                  child: Material(
                    color: Colors.transparent,
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
                        padding: EdgeInsets.symmetric(
                          horizontal: isKeyword || isSpecial ? 10 : 8,
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isKeyword
                              ? const Color(0xFFE53935).withValues(alpha: 0.15)
                              : (isSpecial
                                  ? const Color(0xFF38BDF8).withValues(alpha: 0.15)
                                  : const Color(0xFF1E293B)),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isKeyword
                                ? const Color(0xFFE53935).withValues(alpha: 0.4)
                                : (isSpecial
                                    ? const Color(0xFF38BDF8).withValues(alpha: 0.4)
                                    : const Color(0xFF334155)),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          item['label'] as String,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: isKeyword ? 11 : 12.5,
                            fontWeight: isKeyword || isSpecial ? FontWeight.bold : FontWeight.w600,
                            color: isKeyword
                                ? const Color(0xFFF87171)
                                : (isSpecial ? const Color(0xFF38BDF8) : Colors.white),
                          ),
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

  Widget _buildActionIcon({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color color = const Color(0xFF94A3B8),
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          child: Icon(icon, size: 17, color: color),
        ),
      ),
    );
  }
}
