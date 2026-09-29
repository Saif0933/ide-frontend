import 'dart:async';
import 'package:flutter/material.dart';
import '../../projects/models/project_model.dart';
import '../models/file_node_model.dart';
import '../models/editor_tab_model.dart';
import '../models/diagnostic_issue.dart';
import '../../execution/models/execution_job.dart';
import '../../execution/models/execution_log.dart';
import '../../execution/models/run_config.dart';
import '../../chat/models/message_context.dart';
import '../../../core/network/mock_backend_service.dart';
import '../../../core/theme/syntax_theme.dart';
import '../services/file_import_service.dart';

class IdeController extends ChangeNotifier {
  final MockBackendService _backendService = MockBackendService();

  final ProjectModel project;

  // File tree
  List<FileNodeModel> _fileTree = [];
  bool _isLoadingTree = false;

  // Tabs & Active File
  final List<EditorTabModel> _openTabs = [];
  int _activeTabIndex = 0;

  // Panels & Views
  bool _isExplorerOpen = false;
  bool _isTerminalOpen = true;
  bool _isProblemsOpen = false;
  bool _isFindReplaceOpen = false;
  bool _isChatOpen = false;

  // Editor Settings
  double _fontSize = 13.5;
  SyntaxThemePreset _syntaxPreset = SyntaxThemePreset.oneDark;
  final bool _wordWrap = false;
  final bool _showLineNumbers = true;

  // Diagnostics / Problems
  List<DiagnosticIssue> _diagnostics = [];

  // Execution & Logs
  ExecutionJob? _currentExecution;
  final List<ExecutionLog> _terminalLogs = [];
  bool _isExecuting = false;
  final RunConfig _runConfig;

  // Autosave Timer
  Timer? _autoSaveTimer;

  IdeController({required this.project})
      : _runConfig = RunConfig(entryFile: project.defaultFile) {
    _initWorkspace();
  }

  // Getters
  List<FileNodeModel> get fileTree => _fileTree;
  bool get isLoadingTree => _isLoadingTree;
  List<EditorTabModel> get openTabs => _openTabs;
  int get activeTabIndex => _activeTabIndex;
  EditorTabModel? get activeTab =>
      _openTabs.isNotEmpty && _activeTabIndex < _openTabs.length
          ? _openTabs[_activeTabIndex]
          : null;

  bool get isExplorerOpen => _isExplorerOpen;
  bool get isTerminalOpen => _isTerminalOpen;
  bool get isProblemsOpen => _isProblemsOpen;
  bool get isFindReplaceOpen => _isFindReplaceOpen;
  bool get isChatOpen => _isChatOpen;

  double get fontSize => _fontSize;
  SyntaxThemePreset get syntaxPreset => _syntaxPreset;
  SyntaxTheme get syntaxTheme => SyntaxTheme.getPreset(_syntaxPreset);
  bool get wordWrap => _wordWrap;
  bool get showLineNumbers => _showLineNumbers;

  List<DiagnosticIssue> get diagnostics => _diagnostics;
  ExecutionJob? get currentExecution => _currentExecution;
  List<ExecutionLog> get terminalLogs => _terminalLogs;
  bool get isExecuting => _isExecuting;
  RunConfig get runConfig => _runConfig;

  Future<void> _initWorkspace() async {
    _isLoadingTree = true;
    notifyListeners();

    try {
      _fileTree = await _backendService.getProjectTree(project.id);
      // Automatically open the default file (main.py)
      final defaultNode = _findFileByName(_fileTree, project.defaultFile) ??
          _findFirstFile(_fileTree);
      if (defaultNode != null) {
        openFile(defaultNode);
      }
    } catch (e) {
      debugPrint('Error loading workspace: $e');
    } finally {
      _isLoadingTree = false;
      notifyListeners();
    }
  }

  FileNodeModel? _findFileByName(List<FileNodeModel> nodes, String name) {
    for (final node in nodes) {
      if (!node.isFolder && node.name == name) return node;
      if (node.children.isNotEmpty) {
        final found = _findFileByName(node.children, name);
        if (found != null) return found;
      }
    }
    return null;
  }

