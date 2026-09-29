import 'dart:async';
import 'package:frontend/core/errors/app_exceptions.dart';
import 'package:frontend/features/auth/models/user_model.dart';
import 'package:frontend/features/projects/models/project_model.dart';
import 'package:frontend/features/projects/models/template_model.dart';
import 'package:frontend/features/ide/models/file_node_model.dart';
import 'package:frontend/features/execution/models/execution_job.dart';
import 'package:frontend/features/execution/models/execution_log.dart';
import 'package:frontend/features/execution/models/run_config.dart';
import 'package:frontend/features/chat/models/chat_message.dart';
import 'package:frontend/features/chat/models/message_context.dart';
import 'package:frontend/features/notifications/models/notification_model.dart';
import 'package:frontend/features/ide/services/file_import_service.dart';
import 'websocket_client.dart';

class MockBackendService {
  static final MockBackendService _instance = MockBackendService._internal();
  factory MockBackendService() => _instance;
  MockBackendService._internal() {
    _seedInitialData();
  }

  UserModel? _currentUser;
  final List<ProjectModel> _projects = [];
  final Map<String, List<FileNodeModel>> _projectFiles = {};
  final List<ExecutionJob> _executions = [];
  final Map<String, List<ChatMessage>> _conversations = {};
  final List<NotificationModel> _notifications = [];

  UserModel? get currentUser => _currentUser;
  List<ProjectModel> get projects => List.unmodifiable(_projects);
  List<ExecutionJob> get executions => List.unmodifiable(_executions);
  List<NotificationModel> get notifications => List.unmodifiable(_notifications);

