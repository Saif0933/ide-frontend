import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/projects/models/project_model.dart';
import 'package:frontend/features/chat/presentation/screens/developer_chat_screen.dart';
import 'package:frontend/features/ide/controllers/ide_controller.dart';
import 'package:frontend/features/ide/models/editor_tab_model.dart';
import 'package:frontend/features/execution/models/execution_log.dart';
import '../widgets/explorer/project_explorer_drawer.dart';
import '../widgets/explorer/file_creation_dialog.dart';
import '../widgets/editor/custom_python_highlighter.dart';

enum ConsoleTabType { terminal, output, errors, askAi }

class IdeWorkspaceScreen extends StatefulWidget {
  final ProjectModel project;

  const IdeWorkspaceScreen({super.key, required this.project});

  @override
  State<IdeWorkspaceScreen> createState() => _IdeWorkspaceScreenState();
}

class _IdeWorkspaceScreenState extends State<IdeWorkspaceScreen> {
  late IdeController _ideController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey _threeLinesMenuKey = GlobalKey();
  final GlobalKey _moreVertKey = GlobalKey();
  final ScrollController _mainScrollController = ScrollController();
  final ScrollController _terminalScrollController = ScrollController();
  final ScrollController _codeVerticalScrollController = ScrollController();
  final ScrollController _codeHorizontalScrollController = ScrollController();
  final ScrollController _gutterScrollController = ScrollController();

  // Active Console Tab
  ConsoleTabType _activeConsoleTab = ConsoleTabType.terminal;

  // Code Editor Controller
  late PythonSyntaxHighlighter _codeTextController;
  bool _isTerminalExpanded = false;
  bool _isDarkMode = true;

  static const String _defaultBubbleSortCode = '''#!/usr/bin/env python3
"""
Algorithm Sandbox: Quick Sort & Binary Search
Note: Demonstrates execution error detection
and Ask Developer workflow.
"""

def bubble_sort(arr):
    n = len(arr)
    for i in range(n):
        for j in range(0, n - i - 1):
            if arr[j] > arr[j + 1]:
                arr[j], arr[j + 1] = arr[j + 1], arr[j]
    return arr

if __name__ == "__main__":
    data = [64, 34, 25, 12, 22, 11, 90]
    print("Original:", data)
    print("Sorted:", bubble_sort(data))
''';

  String? _currentActiveTabId;

