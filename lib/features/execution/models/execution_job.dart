enum ExecutionStatus {
  queued,
  running,
  completed,
  failed,
  timedOut,
  cancelled,
}

class ExecutionJob {
  final String id;
  final String projectId;
  final String fileId;
  final String fileName;
  final ExecutionStatus status;
  final String? queueJobId;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final int? exitCode;
  final int? durationMs;
  final String? stdout;
  final String? stderr;
  final String? memoryUsage;
  final String? cpuUsage;

  const ExecutionJob({
    required this.id,
    required this.projectId,
    required this.fileId,
    required this.fileName,
    this.status = ExecutionStatus.queued,
    this.queueJobId,
    required this.startedAt,
    this.finishedAt,
    this.exitCode,
    this.durationMs,
    this.stdout,
    this.stderr,
    this.memoryUsage,
    this.cpuUsage,
  });

  bool get isRunning => status == ExecutionStatus.running || status == ExecutionStatus.queued;
  bool get isSuccess => status == ExecutionStatus.completed && exitCode == 0;
  bool get hasFailed => status == ExecutionStatus.failed || (exitCode != null && exitCode != 0) || status == ExecutionStatus.timedOut;

  ExecutionJob copyWith({
    String? id,
    String? projectId,
    String? fileId,
    String? fileName,
    ExecutionStatus? status,
    String? queueJobId,
    DateTime? startedAt,
    DateTime? finishedAt,
    int? exitCode,
    int? durationMs,
    String? stdout,
    String? stderr,
    String? memoryUsage,
    String? cpuUsage,
  }) {
    return ExecutionJob(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      fileId: fileId ?? this.fileId,
      fileName: fileName ?? this.fileName,
      status: status ?? this.status,
      queueJobId: queueJobId ?? this.queueJobId,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      exitCode: exitCode ?? this.exitCode,
      durationMs: durationMs ?? this.durationMs,
      stdout: stdout ?? this.stdout,
      stderr: stderr ?? this.stderr,
      memoryUsage: memoryUsage ?? this.memoryUsage,
      cpuUsage: cpuUsage ?? this.cpuUsage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'fileId': fileId,
      'fileName': fileName,
      'status': status.name,
      'queueJobId': queueJobId,
      'startedAt': startedAt.toIso8601String(),
      'finishedAt': finishedAt?.toIso8601String(),
      'exitCode': exitCode,
      'durationMs': durationMs,
      'stdout': stdout,
      'stderr': stderr,
      'memoryUsage': memoryUsage,
      'cpuUsage': cpuUsage,
    };
  }

  factory ExecutionJob.fromJson(Map<String, dynamic> json) {
    return ExecutionJob(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      fileId: json['fileId'] as String,
      fileName: json['fileName'] as String? ?? 'main.py',
      status: ExecutionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ExecutionStatus.queued,
      ),
      queueJobId: json['queueJobId'] as String?,
      startedAt: DateTime.parse(json['startedAt'] as String),
      finishedAt: json['finishedAt'] != null ? DateTime.parse(json['finishedAt'] as String) : null,
      exitCode: json['exitCode'] as int?,
      durationMs: json['durationMs'] as int?,
      stdout: json['stdout'] as String?,
      stderr: json['stderr'] as String?,
      memoryUsage: json['memoryUsage'] as String?,
      cpuUsage: json['cpuUsage'] as String?,
    );
  }
}