  FileNodeModel? _findFirstFile(List<FileNodeModel> nodes) {
    for (final node in nodes) {
      if (!node.isFolder) return node;
      if (node.children.isNotEmpty) {
        final found = _findFirstFile(node.children);
        if (found != null) return found;
      }
    }
    return null;
  }

  // Tab Operations
  void openFile(FileNodeModel file) {
    if (file.isFolder) return;

    final existingIndex = _openTabs.indexWhere((tab) => tab.fileId == file.id);
    if (existingIndex != -1) {
      _activeTabIndex = existingIndex;
      notifyListeners();
      return;
    }

    final newTab = EditorTabModel(
      id: 'tab_${file.id}',
      fileId: file.id,
      title: file.name,
      path: file.path,
      initialContent: file.content,
      currentContent: file.content,
      syncState: SyncState.clean,
      version: file.version,
    );

    _openTabs.add(newTab);
    _activeTabIndex = _openTabs.length - 1;
    _analyzeDiagnostics(newTab.currentContent, newTab.fileId, newTab.path);
    notifyListeners();
  }

  void switchTab(int index) {
    if (index >= 0 && index < _openTabs.length) {
      _activeTabIndex = index;
      final current = _openTabs[index];
      _analyzeDiagnostics(current.currentContent, current.fileId, current.path);
      notifyListeners();
    }
  }

  void closeTab(int index) {
    if (index < 0 || index >= _openTabs.length) return;

    _openTabs.removeAt(index);
    if (_activeTabIndex >= _openTabs.length) {
      _activeTabIndex = _openTabs.isNotEmpty ? _openTabs.length - 1 : 0;
    }
    notifyListeners();
  }