  @override
  void initState() {
    super.initState();
    _ideController = IdeController(project: widget.project);

    final initialCode = _ideController.activeTab?.currentContent ?? _defaultBubbleSortCode;
    _currentActiveTabId = _ideController.activeTab?.id;

    _codeTextController = PythonSyntaxHighlighter(
      text: initialCode,
      syntaxTheme: _ideController.syntaxTheme,
      fontSize: 12.5,
    );

    _codeTextController.addListener(() {
      final activeTab = _ideController.activeTab;
      if (activeTab != null && activeTab.currentContent != _codeTextController.text) {
        _ideController.updateEditorContent(_codeTextController.text);
      }
      if (mounted) setState(() {});
    });

    _ideController.addListener(_onIdeControllerChange);

    _codeVerticalScrollController.addListener(() {
      if (_gutterScrollController.hasClients && _codeVerticalScrollController.hasClients) {
        if (_gutterScrollController.offset != _codeVerticalScrollController.offset) {
          _gutterScrollController.jumpTo(_codeVerticalScrollController.offset);
        }
      }
    });

    // Seed realistic initial terminal output if empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_ideController.terminalLogs.isEmpty) {
        _populateDefaultTerminalLogs();
      }
    });
  }

  void _onIdeControllerChange() {
    final activeTab = _ideController.activeTab;
    if (activeTab != null) {
      if (activeTab.id != _currentActiveTabId) {
        _currentActiveTabId = activeTab.id;
        _codeTextController.text = activeTab.currentContent;
        if (mounted) setState(() {});
      }
    } else {
      if (_currentActiveTabId != null) {
        _currentActiveTabId = null;
        _codeTextController.text = '';
        if (mounted) setState(() {});
      }
    }
  }

  void _populateDefaultTerminalLogs() {
    _ideController.clearTerminal();
  }

  @override
  void dispose() {
    _ideController.removeListener(_onIdeControllerChange);
    _mainScrollController.dispose();
    _terminalScrollController.dispose();
    _codeVerticalScrollController.dispose();
    _codeHorizontalScrollController.dispose();
    _gutterScrollController.dispose();
    _codeTextController.dispose();
    _ideController.dispose();
    super.dispose();
  }

  void _openDeveloperChat({bool withErrorContext = false}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => DeveloperChatScreen(
          projectId: widget.project.id,
          projectName: widget.project.name,
          ideController: _ideController,
          initialContext: withErrorContext
              ? _ideController.buildErrorContext()
              : null,
        ),
      ),
    );
  }

  void _showAnchoredSettingsPopup(GlobalKey? anchorKey) {
    RenderBox? renderBox;
    if (anchorKey?.currentContext != null) {
      renderBox = anchorKey!.currentContext!.findRenderObject() as RenderBox?;
    }

    final Offset offset = renderBox?.localToGlobal(Offset.zero) ?? const Offset(12, 56);
    final Size size = renderBox?.size ?? const Size(40, 40);
    final screenSize = MediaQuery.of(context).size;
    final topPosition = (offset.dy + size.height + 4).clamp(44.0, screenSize.height - 220);
    final isLeftAligned = offset.dx < screenSize.width / 2;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Workspace & Storage',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (dialogCtx, anim1, anim2) {
        return Theme(
          data: AppTheme.darkTheme,
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Material(
                color: Colors.transparent,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(dialogCtx),
                        behavior: HitTestBehavior.translucent,
                        child: Container(color: Colors.transparent),
                      ),
                    ),
                    Positioned(
                      top: topPosition,
                      left: isLeftAligned ? 12 : null,
                      right: isLeftAligned ? null : 12,
                      width: (screenSize.width - 24).clamp(310.0, 395.0),
                      child: Container(
                        constraints: BoxConstraints(
                          maxHeight: screenSize.height - topPosition - 20,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D1322),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF2A374A), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.65),
                              blurRadius: 32,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: const BoxDecoration(
                                color: Color(0xFF141D30),
                                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                                border: Border(bottom: BorderSide(color: Color(0xFF243044), width: 1)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.tune_rounded, size: 16, color: Colors.white),
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text(
                                      'Workspace & Storage',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    style: IconButton.styleFrom(
                                      backgroundColor: const Color(0xFF1E293B),
                                      padding: const EdgeInsets.all(4),
                                      minimumSize: const Size(26, 26),
                                    ),
                                    icon: const Icon(Icons.close_rounded, size: 14, color: Color(0xFF94A3B8)),
                                    onPressed: () => Navigator.pop(dialogCtx),
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    _buildStorageTile(
                                      icon: Icons.download_rounded,
                                      iconBg: const Color(0xFF10B981).withValues(alpha: 0.15),
                                      iconColor: const Color(0xFF34D399),
                                      title: 'Save Active File to Device',
                                      subtitle: 'Download ${_ideController.activeTab?.title ?? "main.py"}',
                                      onTap: () async {
                                        final messenger = ScaffoldMessenger.of(context);
                                        Navigator.pop(dialogCtx);
                                        final ok = await _ideController.saveActiveFileToDevice();
                                        if (ok && mounted) {
                                          messenger.showSnackBar(
                                            const SnackBar(content: Text('File saved to device storage!'), behavior: SnackBarBehavior.floating),
                                          );
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 6),
                                    _buildStorageTile(
                                      icon: Icons.folder_zip_rounded,
                                      iconBg: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                                      iconColor: const Color(0xFFA78BFA),
                                      title: 'Export Entire Project',
                                      subtitle: 'Bundle all files to device storage',
                                      onTap: () async {
                                        final messenger = ScaffoldMessenger.of(context);
                                        Navigator.pop(dialogCtx);
                                        final ok = await _ideController.exportEntireProjectToDevice();
                                        if (ok && mounted) {
                                          messenger.showSnackBar(
                                            const SnackBar(content: Text('Project exported successfully!'), behavior: SnackBarBehavior.floating),
                                          );
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 6),
                                    _buildStorageTile(
                                      icon: Icons.file_open_rounded,
                                      iconBg: const Color(0xFF06B6D4).withValues(alpha: 0.15),
                                      iconColor: const Color(0xFF22D3EE),
                                      title: 'Open File from Device',
                                      subtitle: 'Import script from phone file manager',
                                      onTap: () async {
                                        final messenger = ScaffoldMessenger.of(context);
                                        Navigator.pop(dialogCtx);
                                        final ok = await _ideController.importExternalFiles();
                                        if (ok && mounted) {
                                          messenger.showSnackBar(
                                            const SnackBar(content: Text('File opened in editor!'), behavior: SnackBarBehavior.floating),
                                          );
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 6),
                                    _buildStorageTile(
                                      icon: Icons.drive_folder_upload_rounded,
                                      iconBg: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                                      iconColor: const Color(0xFFFBBF24),
                                      title: 'Open Folder from Device',
                                      subtitle: 'Import directory tree from device',
                                      onTap: () async {
                                        final messenger = ScaffoldMessenger.of(context);
                                        Navigator.pop(dialogCtx);
                                        final ok = await _ideController.importExternalFolder();
                                        if (ok && mounted) {
                                          messenger.showSnackBar(
                                            const SnackBar(content: Text('Folder imported into workspace!'), behavior: SnackBarBehavior.floating),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStorageTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF161F30),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF243044), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(subtitle, style: const TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8))),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: Color(0xFF64748B)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: AnimatedBuilder(
        animation: _ideController,
        builder: (context, _) {
          final isExecuting = _ideController.isExecuting;
          final activeTabTitle = _ideController.activeTab?.title ?? 'main.py';

          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: const Color(0xFF070B14),
            drawer: Drawer(
              child: ProjectExplorerDrawer(ideController: _ideController),
            ),
            // TOP APP BAR
            appBar: AppBar(
              backgroundColor: const Color(0xFF070B14),
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              centerTitle: false,
              titleSpacing: 0,
              leading: IconButton(
                key: _threeLinesMenuKey,
                icon: const Icon(
                  Icons.menu_rounded,
                  size: 24,
                  color: Colors.white,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 44),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Official Python Snakes Logo Widget
                  const _PythonLogoWidget(size: 26),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          activeTabTitle,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.project.name,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF8E9CAE),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                // Dark / Light Mode Toggle Icon
                IconButton(
                  icon: Icon(
                    _isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_round,
                    size: 20,
                    color: const Color(0xFFCBD5E1),
                  ),
                  tooltip: _isDarkMode ? 'Light Mode' : 'Dark Mode',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36),
                  onPressed: () {
                    setState(() {
                      _isDarkMode = !_isDarkMode;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_isDarkMode ? 'Dark theme active' : 'Light theme active'),
                        duration: const Duration(milliseconds: 1000),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                // 3-dots More Options (Opens Storage & Workspace Popup)
                IconButton(
                  key: _moreVertKey,
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    size: 20,
                    color: Color(0xFFCBD5E1),
                  ),
                  tooltip: 'More actions',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36),
                  onPressed: () => _showAnchoredSettingsPopup(_moreVertKey),
                ),
                const SizedBox(width: 4),
              ],
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                controller: _mainScrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. TABS & RUN BAR ROW
                    _buildTabsAndActionBar(isExecuting, activeTabTitle),
                    const SizedBox(height: 12),

                    // 2. PYTHON CODE EDITOR WINDOW
                    _buildCodeEditorCard(),
                    const SizedBox(height: 14),

                    // 3. CONSOLE PANEL TABS (Terminal, Output, Errors, Ask AI)
                    _buildConsolePanelTabs(),
                    const SizedBox(height: 8),

                    // 4. TERMINAL / OUTPUT CONSOLE BOX
                    _buildConsoleOutputBox(isExecuting),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // 1. TABS & RUN ACTION BAR
  // ==========================================
  // 1. TABS & RUN BAR ROW
  // ==========================================
  Widget _buildTabsAndActionBar(bool isExecuting, String activeTabTitle) {
    return Row(
      children: [
        // Open Tabs list with horizontal scroll
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                if (_ideController.openTabs.isEmpty) ...[
                  _buildTabItem(
                    0,
                    EditorTabModel(
                      id: 'default',
                      fileId: 'default',
                      title: activeTabTitle,
                      path: activeTabTitle,
                      initialContent: '',
                      currentContent: '',
                    ),
                    true,
                  ),
                  const SizedBox(width: 6),
                ] else ...[
                  for (int i = 0; i < _ideController.openTabs.length; i++) ...[
                    _buildTabItem(i, _ideController.openTabs[i], i == _ideController.activeTabIndex),
                    const SizedBox(width: 6),
                  ],
                ],
                // Plus Button (Add new blank file)
                InkWell(
                  onTap: () => FileCreationDialog.show(context, _ideController, isFolder: false),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF1E293B)),
                    ),
                    child: const Icon(Icons.add_rounded, size: 20, color: Color(0xFFCBD5E1)),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Save File Button
        InkWell(
          onTap: () async {
            final messenger = ScaffoldMessenger.of(context);
            await _ideController.saveActiveFile();
            messenger.showSnackBar(
              const SnackBar(content: Text('File saved!'), duration: Duration(milliseconds: 1000), behavior: SnackBarBehavior.floating),
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: const Icon(Icons.save_outlined, size: 18, color: Color(0xFF38BDF8)),
          ),
        ),
        const SizedBox(width: 8),

        // Folder Button
        InkWell(
          onTap: () => _scaffoldKey.currentState?.openDrawer(),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: const Icon(Icons.folder_outlined, size: 18, color: Color(0xFF94A3B8)),
          ),
        ),
        const SizedBox(width: 10),

        // VIBRANT GREEN "▶ Run" BUTTON
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isExecuting ? _ideController.stopExecution : _ideController.runCode,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isExecuting ? const Color(0xFFEF4444) : const Color(0xFF00C853),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: (isExecuting ? const Color(0xFFEF4444) : const Color(0xFF00C853)).withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isExecuting ? Icons.stop_rounded : Icons.play_arrow_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isExecuting ? 'Stop' : 'Run',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabItem(int index, EditorTabModel tab, bool isActive) {
    return InkWell(
      onTap: () => _ideController.switchTab(index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF13233A) : const Color(0xFF0D1524),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? const Color(0xFF1E3A5F) : const Color(0xFF162235),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _PythonLogoWidget(size: 16),
            const SizedBox(width: 8),
            Text(
              tab.title,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? Colors.white : const Color(0xFF8E9CAE),
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: () {
                _ideController.closeTab(index);
              },
              child: const Icon(
                Icons.close_rounded,
                size: 14,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 2. CODE EDITOR WINDOW (SCROLLABLE)
  // ==========================================
  Widget _buildCodeEditorCard() {
    final lines = _codeTextController.text.split('\n');
    final lineCount = lines.isEmpty ? 1 : lines.length;

    return Container(
      height: 310,
      decoration: BoxDecoration(
        color: const Color(0xFF0C1322),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1A273F), width: 1.2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Line Numbers Gutter (Synchronized Vertical Scroll)
            Container(
              width: 36,
              color: const Color(0xFF090E1A),
              child: SingleChildScrollView(
                controller: _gutterScrollController,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: List.generate(lineCount, (index) {
                    return SizedBox(
                      height: 19.5,
                      child: Text(
                        '${index + 1}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11.5,
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            // Vertical Divider
            Container(width: 1, color: const Color(0xFF1A273F)),

            // Code Text Area (Scrollable Vertically and Horizontally)
            Expanded(
              child: Scrollbar(
                controller: _codeVerticalScrollController,
                thumbVisibility: false,
                child: SingleChildScrollView(
                  controller: _codeVerticalScrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: SingleChildScrollView(
                    controller: _codeHorizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: IntrinsicWidth(
                      child: TextField(
                        controller: _codeTextController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12.5,
                          height: 1.56,
                          color: Colors.white,
                        ),
                        cursorColor: const Color(0xFF38BDF8),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 3. CONSOLE PANEL TABS
  // ==========================================
  Widget _buildConsolePanelTabs() {
    return Row(
      children: [
        _buildPanelTabItem(
          tab: ConsoleTabType.terminal,
          icon: Icons.terminal_rounded,
          iconBg: const Color(0xFF00E5FF),
          label: 'Terminal',
        ),
        const SizedBox(width: 6),
        _buildPanelTabItem(
          tab: ConsoleTabType.output,
          icon: Icons.play_arrow_rounded,
          iconBg: const Color(0xFF10B981),
          label: 'Output',
        ),
        const SizedBox(width: 6),
        _buildPanelTabItem(
          tab: ConsoleTabType.errors,
          icon: Icons.warning_amber_rounded,
          iconBg: const Color(0xFFEF4444),
          label: 'Errors',
        ),
        const SizedBox(width: 6),
        _buildPanelTabItem(
          tab: ConsoleTabType.askAi,
          icon: Icons.smart_toy_rounded,
          iconBg: const Color(0xFFA855F7),
          label: 'Ask AI',
        ),
        const Spacer(),
        // Panel toggle icon
        IconButton(
          icon: Icon(
            _isTerminalExpanded ? Icons.splitscreen_rounded : Icons.crop_square_rounded,
            size: 18,
            color: const Color(0xFF8E9CAE),
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 28),
          onPressed: () {
            setState(() => _isTerminalExpanded = !_isTerminalExpanded);
          },
        ),
      ],
    );
  }

  Widget _buildPanelTabItem({
    required ConsoleTabType tab,
    required IconData icon,
    required Color iconBg,
    required String label,
  }) {
    final isSelected = _activeConsoleTab == tab;

    return InkWell(
      onTap: () {
        setState(() => _activeConsoleTab = tab);
        if (tab == ConsoleTabType.askAi) {
          _openDeveloperChat(withErrorContext: false);
        }
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF00E5FF) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(icon, size: 11, color: Colors.black),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF8E9CAE),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 4. TERMINAL CONSOLE OUTPUT BOX
  // ==========================================
  Widget _buildConsoleOutputBox(bool isExecuting) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 140,
        maxHeight: _isTerminalExpanded ? 340 : 200,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF060B14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1B273E), width: 1.2),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Console Header Row
          Row(
            children: [
              const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF00E676),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Python 3.12.0',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: _ideController.clearTerminal,
                child: const Icon(
                  Icons.delete_outline_rounded,
                  size: 16,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () {
                  setState(() => _isTerminalExpanded = !_isTerminalExpanded);
                },
                child: const Icon(
                  Icons.open_in_full_rounded,
                  size: 14,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Output Lines
          Expanded(
            child: _ideController.terminalLogs.isEmpty
                ? _buildDefaultConsoleLogs()
                : ListView.builder(
                    controller: _terminalScrollController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _ideController.terminalLogs.length,
                    itemBuilder: (context, index) {
                      final log = _ideController.terminalLogs[index];
                      return _buildLogLineItem(log);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultConsoleLogs() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '[sandbox] Initializing Python 3.12 isolated\nrunner (Memory limit: 128MB, Timeout: 15s) ...',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 11.5,
            color: Color(0xFF38BDF8),
            height: 1.4,
          ),
        ),
        SizedBox(height: 4),
        Text.rich(
          TextSpan(
            text: 'Running: ',
            style: TextStyle(fontFamily: 'monospace', fontSize: 11.5, color: Colors.white),
            children: [
              TextSpan(
                text: 'python3 main.py',
                style: TextStyle(fontFamily: 'monospace', fontSize: 11.5, color: Color(0xFFFBBF24)),
              ),
            ],
          ),
        ),
        SizedBox(height: 3),
        Text(
          'Original: [64, 34, 25, 12, 22, 11, 90]',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 11.5,
            color: Color(0xFFE2E8F0),
          ),
        ),
        SizedBox(height: 3),
        Text(
          'Sorted: [11, 12, 22, 25, 34, 64, 90]',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 11.5,
            color: Color(0xFFE2E8F0),
          ),
        ),
        SizedBox(height: 3),
        Text(
          'Process finished with exit code 0',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 11.5,
            color: Color(0xFF00E676),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLogLineItem(ExecutionLog log) {
    Color textColor = const Color(0xFFE2E8F0);
    if (log.stream == LogStreamType.stderr) {
      textColor = const Color(0xFFF87171);
    } else if (log.stream == LogStreamType.system) {
      textColor = const Color(0xFF38BDF8);
    }

    if (log.content.contains('exit code 0')) {
      textColor = const Color(0xFF00E676);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: SelectableText(
        log.content,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 11.5,
          color: textColor,
          height: 1.35,
        ),
      ),
    );
  }

  // ==========================================
}

// ==========================================
// OFFICIAL PYTHON INTERTWINED LOGO WIDGET
// ==========================================
class _PythonLogoWidget extends StatelessWidget {
  final double size;

  const _PythonLogoWidget({this.size = 24});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PythonLogoPainter(),
      ),
    );
  }
}

class _PythonLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Blue Snake (Top Left)
    final bluePaint = Paint()
      ..color = const Color(0xFF387EB8)
      ..style = PaintingStyle.fill;

    final yellowPaint = Paint()
      ..color = const Color(0xFFFFE052)
      ..style = PaintingStyle.fill;

    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw Blue Top Segment
    final bluePath = Path();
    bluePath.moveTo(w * 0.48, h * 0.05);
    bluePath.lineTo(w * 0.28, h * 0.05);
    bluePath.arcToPoint(Offset(w * 0.08, h * 0.25), radius: Radius.circular(w * 0.2));
    bluePath.lineTo(w * 0.08, h * 0.42);
    bluePath.lineTo(w * 0.25, h * 0.42);
    bluePath.lineTo(w * 0.25, h * 0.52);
    bluePath.lineTo(w * 0.52, h * 0.52);
    bluePath.lineTo(w * 0.52, h * 0.32);
    bluePath.lineTo(w * 0.28, h * 0.32);
    bluePath.lineTo(w * 0.28, h * 0.22);
    bluePath.lineTo(w * 0.65, h * 0.22);
    bluePath.arcToPoint(Offset(w * 0.48, h * 0.05), radius: Radius.circular(w * 0.17));
    bluePath.close();
    canvas.drawPath(bluePath, bluePaint);

    // Blue snake eye
    canvas.drawCircle(Offset(w * 0.22, h * 0.14), w * 0.045, eyePaint);

    // Draw Yellow Bottom Segment (Rotated symmetry)
    final yellowPath = Path();
    yellowPath.moveTo(w * 0.52, h * 0.95);
    yellowPath.lineTo(w * 0.72, h * 0.95);
    yellowPath.arcToPoint(Offset(w * 0.92, h * 0.75), radius: Radius.circular(w * 0.2));
    yellowPath.lineTo(w * 0.92, h * 0.58);
    yellowPath.lineTo(w * 0.75, h * 0.58);
    yellowPath.lineTo(w * 0.75, h * 0.48);
    yellowPath.lineTo(w * 0.48, h * 0.48);
    yellowPath.lineTo(w * 0.48, h * 0.68);
    yellowPath.lineTo(w * 0.72, h * 0.68);
    yellowPath.lineTo(w * 0.72, h * 0.78);
    yellowPath.lineTo(w * 0.35, h * 0.78);
    yellowPath.arcToPoint(Offset(w * 0.52, h * 0.95), radius: Radius.circular(w * 0.17));
    yellowPath.close();
    canvas.drawPath(yellowPath, yellowPaint);

    // Yellow snake eye
    canvas.drawCircle(Offset(w * 0.78, h * 0.86), w * 0.045, eyePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
