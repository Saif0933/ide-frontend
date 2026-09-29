import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/theme/syntax_theme.dart';
import 'package:frontend/core/utils/responsive.dart';
import 'package:frontend/features/projects/models/project_model.dart';
import 'package:frontend/features/chat/presentation/screens/developer_chat_screen.dart';
import 'package:frontend/features/ide/controllers/ide_controller.dart';
import '../widgets/editor/code_editor_view.dart';
import '../widgets/explorer/project_explorer_drawer.dart';
import '../widgets/tabs/editor_tab_header.dart';
import '../widgets/terminal/terminal_panel.dart';
import '../widgets/problems/problems_panel.dart';
import '../widgets/explorer/file_creation_dialog.dart';

class IdeWorkspaceScreen extends StatefulWidget {
  final ProjectModel project;

  const IdeWorkspaceScreen({
    super.key,
    required this.project,
  });

  @override
  State<IdeWorkspaceScreen> createState() => _IdeWorkspaceScreenState();
}

class _IdeWorkspaceScreenState extends State<IdeWorkspaceScreen> {
  late IdeController _ideController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSidebarVisible = true;

  @override
  void initState() {
    super.initState();
    _ideController = IdeController(project: widget.project);
  }

  @override
  void dispose() {
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
          initialContext: withErrorContext ? _ideController.buildErrorContext() : null,
        ),
      ),
    );
  }

  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Device Storage & Workspace Actions',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  // Save Active File to Device
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.statusSuccess.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.download_rounded, size: 18, color: AppColors.statusSuccess),
                    ),
                    title: const Text('Save Active File to Device', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                    subtitle: const Text('Save currently opened Python file to Phone or Desktop storage', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    onTap: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      Navigator.pop(ctx);
                      final ok = await _ideController.saveActiveFileToDevice();
                      if (ok && mounted) {
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Active file saved to device storage successfully!')),
                        );
                      }
                    },
                  ),
                  // Export Entire Project to Device
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accentPurple.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.folder_zip_rounded, size: 18, color: AppColors.accentPurple),
                    ),
                    title: const Text('Export Entire Project to Device', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                    subtitle: const Text('Export all project files & folders to Phone or Desktop storage', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    onTap: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      Navigator.pop(ctx);
                      final ok = await _ideController.exportEntireProjectToDevice();
                      if (ok && mounted) {
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Project files exported to device storage successfully!')),
                        );
                      }
                    },
                  ),
                  // Open File from Device
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accentCyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.file_open_rounded, size: 18, color: AppColors.accentCyan),
                    ),
                    title: const Text('Open File from Device', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                    subtitle: const Text('Pick from Mobile File Manager or Desktop Explorer', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    onTap: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      Navigator.pop(ctx);
                      final ok = await _ideController.importExternalFiles();
                      if (ok && mounted) {
                        messenger.showSnackBar(
                          const SnackBar(content: Text('File imported and opened in editor!')),
                        );
                      }
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accentAmber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.drive_folder_upload_rounded, size: 18, color: AppColors.accentAmber),
                    ),
                    title: const Text('Open Folder from Device', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                    subtitle: const Text('Import directory tree from Mobile or Desktop', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    onTap: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      Navigator.pop(ctx);
                      final ok = await _ideController.importExternalFolder();
                      if (ok && mounted) {
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Folder imported into workspace!')),
                        );
                      }
                    },
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Editor Font Size'),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, size: 20),
                            onPressed: () {
                              _ideController.setFontSize(_ideController.fontSize - 1);
                              setModalState(() {});
                            },
                          ),
                          Text('${_ideController.fontSize.toInt()} pt', style: const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, size: 20),
                            onPressed: () {
                              _ideController.setFontSize(_ideController.fontSize + 1);
                              setModalState(() {});
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  const Text('Syntax Color Theme', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: SyntaxThemePreset.values.map((preset) {
                      final isSelected = _ideController.syntaxPreset == preset;
                      return ChoiceChip(
                        label: Text(preset.name),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surfaceLight,
                        onSelected: (selected) {
                          if (selected) {
                            _ideController.setSyntaxPreset(preset);
                            setModalState(() {});
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const Divider(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.memory_rounded, size: 16, color: AppColors.accentCyan),
                      const SizedBox(width: 8),
                      const Text('Sandbox Limits: Python 3.12 • 128MB • 15s Timeout', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final isMobile = Responsive.isMobile(context);

    return AnimatedBuilder(
      animation: _ideController,
      builder: (context, _) {
        final isExecuting = _ideController.isExecuting;
        final hasDiagnostics = _ideController.diagnostics.isNotEmpty;

        Widget mainWorkspace = Column(
          children: [
            // Tabs Header
            EditorTabHeader(ideController: _ideController),

            // Main Code Editor Area
            Expanded(
              child: _ideController.activeTab == null
                  ? Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.surfaceBorder),
                              ),
                              child: const Icon(Icons.code_rounded, size: 40, color: AppColors.primaryLight),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No File Open in Editor',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Select a file to edit or open files and folders directly from your device file manager.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 20),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              alignment: WrapAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => FileCreationDialog.show(context, _ideController, isFolder: false),
                                  icon: const Icon(Icons.note_add_rounded, size: 16),
                                  label: const Text('New File'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () => FileCreationDialog.show(context, _ideController, isFolder: true),
                                  icon: const Icon(Icons.create_new_folder_outlined, size: 16, color: AppColors.accentAmber),
                                  label: const Text('New Folder', style: TextStyle(color: AppColors.textPrimary)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.surfaceBorder),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () async {
                                    final messenger = ScaffoldMessenger.of(context);
                                    final ok = await _ideController.importExternalFiles();
                                    if (ok && mounted) {
                                      messenger.showSnackBar(
                                        const SnackBar(content: Text('File imported and opened in editor!')),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.file_open_rounded, size: 16, color: AppColors.accentCyan),
                                  label: const Text('Open File from Device', style: TextStyle(color: AppColors.textPrimary)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.surfaceBorder),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                                if (isMobile)
                                  TextButton.icon(
                                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                                    icon: const Icon(Icons.folder_open_rounded, size: 16, color: AppColors.accentCyan),
                                    label: const Text('Project Explorer', style: TextStyle(color: AppColors.accentCyan)),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : CodeEditorView(
                      ideController: _ideController,
                      activeTab: _ideController.activeTab!,
                    ),
            ),

            // Problems Panel (collapsible)
            if (_ideController.isProblemsOpen)
              SizedBox(
                height: 160,
                child: ProblemsPanel(ideController: _ideController),
              ),

            // Terminal Panel (collapsible)
            if (_ideController.isTerminalOpen)
              SizedBox(
                height: isDesktop ? 240 : 200,
                child: TerminalPanel(
                  ideController: _ideController,
                  onAskDeveloper: () => _openDeveloperChat(withErrorContext: true),
                ),
              ),
          ],
        );

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.background,
          drawer: isMobile
              ? Drawer(
                  child: ProjectExplorerDrawer(ideController: _ideController),
                )
              : null,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36),
              onPressed: () => Navigator.of(context).pop(),
            ),
            titleSpacing: 0,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isMobile)
                  IconButton(
                    icon: const Icon(Icons.menu_rounded, size: 20, color: AppColors.textPrimary),
                    tooltip: 'Project Explorer',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  )
                else
                  IconButton(
                    icon: Icon(_isSidebarVisible ? Icons.view_sidebar_rounded : Icons.view_sidebar_outlined, size: 20, color: _isSidebarVisible ? AppColors.primaryLight : AppColors.textMuted),
                    tooltip: _isSidebarVisible ? 'Hide Sidebar' : 'Show Sidebar',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32),
                    onPressed: () => setState(() => _isSidebarVisible = !_isSidebarVisible),
                  ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _ideController.project.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: AppColors.accentCyan,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Python 3.12 Sandboxed',
                            style: TextStyle(fontSize: 9.5, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              // Search toggle
              IconButton(
                icon: Icon(
                  Icons.search_rounded,
                  size: 19,
                  color: _ideController.isFindReplaceOpen ? AppColors.primaryLight : AppColors.textSecondary,
                ),
                tooltip: 'Find & Replace',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 30),
                onPressed: _ideController.toggleFindReplace,
              ),

              // Problems Badge Button
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.bug_report_outlined,
                      size: 19,
                      color: hasDiagnostics ? AppColors.accentRed : AppColors.textSecondary,
                    ),
                    tooltip: 'Problems & Diagnostics',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 30),
                    onPressed: _ideController.toggleProblems,
                  ),
                  if (hasDiagnostics)
                    Positioned(
                      top: 6,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: const BoxDecoration(
                          color: AppColors.accentRed,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${_ideController.diagnostics.length}',
                          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),

              // Save to Device Button
              IconButton(
                icon: const Icon(Icons.download_rounded, size: 19, color: AppColors.statusSuccess),
                tooltip: 'Save File to Phone/Desktop',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 30),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final ok = await _ideController.saveActiveFileToDevice();
                  if (ok && mounted) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('File saved to device storage successfully!')),
                    );
                  }
                },
              ),

              // Developer Chat Button
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 19, color: AppColors.accentPurple),
                tooltip: 'Developer Collaboration Chat',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 30),
                onPressed: () => _openDeveloperChat(withErrorContext: false),
              ),

              // Run / Stop Action CTA Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                child: SizedBox(
                  height: 30,
                  child: ElevatedButton.icon(
                    onPressed: isExecuting ? _ideController.stopExecution : _ideController.runCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isExecuting ? AppColors.accentRed : AppColors.accent,
                      foregroundColor: Colors.white,
                      elevation: 1,
                      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 12 : 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    icon: Icon(
                      isExecuting ? Icons.stop_rounded : Icons.play_arrow_rounded,
                      size: 14,
                    ),
                    label: Text(
                      isExecuting ? 'Stop' : 'Run',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

              // More Settings Menu
              IconButton(
                icon: const Icon(Icons.more_vert_rounded, size: 19, color: AppColors.textSecondary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28),
                onPressed: _showSettingsModal,
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: !isMobile
              ? Row(
                  children: [
                    if (_isSidebarVisible)
                      ProjectExplorerDrawer(ideController: _ideController),
                    Expanded(child: mainWorkspace),
                  ],
                )
              : mainWorkspace,
          bottomNavigationBar: !_ideController.isTerminalOpen
              ? Container(
                  height: 36,
                  color: AppColors.surface,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: _ideController.toggleTerminal,
                        child: const Row(
                          children: [
                            Icon(Icons.terminal_rounded, size: 15, color: AppColors.accentCyan),
                            SizedBox(width: 6),
                            Text(
                              'Show Terminal',
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: _ideController.toggleProblems,
                        child: Row(
                          children: [
                            Icon(
                              Icons.bug_report_rounded,
                              size: 15,
                              color: hasDiagnostics ? AppColors.accentRed : AppColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_ideController.diagnostics.length} Problems',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: hasDiagnostics ? AppColors.accentRed : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : null,
        );
      },
    );
  }
}
