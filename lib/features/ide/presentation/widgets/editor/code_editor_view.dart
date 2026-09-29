import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/ide/models/editor_tab_model.dart';
import 'package:frontend/features/ide/controllers/ide_controller.dart';
import 'custom_python_highlighter.dart';
import 'editor_quick_keys.dart';
import 'find_replace_bar.dart';

class CodeEditorView extends StatefulWidget {
  final IdeController ideController;
  final EditorTabModel activeTab;

  const CodeEditorView({
    super.key,
    required this.ideController,
    required this.activeTab,
  });

  @override
  State<CodeEditorView> createState() => _CodeEditorViewState();
}

class _CodeEditorViewState extends State<CodeEditorView> {
  late PythonSyntaxHighlighter _textController;
  late ScrollController _verticalScrollController;
  late ScrollController _gutterScrollController;
  late FocusNode _focusNode;

  // Undo/Redo History
  final List<String> _undoStack = [];
  final List<String> _redoStack = [];
  bool _isPerformingUndoRedo = false;

  int _currentLineNumber = 1;
  int _currentColumnNumber = 1;

  @override
  void initState() {
    super.initState();
    _verticalScrollController = ScrollController();
    _gutterScrollController = ScrollController();
    _focusNode = FocusNode();

    _textController = PythonSyntaxHighlighter(
      text: widget.activeTab.currentContent,
      syntaxTheme: widget.ideController.syntaxTheme,
      fontSize: widget.ideController.fontSize,
    );

    _undoStack.add(widget.activeTab.currentContent);

    _textController.addListener(_onTextChanged);
    _verticalScrollController.addListener(_syncScroll);
  }

  @override
  void didUpdateWidget(covariant CodeEditorView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.activeTab.id != widget.activeTab.id) {
      _textController.text = widget.activeTab.currentContent;
      _undoStack.clear();
      _redoStack.clear();
      _undoStack.add(widget.activeTab.currentContent);
    }

