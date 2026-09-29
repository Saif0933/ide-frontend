enum LogStreamType {
  stdout,
  stderr,
  system,
}

class ExecutionLog {
  final String id;
  final String executionId;
  final LogStreamType stream;
  final int sequence;
  final String content;
  final DateTime createdAt;

  const ExecutionLog({
    required this.id,
    required this.executionId,
    required this.stream,
    required this.sequence,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'executionId': executionId,
      'stream': stream.name,
      'sequence': sequence,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ExecutionLog.fromJson(Map<String, dynamic> json) {
    return ExecutionLog(
      id: json['id'] as String,
      executionId: json['executionId'] as String,
      stream: LogStreamType.values.firstWhere(
        (e) => e.name == json['stream'],
        orElse: () => LogStreamType.stdout,
      ),
      sequence: json['sequence'] as int? ?? 0,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