  // Editor Content Changes & Autosave
  void updateEditorContent(String newContent) {
    final current = activeTab;
    if (current == null) return;

    _openTabs[_activeTabIndex] = current.copyWith(
      currentContent: newContent,
      syncState: SyncState.dirtyLocal,
    );
    notifyListeners();

    _analyzeDiagnostics(newContent, current.fileId, current.path);

    // Debounce autosave
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(milliseconds: 900), () {
      saveActiveFile();
    });
  }

  void updateCursorPosition(int line, int column) {
    final current = activeTab;
    if (current == null) return;
    _openTabs[_activeTabIndex] = current.copyWith(
      cursorLine: line,
      cursorColumn: column,
    );
    notifyListeners();
  }

  Future<void> saveActiveFile() async {
    final current = activeTab;
    if (current == null) return;

    _openTabs[_activeTabIndex] = current.copyWith(syncState: SyncState.saving);
    notifyListeners();

    try {
      await _backendService.saveFileContent(
        current.fileId,
        project.id,
        current.currentContent,
      );

      _openTabs[_activeTabIndex] = current.copyWith(
        initialContent: current.currentContent,
        syncState: SyncState.clean,
        version: current.version + 1,
      );
      notifyListeners();
    } catch (e) {
      _openTabs[_activeTabIndex] = current.copyWith(syncState: SyncState.saveFailed);
      notifyListeners();
    }
  }

  // Diagnostics & Problem Inspector
  void _analyzeDiagnostics(String code, String fileId, String filePath) {
    final List<DiagnosticIssue> issues = [];
    final lines = code.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineNum = i + 1;

      if (line.contains('pritn(')) {
        issues.add(
          DiagnosticIssue(
            id: 'diag_${fileId}_$lineNum',
            fileId: fileId,
            filePath: filePath,
            line: lineNum,
            column: line.indexOf('pritn(') + 1,
            message: "Undefined name 'pritn'. Did you mean 'print'?",
            severity: DiagnosticSeverity.error,
            source: 'PyLint',
          ),
        );
      } else if (line.trim().startsWith('def ') && !line.trim().endsWith(':')) {
        issues.add(
          DiagnosticIssue(
            id: 'diag_${fileId}_def_$lineNum',
            fileId: fileId,
            filePath: filePath,
            line: lineNum,
            column: line.length,
            message: "SyntaxError: Expected ':' at end of function definition",
            severity: DiagnosticSeverity.error,
            source: 'SyntaxChecker',
          ),
        );
      } else if (line.trim().startsWith('import ') && line.contains('unused_module')) {
        issues.add(
          DiagnosticIssue(
            id: 'diag_${fileId}_warn_$lineNum',
            fileId: fileId,
            filePath: filePath,
            line: lineNum,
            column: 1,
            message: "Module imported but never used: 'unused_module'",
            severity: DiagnosticSeverity.warning,
            source: 'Flake8',
          ),
        );
      }
    }

    _diagnostics = issues;
    notifyListeners();
  }

  // File Operations
  Future<void> createNewFile(String name, {String? parentId}) async {
    final newFile = await _backendService.createFileOrFolder(
      projectId: project.id,
      name: name,
      type: FileNodeType.file,
      parentId: parentId,
    );
    _fileTree = await _backendService.getProjectTree(project.id);
    openFile(newFile);
    notifyListeners();
  }

  Future<void> createNewFolder(String name, {String? parentId}) async {
    await _backendService.createFileOrFolder(
      projectId: project.id,
      name: name,
      type: FileNodeType.folder,
      parentId: parentId,
    );
    _fileTree = await _backendService.getProjectTree(project.id);
    notifyListeners();
  }

  // Save currently active file to Native Phone / Desktop Device Storage
  Future<bool> saveActiveFileToDevice() async {
    final current = activeTab;
    if (current == null) return false;

    await saveActiveFile();
    final result = await FileImportService.saveFileToDevice(
      fileName: current.title,
      content: current.currentContent,
    );
    return result != null;
  }

  // Save specific file node to Native Phone / Desktop Device Storage
  Future<bool> saveFileNodeToDevice(FileNodeModel node) async {
    final result = await FileImportService.saveFileToDevice(
      fileName: node.name,
      content: node.content,
    );
    return result != null;
  }

  // Export Entire Project & Folders to Native Phone / Desktop Storage
  Future<bool> exportEntireProjectToDevice() async {
    await saveActiveFile();

    final List<Map<String, String>> flatFiles = [];
    _collectFilesRecursively(_fileTree, flatFiles);

    if (flatFiles.isEmpty && activeTab != null) {
      flatFiles.add({
        'path': activeTab!.title,
        'content': activeTab!.currentContent,
      });
    }

    if (flatFiles.isEmpty) return false;

    return await FileImportService.saveProjectToDeviceFolder(
      projectName: project.name.replaceAll(' ', '_'),
      files: flatFiles,
    );
  }

  void _collectFilesRecursively(List<FileNodeModel> nodes, List<Map<String, String>> result) {
    for (final node in nodes) {
      if (!node.isFolder) {
        result.add({
          'path': node.path,
          'content': node.content,
        });
      } else if (node.children.isNotEmpty) {
        _collectFilesRecursively(node.children, result);
      }
    }
  }

  // Pick External File(s) from Mobile / Desktop File Manager
  Future<bool> importExternalFiles({String? parentId}) async {
    try {
      final items = await FileImportService.pickExternalFiles();
      if (items.isEmpty) return false;

      FileNodeModel? lastCreatedFile;

      for (final item in items) {
        final node = await _backendService.createFileOrFolder(
          projectId: project.id,
          name: item.name,
          type: FileNodeType.file,
          parentId: parentId,
        );
        await _backendService.saveFileContent(node.id, project.id, item.content);
        lastCreatedFile = node.copyWith(content: item.content);
      }

      _fileTree = await _backendService.getProjectTree(project.id);
      if (lastCreatedFile != null) {
        openFile(lastCreatedFile);
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error importing external files: $e');
      return false;
    }
  }

  // Pick External Folder from Mobile / Desktop File Manager
  Future<bool> importExternalFolder({String? parentId}) async {
    try {
      final items = await FileImportService.pickExternalDirectory();
      if (items.isEmpty) return false;

      for (final item in items) {
        await _importItemRecursively(item, parentId);
      }

      _fileTree = await _backendService.getProjectTree(project.id);
      // Open the first file from imported tree
      final firstFile = _findFirstFile(_fileTree);
      if (firstFile != null) {
        openFile(firstFile);
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error importing external folder: $e');
      return false;
    }
  }

  Future<void> _importItemRecursively(ImportedFileItem item, String? parentId) async {
    if (item.isFolder) {
      final folderNode = await _backendService.createFileOrFolder(
        projectId: project.id,
        name: item.name,
        type: FileNodeType.folder,
        parentId: parentId,
      );
      for (final child in item.children) {
        await _importItemRecursively(child, folderNode.id);
      }
    } else {
      final fileNode = await _backendService.createFileOrFolder(
        projectId: project.id,
        name: item.name,
        type: FileNodeType.file,
        parentId: parentId,
      );
      await _backendService.saveFileContent(fileNode.id, project.id, item.content);
    }
  }

  Future<void> deleteNode(String fileId) async {
    await _backendService.deleteFileOrFolder(project.id, fileId);
    _fileTree = await _backendService.getProjectTree(project.id);
    _openTabs.removeWhere((tab) => tab.fileId == fileId);
    if (_activeTabIndex >= _openTabs.length) {
      _activeTabIndex = _openTabs.isNotEmpty ? _openTabs.length - 1 : 0;
    }
    notifyListeners();
  }

  // Panels & Views Toggles
  void toggleExplorer() {
    _isExplorerOpen = !_isExplorerOpen;
    notifyListeners();
  }

  void toggleTerminal() {
    _isTerminalOpen = !_isTerminalOpen;
    notifyListeners();
  }

  void toggleProblems() {
    _isProblemsOpen = !_isProblemsOpen;
    notifyListeners();
  }

  void toggleFindReplace() {
    _isFindReplaceOpen = !_isFindReplaceOpen;
    notifyListeners();
  }

  void toggleChat() {
    _isChatOpen = !_isChatOpen;
    notifyListeners();
  }

  void setFontSize(double size) {
    _fontSize = size.clamp(10.0, 26.0);
    notifyListeners();
  }

  void setSyntaxPreset(SyntaxThemePreset preset) {
    _syntaxPreset = preset;
    notifyListeners();
  }

  void clearTerminal() {
    _terminalLogs.clear();
    notifyListeners();
  }

  // Execution Flow
  Future<void> runCode() async {
    final current = activeTab;
    if (current == null) return;

    // First auto-save
    await saveActiveFile();

    _isExecuting = true;
    _isTerminalOpen = true;
    _terminalLogs.clear();
    notifyListeners();

    try {
      final job = await _backendService.executePythonCode(
        projectId: project.id,
        fileId: current.fileId,
        fileName: current.title,
        code: current.currentContent,
        config: _runConfig,
        onLogChunk: (log) {
          _terminalLogs.add(log);
          notifyListeners();
        },
      );
      _currentExecution = job;
    } catch (e) {
      _terminalLogs.add(
        ExecutionLog(
          id: 'err_${DateTime.now().millisecondsSinceEpoch}',
          executionId: 'err',
          stream: LogStreamType.stderr,
          sequence: _terminalLogs.length + 1,
          content: 'Execution Exception: $e',
          createdAt: DateTime.now(),
        ),
      );
    } finally {
      _isExecuting = false;
      notifyListeners();
    }
  }

  void stopExecution() {
    _isExecuting = false;
    _terminalLogs.add(
      ExecutionLog(
        id: 'cancel_${DateTime.now().millisecondsSinceEpoch}',
        executionId: _currentExecution?.id ?? 'job',
        stream: LogStreamType.system,
        sequence: _terminalLogs.length + 1,
        content: '[Process terminated by user cancellation]',
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  // Build Context for Ask Developer action
  MessageContext buildErrorContext() {
    final current = activeTab;
    final lastStderr = _terminalLogs
        .where((l) => l.stream == LogStreamType.stderr)
        .map((l) => l.content)
        .join('\n');

    int lineNum = 1;
    if (lastStderr.contains('line ')) {
      final match = RegExp(r'line (\d+)').firstMatch(lastStderr);
      if (match != null) {
        lineNum = int.tryParse(match.group(1) ?? '1') ?? 1;
      }
    }

    return MessageContext(
      id: 'ctx_${DateTime.now().millisecondsSinceEpoch}',
      projectId: project.id,
      fileId: current?.fileId,
      fileName: current?.title ?? 'main.py',
      lineStart: lineNum,
      lineEnd: lineNum,
      codeSnippet: current?.currentContent,
      executionId: _currentExecution?.id,
      errorSummary: lastStderr.isNotEmpty ? lastStderr.split('\n').last : 'Runtime exception',
      errorTraceback: lastStderr.isNotEmpty ? lastStderr : _currentExecution?.stderr,
      type: MessageContextType.executionError,
    );
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }
}