    _textController.syntaxTheme = widget.ideController.syntaxTheme;
    _textController.fontSize = widget.ideController.fontSize;
  }

  void _syncScroll() {
    if (_gutterScrollController.hasClients && _verticalScrollController.hasClients) {
      if (_gutterScrollController.offset != _verticalScrollController.offset) {
        _gutterScrollController.jumpTo(_verticalScrollController.offset);
      }
    }
  }

  void _onTextChanged() {
    final text = _textController.text;

    // Track Cursor position
    final selection = _textController.selection;
    if (selection.isValid && selection.baseOffset >= 0) {
      final prefix = text.substring(0, selection.baseOffset);
      final lines = prefix.split('\n');
      _currentLineNumber = lines.length;
      _currentColumnNumber = lines.last.length + 1;
      widget.ideController.updateCursorPosition(_currentLineNumber, _currentColumnNumber);
    }

    if (!_isPerformingUndoRedo) {
      if (_undoStack.isEmpty || _undoStack.last != text) {
        _undoStack.add(text);
        if (_undoStack.length > 50) _undoStack.removeAt(0);
        _redoStack.clear();
      }
      widget.ideController.updateEditorContent(text);
    }
    setState(() {});
  }

  void _handleUndo() {
    if (_undoStack.length > 1) {
      _isPerformingUndoRedo = true;
      final current = _undoStack.removeLast();
      _redoStack.add(current);
      final previous = _undoStack.last;
      _textController.text = previous;
      widget.ideController.updateEditorContent(previous);
      _isPerformingUndoRedo = false;
      setState(() {});
    }
  }

  void _handleRedo() {
    if (_redoStack.isNotEmpty) {
      _isPerformingUndoRedo = true;
      final next = _redoStack.removeLast();
      _undoStack.add(next);
      _textController.text = next;
      widget.ideController.updateEditorContent(next);
      _isPerformingUndoRedo = false;
      setState(() {});
    }
  }

  void _handleInsert(String insertText, {int cursorOffset = 0}) {
    final selection = _textController.selection;
    final text = _textController.text;

    int start = selection.start >= 0 ? selection.start : text.length;
    int end = selection.end >= 0 ? selection.end : text.length;

    final newText = text.replaceRange(start, end, insertText);
    _textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + cursorOffset),
    );
  }

  void _handleTab() {
    _handleInsert('    ', cursorOffset: 4);
  }

  void _handleFind(String query, {bool matchCase = false, bool isRegex = false}) {
    // Basic search trigger
  }

  void _handleReplaceAll(String query, String replacement) {
    if (query.isEmpty) return;
    final newText = _textController.text.replaceAll(query, replacement);
    _textController.text = newText;
    widget.ideController.updateEditorContent(newText);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _verticalScrollController.removeListener(_syncScroll);
    _textController.dispose();
    _verticalScrollController.dispose();
    _gutterScrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.ideController.syntaxTheme;
    final lines = _textController.text.split('\n');
    final totalLines = lines.isEmpty ? 1 : lines.length;

    return Container(
      color: theme.background,
      child: Column(
        children: [
          // Find & Replace Banner
          if (widget.ideController.isFindReplaceOpen)
            FindReplaceBar(
              onFind: _handleFind,
              onReplaceAll: _handleReplaceAll,
              onClose: () => widget.ideController.toggleFindReplace(),
            ),

          // Code Editor with Line Gutter
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Line Numbers Gutter
                if (widget.ideController.showLineNumbers)
                  Container(
                    width: 44,
                    color: theme.gutterBackground,
                    child: SingleChildScrollView(
                      controller: _gutterScrollController,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        children: List.generate(totalLines, (index) {
                          final lineNum = index + 1;
                          final isCurrent = lineNum == _currentLineNumber;
                          return Container(
                            height: widget.ideController.fontSize * 1.45,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 8),
                            color: isCurrent
                                ? theme.currentLine.withValues(alpha: 0.5)
                                : Colors.transparent,
                            child: Text(
                              '$lineNum',
                              style: AppTheme.codeStyle(
                                fontSize: widget.ideController.fontSize - 1,
                                color: isCurrent ? AppColors.textPrimary : theme.gutterText,
                                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),

                // Editor Text Field Area
                Expanded(
                  child: SingleChildScrollView(
                    controller: _verticalScrollController,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    child: KeyboardListener(
                      focusNode: FocusNode(),
                      onKeyEvent: (event) {
                        if (event is KeyDownEvent) {
                          if (event.logicalKey == LogicalKeyboardKey.tab) {
                            _handleTab();
                          }
                        }
                      },
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        autocorrect: false,
                        enableSuggestions: false,
                        style: AppTheme.codeStyle(
                          fontSize: widget.ideController.fontSize,
                          color: AppColors.textPrimary,
                        ),
                        cursorColor: AppColors.editorCursor,
                        cursorWidth: 2,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Quick Keys Toolbar for Mobile Coding
          EditorQuickKeys(
            onInsertText: _handleInsert,
            onTab: _handleTab,
            onUndo: _handleUndo,
            onRedo: _handleRedo,
            onSave: () async {
              final messenger = ScaffoldMessenger.of(context);
              await widget.ideController.saveActiveFile();
              if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('File saved to workspace!'),
                    duration: Duration(milliseconds: 1200),
                  ),
                );
              }
            },
          ),

          // Editor Status Bar (Line/Col, Save state, Encoding)
          Container(
            height: 24,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: AppColors.surface,
            child: Row(
              children: [
                _buildSyncIndicator(widget.activeTab.syncState),
                const SizedBox(width: 8),
                Text(
                  widget.activeTab.title,
                  style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                ),
                const Spacer(),
                Text(
                  'Ln $_currentLineNumber, Col $_currentColumnNumber',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10.5,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'UTF-8',
                  style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Python 3.12',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentCyan,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncIndicator(SyncState state) {
    Color dotColor;
    String label;

    switch (state) {
      case SyncState.clean:
        dotColor = AppColors.statusSuccess;
        label = 'Saved';
        break;
      case SyncState.dirtyLocal:
        dotColor = AppColors.statusQueued;
        label = 'Editing';
        break;
      case SyncState.saving:
        dotColor = AppColors.statusRunning;
        label = 'Saving...';
        break;
      case SyncState.conflict:
        dotColor = AppColors.accentAmber;
        label = 'Conflict';
        break;
      case SyncState.saveFailed:
        dotColor = AppColors.statusFailed;
        label = 'Save Error';
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(fontSize: 10.5, color: dotColor, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