  void _seedInitialData() {
    final now = DateTime.now();
    _currentUser = UserModel(
      id: 'usr_001',
      name: 'Alex Rivera',
      email: 'alex.rivera@dev.io',
      phone: '+1 (555) 321-9876',
      role: 'developer',
      avatarUrl: '',
      createdAt: now.subtract(const Duration(days: 30)),
    );

    // Seed Project 1: Python Starter Kit
    final proj1 = ProjectModel(
      id: 'proj_001',
      ownerId: 'usr_001',
      name: 'Data Analytics Engine',
      description: 'Statistical calculations, data pipelines, and CLI report generator.',
      language: 'python',
      visibility: ProjectVisibility.privateProject,
      lastExecutionStatus: ProjectExecutionStatus.success,
      createdAt: now.subtract(const Duration(days: 5)),
      updatedAt: now.subtract(const Duration(minutes: 15)),
      fileCount: 4,
      defaultFile: 'main.py',
    );

    // Seed Project 2: Algorithm Sandbox (with intentional NameError for Ask Developer flow)
    final proj2 = ProjectModel(
      id: 'proj_002',
      ownerId: 'usr_001',
      name: 'Algorithm Sandbox',
      description: 'Dynamic programming, sorting, and graph traversal algorithms.',
      language: 'python',
      visibility: ProjectVisibility.privateProject,
      lastExecutionStatus: ProjectExecutionStatus.failed,
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now.subtract(const Duration(minutes: 3)),
      fileCount: 2,
      defaultFile: 'main.py',
    );

    // Seed Project 3: API Microservice
    final proj3 = ProjectModel(
      id: 'proj_003',
      ownerId: 'usr_001',
      name: 'Python Web Scraper',
      description: 'Async web requests and HTML parser pipeline.',
      language: 'python',
      visibility: ProjectVisibility.privateProject,
      lastExecutionStatus: ProjectExecutionStatus.idle,
      createdAt: now.subtract(const Duration(days: 10)),
      updatedAt: now.subtract(const Duration(hours: 8)),
      fileCount: 3,
      defaultFile: 'main.py',
    );

    _projects.addAll([proj1, proj2, proj3]);

    // Seed files for proj1
    _projectFiles['proj_001'] = [
      FileNodeModel(
        id: 'file_001',
        projectId: 'proj_001',
        name: 'main.py',
        type: FileNodeType.file,
        path: 'main.py',
        size: 480,
        version: 3,
        content: '''#!/usr/bin/env python3
"""
Project: Data Analytics Engine
PyStudio Cloud Execution Sandbox (Python 3.12)
"""
from utils import calculate_metrics, display_summary

def main():
    print("=== PyStudio High-Performance Analytics ===")
    sample_data = [42, 88, 19, 95, 73, 61, 84, 99, 15, 67]
    print(f"[*] Processing dataset with {len(sample_data)} samples...")
    
    metrics = calculate_metrics(sample_data)
    display_summary(metrics)
    print("\\n[SUCCESS] Computation finished successfully.")

if __name__ == "__main__":
    main()
''',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(minutes: 15)),
      ),
      FileNodeModel(
        id: 'file_002',
        projectId: 'proj_001',
        name: 'utils.py',
        type: FileNodeType.file,
        path: 'utils.py',
        size: 620,
        version: 2,
        content: '''def calculate_metrics(values: list[int]) -> dict:
    """Computes basic statistical metrics."""
    if not values:
        return {}
    
    sorted_vals = sorted(values)
    n = len(values)
    mean = sum(values) / n
    median = (sorted_vals[n // 2] if n % 2 != 0 
              else (sorted_vals[n // 2 - 1] + sorted_vals[n // 2]) / 2)
    
    return {
        "count": n,
        "sum": sum(values),
        "mean": round(mean, 2),
        "median": median,
        "min": min(values),
        "max": max(values),
    }

def display_summary(metrics: dict):
    print("----------------------------------------")
    print(f"Total Elements : {metrics.get('count', 0)}")
    print(f"Mean Value     : {metrics.get('mean', 0.0)}")
    print(f"Median Value   : {metrics.get('median', 0.0)}")
    print(f"Min / Max      : {metrics.get('min')} / {metrics.get('max')}")
    print("----------------------------------------")
''',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(hours: 1)),
      ),
      FileNodeModel(
        id: 'folder_001',
        projectId: 'proj_001',
        name: 'models',
        type: FileNodeType.folder,
        path: 'models',
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(days: 4)),
        children: [
          FileNodeModel(
            id: 'file_003',
            projectId: 'proj_001',
            parentId: 'folder_001',
            name: 'dataset.py',
            type: FileNodeType.file,
            path: 'models/dataset.py',
            size: 320,
            version: 1,
            content: '''class Dataset:
    def __init__(self, raw_data: list):
        self.raw_data = raw_data
        
    def filter_outliers(self, threshold=100):
        return [x for x in self.raw_data if x <= threshold]
''',
            createdAt: now.subtract(const Duration(days: 4)),
            updatedAt: now.subtract(const Duration(days: 4)),
          ),
        ],
      ),
      FileNodeModel(
        id: 'file_004',
        projectId: 'proj_001',
        name: 'README.md',
        type: FileNodeType.file,
        path: 'README.md',
        size: 210,
        version: 1,
        content: '# Data Analytics Engine\n\nRun `python main.py` in your isolated PyStudio container.\n',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
    ];

    // Seed files for proj2 (Algorithm Sandbox)
    _projectFiles['proj_002'] = [
      FileNodeModel(
        id: 'file_201',
        projectId: 'proj_002',
        name: 'main.py',
        type: FileNodeType.file,
        path: 'main.py',
        size: 350,
        version: 4,
        content: '''#!/usr/bin/env python3
"""
Algorithm Sandbox: Quick Sort & Binary Search
Note: Demonstrates execution error detection and Ask Developer workflow.
"""

def bubble_sort(arr):
    n = len(arr)
    for i in range(n):
        for j in range(0, n - i - 1):
            if arr[j] > arr[j + 1]:
                arr[j], arr[j + 1] = arr[j + 1], arr[j]
    return arr

def main():
    numbers = [64, 34, 25, 12, 22, 11, 90]
    print("[*] Unsorted array:", numbers)
    
    # Intentional typo below to test Error -> Ask Developer feature
    sorted_array = bubble_sort(numbers)
    pritn(f"Sorted Result: {sorted_array}")

if __name__ == "__main__":
    main()
''',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(minutes: 3)),
      ),
    ];

    // Seed Conversations
    _conversations['proj_001'] = [
      ChatMessage(
        id: 'msg_001',
        conversationId: 'proj_001',
        projectId: 'proj_001',
        senderId: 'usr_mentor',
        senderName: 'Elena Rostova (Mentor)',
        senderType: MessageSenderType.developer,
        content: 'Hi Alex! I reviewed your `calculate_metrics` implementation in `utils.py`. The edge cases for empty lists look clean. Let me know if you need help adding standard deviation formulas!',
        createdAt: now.subtract(const Duration(hours: 2)),
        status: MessageDeliveryStatus.read,
      ),
      ChatMessage(
        id: 'msg_002',
        conversationId: 'proj_001',
        projectId: 'proj_001',
        senderId: 'usr_001',
        senderName: 'Alex Rivera',
        senderType: MessageSenderType.user,
        content: 'Thanks Elena! I will add variance and standard deviation next. Cloud execution runs super fast!',
        createdAt: now.subtract(const Duration(hours: 1, minutes: 45)),
        status: MessageDeliveryStatus.read,
      ),
    ];

    _conversations['proj_002'] = [
      ChatMessage(
        id: 'msg_201',
        conversationId: 'proj_002',
        projectId: 'proj_002',
        senderId: 'usr_mentor',
        senderName: 'Marcus Vance (Staff Eng)',
        senderType: MessageSenderType.developer,
        content: 'Welcome to your Algorithm Sandbox project! If you encounter any traceback errors during execution, tap the "Ask Developer" button in the terminal to share the traceback context.',
        createdAt: now.subtract(const Duration(days: 1)),
        status: MessageDeliveryStatus.read,
      ),
    ];

    // Seed Notifications
    _notifications.addAll([
      NotificationModel(
        id: 'notif_001',
        userId: 'usr_001',
        title: 'Developer Reply Received',
        body: 'Elena Rostova commented on project "Data Analytics Engine".',
        type: NotificationType.chatReply,
        projectId: 'proj_001',
        conversationId: 'proj_001',
        createdAt: now.subtract(const Duration(hours: 2)),
        isRead: true,
      ),
      NotificationModel(
        id: 'notif_002',
        userId: 'usr_001',
        title: 'Execution Succeeded',
        body: 'Job #job_992 in "Data Analytics Engine" completed in 240ms with exit code 0.',
        type: NotificationType.executionCompleted,
        projectId: 'proj_001',
        createdAt: now.subtract(const Duration(minutes: 15)),
        isRead: false,
      ),
    ]);
  }

  // Auth Simulation
  Future<bool> requestOtp(String emailOrPhone) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }

  Future<UserModel> verifyOtp(String emailOrPhone, String otp) async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (otp == '123456' || otp.length == 6) {
      _currentUser = UserModel(
        id: 'usr_001',
        name: emailOrPhone.contains('@') ? emailOrPhone.split('@')[0] : 'Developer',
        email: emailOrPhone.contains('@') ? emailOrPhone : 'dev@pystudio.io',
        phone: !emailOrPhone.contains('@') ? emailOrPhone : null,
        role: 'developer',
        createdAt: DateTime.now(),
      );
      return _currentUser!;
    }
    throw AuthException('Invalid OTP code. Please enter valid 6-digit code (Use 123456).');
  }

  // Project APIs
  Future<List<ProjectModel>> getProjects() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_projects);
  }

  Future<ProjectModel> createProject({
    required String name,
    String description = '',
    String templateId = 'empty_python',
    ProjectVisibility visibility = ProjectVisibility.privateProject,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final newId = 'proj_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final template = TemplateModel.defaultTemplates.firstWhere(
      (t) => t.id == templateId,
      orElse: () => TemplateModel.defaultTemplates.first,
    );

    final newProject = ProjectModel(
      id: newId,
      ownerId: _currentUser?.id ?? 'usr_001',
      name: name,
      description: description,
      language: 'python',
      visibility: visibility,
      lastExecutionStatus: ProjectExecutionStatus.idle,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      fileCount: template.initialFiles.length,
      defaultFile: template.initialFiles.keys.first,
    );

    _projects.insert(0, newProject);

    // Create template files
    final List<FileNodeModel> files = [];
    int idx = 1;
    template.initialFiles.forEach((filename, content) {
      files.add(
        FileNodeModel(
          id: 'file_${newId}_$idx',
          projectId: newId,
          name: filename,
          type: FileNodeType.file,
          path: filename,
          size: content.length,
          version: 1,
          content: content,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      idx++;
    });
    _projectFiles[newId] = files;
    _conversations[newId] = [];

    return newProject;
  }

  Future<ProjectModel> createProjectWithFiles({
    required String name,
    String description = '',
    required List<ImportedFileItem> importedFiles,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newId = 'proj_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    
    String defaultFileName = 'main.py';
    if (importedFiles.isNotEmpty) {
      final first = importedFiles.first;
      if (!first.isFolder) {
        defaultFileName = first.name;
      } else if (first.children.isNotEmpty) {
        final firstFile = _findFirstImportedFile(first);
        if (firstFile != null) defaultFileName = firstFile.name;
      }
    }

    final newProject = ProjectModel(
      id: newId,
      ownerId: _currentUser?.id ?? 'usr_001',
      name: name,
      description: description.isNotEmpty ? description : 'Imported from device file manager',
      language: 'python',
      visibility: ProjectVisibility.privateProject,
      lastExecutionStatus: ProjectExecutionStatus.idle,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      fileCount: importedFiles.length,
      defaultFile: defaultFileName,
    );

    _projects.insert(0, newProject);

    final List<FileNodeModel> files = [];
    int idx = 1;
    for (final item in importedFiles) {
      if (item.isFolder) {
        final folderId = 'folder_${newId}_$idx';
        final folderNode = FileNodeModel(
          id: folderId,
          projectId: newId,
          name: item.name,
          type: FileNodeType.folder,
          path: item.path,
          children: _convertImportedChildren(newId, item.children, folderId),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        files.add(folderNode);
      } else {
        files.add(
          FileNodeModel(
            id: 'file_${newId}_$idx',
            projectId: newId,
            name: item.name,
            type: FileNodeType.file,
            path: item.path,
            size: item.content.length,
            version: 1,
            content: item.content,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      }
      idx++;
    }

    _projectFiles[newId] = files;
    _conversations[newId] = [];
    return newProject;
  }

  ImportedFileItem? _findFirstImportedFile(ImportedFileItem folder) {
    for (final child in folder.children) {
      if (!child.isFolder) return child;
      final sub = _findFirstImportedFile(child);
      if (sub != null) return sub;
    }
    return null;
  }

  List<FileNodeModel> _convertImportedChildren(String projectId, List<ImportedFileItem> items, String parentId) {
    final List<FileNodeModel> result = [];
    int subIdx = 1;
    for (final item in items) {
      final subId = '${parentId}_$subIdx';
      if (item.isFolder) {
        result.add(
          FileNodeModel(
            id: subId,
            projectId: projectId,
            parentId: parentId,
            name: item.name,
            type: FileNodeType.folder,
            path: item.path,
            children: _convertImportedChildren(projectId, item.children, subId),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      } else {
        result.add(
          FileNodeModel(
            id: subId,
            projectId: projectId,
            parentId: parentId,
            name: item.name,
            type: FileNodeType.file,
            path: item.path,
            size: item.content.length,
            version: 1,
            content: item.content,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      }
      subIdx++;
    }
    return result;
  }

  Future<void> deleteProject(String projectId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _projects.removeWhere((p) => p.id == projectId);
    _projectFiles.remove(projectId);
    _conversations.remove(projectId);
  }

  // File Tree APIs
  Future<List<FileNodeModel>> getProjectTree(String projectId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return List.from(_projectFiles[projectId] ?? []);
  }

  Future<FileNodeModel> createFileOrFolder({
    required String projectId,
    required String name,
    required FileNodeType type,
    String? parentId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Path validation
    if (name.contains('..') || name.contains('/') || name.contains('\\')) {
      throw ValidationException('Invalid file name. Path traversal characters not allowed.');
    }

    final newId = 'file_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final newFile = FileNodeModel(
      id: newId,
      projectId: projectId,
      parentId: parentId,
      name: name,
      type: type,
      path: parentId != null ? '$parentId/$name' : name,
      size: 0,
      version: 1,
      content: type == FileNodeType.file ? '# Created in PyStudio\n\n' : '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final list = _projectFiles[projectId] ?? [];
    if (parentId == null) {
      list.add(newFile);
    } else {
      _insertIntoTree(list, parentId, newFile);
    }
    _projectFiles[projectId] = list;
    return newFile;
  }

  bool _insertIntoTree(List<FileNodeModel> nodes, String parentId, FileNodeModel newChild) {
    for (int i = 0; i < nodes.length; i++) {
      if (nodes[i].id == parentId && nodes[i].isFolder) {
        final updatedChildren = List<FileNodeModel>.from(nodes[i].children)..add(newChild);
        nodes[i] = nodes[i].copyWith(children: updatedChildren);
        return true;
      }
      if (nodes[i].children.isNotEmpty) {
        if (_insertIntoTree(nodes[i].children, parentId, newChild)) return true;
      }
    }
    return false;
  }

  Future<void> saveFileContent(String fileId, String projectId, String content) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final list = _projectFiles[projectId] ?? [];
    _updateNodeContent(list, fileId, content);
  }

  bool _updateNodeContent(List<FileNodeModel> nodes, String fileId, String content) {
    for (int i = 0; i < nodes.length; i++) {
      if (nodes[i].id == fileId) {
        nodes[i] = nodes[i].copyWith(
          content: content,
          size: content.length,
          version: nodes[i].version + 1,
          updatedAt: DateTime.now(),
        );
        return true;
      }
      if (nodes[i].children.isNotEmpty) {
        if (_updateNodeContent(nodes[i].children, fileId, content)) return true;
      }
    }
    return false;
  }

  Future<void> deleteFileOrFolder(String projectId, String fileId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final list = _projectFiles[projectId] ?? [];
    _deleteNodeFromTree(list, fileId);
    _projectFiles[projectId] = list;
  }

  void _deleteNodeFromTree(List<FileNodeModel> nodes, String fileId) {
    nodes.removeWhere((node) => node.id == fileId);
    for (int i = 0; i < nodes.length; i++) {
      if (nodes[i].children.isNotEmpty) {
        _deleteNodeFromTree(nodes[i].children, fileId);
      }
    }
  }

  // Execution Sandbox Simulation
  Future<ExecutionJob> executePythonCode({
    required String projectId,
    required String fileId,
    required String fileName,
    required String code,
    RunConfig? config,
    required Function(ExecutionLog log) onLogChunk,
  }) async {
    final jobId = 'job_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final startTime = DateTime.now();

    // 1. Queued state
    var job = ExecutionJob(
      id: jobId,
      projectId: projectId,
      fileId: fileId,
      fileName: fileName,
      status: ExecutionStatus.queued,
      queueJobId: 'bullmq_$jobId',
      startedAt: startTime,
    );
    _executions.insert(0, job);
    WebSocketClient().emit('execution.queued', {'executionId': jobId, 'status': 'queued'});

    await Future.delayed(const Duration(milliseconds: 350));

    // 2. Running state
    job = job.copyWith(status: ExecutionStatus.running);
    WebSocketClient().emit('execution.started', {'executionId': jobId, 'startedAt': startTime.toIso8601String()});

    int seq = 1;
    final log1 = ExecutionLog(
      id: 'log_${jobId}_$seq',
      executionId: jobId,
      stream: LogStreamType.system,
      sequence: seq++,
      content: '[Sandbox] Initializing Python 3.12 isolated runner (Memory limit: 128MB, Timeout: 15s)...',
      createdAt: DateTime.now(),
    );
    onLogChunk(log1);

    await Future.delayed(const Duration(milliseconds: 250));

    // Check code patterns for realistic simulation
    final bool hasSyntaxError = code.contains('pritn(') || code.contains('def ') && !code.contains(':') && code.contains('\n');
    final bool hasNameError = code.contains('pritn(') || (code.contains('undefined_var'));
    final bool hasInfiniteLoop = code.contains('while True:') && !code.contains('break');
    final bool hasDivisionByZero = code.contains('/ 0') || code.contains('/0');

    if (hasInfiniteLoop) {
      // Simulate timeout
      await Future.delayed(const Duration(milliseconds: 900));
      final timeoutLog = ExecutionLog(
        id: 'log_${jobId}_$seq',
        executionId: jobId,
        stream: LogStreamType.stderr,
        sequence: seq++,
        content: 'ExecutionError: Process exceeded max runtime quota (15.0s hard timeout). Terminated by sandbox supervisor.',
        createdAt: DateTime.now(),
      );
      onLogChunk(timeoutLog);

      final finishedTime = DateTime.now();
      job = job.copyWith(
        status: ExecutionStatus.timedOut,
        finishedAt: finishedTime,
        exitCode: 124,
        durationMs: 15000,
        stderr: timeoutLog.content,
        memoryUsage: '34.2 MB',
        cpuUsage: '99.8%',
      );
      WebSocketClient().emit('execution.failed', {'executionId': jobId, 'status': 'timedOut', 'exitCode': 124});
      return job;
    }

    if (hasNameError || hasSyntaxError || hasDivisionByZero) {
      await Future.delayed(const Duration(milliseconds: 400));
      String errorMsg = '';
      if (code.contains('pritn(')) {
        errorMsg = '''Traceback (most recent call last):
  File "$fileName", line 22, in main
    pritn(f"Sorted Result: {sorted_array}")
NameError: name 'pritn' is not defined. Did you mean: 'print'?''';
      } else if (hasDivisionByZero) {
        errorMsg = '''Traceback (most recent call last):
  File "$fileName", line 14, in <module>
ZeroDivisionError: division by zero''';
      } else {
        errorMsg = '''Traceback (most recent call last):
  File "$fileName", line 8
SyntaxError: invalid syntax''';
      }

      final errLog = ExecutionLog(
        id: 'log_${jobId}_$seq',
        executionId: jobId,
        stream: LogStreamType.stderr,
        sequence: seq++,
        content: errorMsg,
        createdAt: DateTime.now(),
      );
      onLogChunk(errLog);

      final finishedTime = DateTime.now();
      job = job.copyWith(
        status: ExecutionStatus.failed,
        finishedAt: finishedTime,
        exitCode: 1,
        durationMs: 380,
        stderr: errorMsg,
        memoryUsage: '18.4 MB',
        cpuUsage: '14.2%',
      );

      // Update project status
      _updateProjectExecutionStatus(projectId, ProjectExecutionStatus.failed);
      WebSocketClient().emit('execution.failed', {'executionId': jobId, 'status': 'failed', 'exitCode': 1});
      return job;
    }

    // Standard Success Execution Simulation
    final lines = code.split('\n');
    final List<String> printedOutputs = [];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('print(') && trimmed.endsWith(')')) {
        var inner = trimmed.substring(6, trimmed.length - 1);
        if (inner.startsWith('f"') || inner.startsWith('f\'')) {
          inner = inner.substring(2, inner.length - 1);
        } else if ((inner.startsWith('"') && inner.endsWith('"')) || (inner.startsWith('\'') && inner.endsWith('\''))) {
          inner = inner.substring(1, inner.length - 1);
        }
        printedOutputs.add(inner);
      }
    }

    if (printedOutputs.isEmpty) {
      printedOutputs.add('>>> Output from Python 3.12:');
      printedOutputs.add('Hello from PyStudio Cloud Execution Engine!');
      printedOutputs.add('All assertions passed.');
    }

    for (final output in printedOutputs) {
      await Future.delayed(const Duration(milliseconds: 180));
      final outLog = ExecutionLog(
        id: 'log_${jobId}_$seq',
        executionId: jobId,
        stream: LogStreamType.stdout,
        sequence: seq++,
        content: output,
        createdAt: DateTime.now(),
      );
      onLogChunk(outLog);
    }

    final finishedTime = DateTime.now();
    final duration = finishedTime.difference(startTime).inMilliseconds;

    job = job.copyWith(
      status: ExecutionStatus.completed,
      finishedAt: finishedTime,
      exitCode: 0,
      durationMs: duration > 0 ? duration : 260,
      stdout: printedOutputs.join('\n'),
      memoryUsage: '22.6 MB',
      cpuUsage: '8.4%',
    );

    _updateProjectExecutionStatus(projectId, ProjectExecutionStatus.success);
    WebSocketClient().emit('execution.completed', {'executionId': jobId, 'status': 'completed', 'exitCode': 0});
    return job;
  }

  void _updateProjectExecutionStatus(String projectId, ProjectExecutionStatus status) {
    final idx = _projects.indexWhere((p) => p.id == projectId);
    if (idx != -1) {
      _projects[idx] = _projects[idx].copyWith(
        lastExecutionStatus: status,
        updatedAt: DateTime.now(),
      );
    }
  }

  // Chat APIs
  Future<List<ChatMessage>> getConversation(String projectId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_conversations[projectId] ?? []);
  }

  Future<ChatMessage> sendMessage({
    required String projectId,
    required String content,
    MessageContext? context,
  }) async {
    final msgId = 'msg_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final userMsg = ChatMessage(
      id: msgId,
      conversationId: projectId,
      projectId: projectId,
      senderId: _currentUser?.id ?? 'usr_001',
      senderName: _currentUser?.name ?? 'Alex Rivera',
      senderType: MessageSenderType.user,
      content: content,
      createdAt: DateTime.now(),
      status: MessageDeliveryStatus.delivered,
      contextAttachment: context,
    );

    final list = _conversations[projectId] ?? [];
    list.add(userMsg);
    _conversations[projectId] = list;

    // Trigger realistic developer mentor reply
    _scheduleDeveloperReply(projectId, content, context);

    return userMsg;
  }

  void _scheduleDeveloperReply(String projectId, String userContent, MessageContext? context) {
    Future.delayed(const Duration(milliseconds: 1400), () {
      String replyText = "I see your message! Let's check the code.";

      if (context?.errorSummary != null || userContent.toLowerCase().contains('nameerror') || userContent.toLowerCase().contains('error') || userContent.toLowerCase().contains('fix')) {
        if (context?.errorTraceback?.contains('pritn') == true || userContent.contains('pritn')) {
          replyText = "I spotted the issue in line ${context?.lineStart ?? 22}: you have a typo in `pritn()`. Replace it with `print()` and rerun the script in the sandbox!";
        } else {
          replyText = "Looking at the traceback context:\n`${context?.errorSummary ?? 'Traceback'}`\nMake sure all referenced identifiers and imports are defined before calling them in your main execution loop.";
        }
      } else if (context?.codeSnippet != null) {
        replyText = "Thanks for attaching the snippet from `${context?.fileName}` (lines ${context?.lineStart}-${context?.lineEnd}). The logic looks sound! Consider adding type hints for better readability.";
      } else {
        replyText = "Got your question regarding the project! I've inspected your current workspace snapshot. What specific logic would you like to optimize?";
      }

      final devMsg = ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        conversationId: projectId,
        projectId: projectId,
        senderId: 'usr_mentor',
        senderName: 'Marcus Vance (Staff Eng)',
        senderType: MessageSenderType.developer,
        content: replyText,
        createdAt: DateTime.now(),
        status: MessageDeliveryStatus.delivered,
      );

      _conversations[projectId]?.add(devMsg);
      WebSocketClient().emit('chat.message', {'conversationId': projectId, 'message': devMsg.toJson()});

      // Also create a notification
      final notif = NotificationModel(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
        userId: _currentUser?.id ?? 'usr_001',
        title: 'Marcus Vance replied',
        body: replyText.length > 80 ? '${replyText.substring(0, 80)}...' : replyText,
        type: NotificationType.chatReply,
        projectId: projectId,
        conversationId: projectId,
        createdAt: DateTime.now(),
      );
      _notifications.insert(0, notif);
    });
  }

  void markNotificationAsRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
    }
  }

  void markAllNotificationsAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }
}
