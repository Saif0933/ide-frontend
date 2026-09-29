enum MessageContextType {
  fileSnippet,
  executionError,
  fullFile,
  terminalOutput,
}

class MessageContext {
  final String id;
  final String? messageId;
  final String projectId;
  final String? fileId;
  final String? fileName;
  final int? lineStart;
  final int? lineEnd;
  final String? codeSnippet;
  final String? executionId;
  final String? errorSummary;
  final String? errorTraceback;
  final MessageContextType type;

  const MessageContext({
    required this.id,
    this.messageId,
    required this.projectId,
    this.fileId,
    this.fileName,
    this.lineStart,
    this.lineEnd,
    this.codeSnippet,
    this.executionId,
    this.errorSummary,
    this.errorTraceback,
    this.type = MessageContextType.fileSnippet,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'messageId': messageId,
      'projectId': projectId,
      'fileId': fileId,
      'fileName': fileName,
      'lineStart': lineStart,
      'lineEnd': lineEnd,
      'codeSnippet': codeSnippet,
      'executionId': executionId,
      'errorSummary': errorSummary,
      'errorTraceback': errorTraceback,
      'type': type.name,
    };
  }

  factory MessageContext.fromJson(Map<String, dynamic> json) {
    return MessageContext(
      id: json['id'] as String,
      messageId: json['messageId'] as String?,
      projectId: json['projectId'] as String,
      fileId: json['fileId'] as String?,
      fileName: json['fileName'] as String?,
      lineStart: json['lineStart'] as int?,
      lineEnd: json['lineEnd'] as int?,
      codeSnippet: json['codeSnippet'] as String?,
      executionId: json['executionId'] as String?,
      errorSummary: json['errorSummary'] as String?,
      errorTraceback: json['errorTraceback'] as String?,
      type: MessageContextType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageContextType.fileSnippet,
      ),
    );
  }
}
