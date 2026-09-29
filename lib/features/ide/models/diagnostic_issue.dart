enum DiagnosticSeverity {
  error,
  warning,
  info,
}

class DiagnosticIssue {
  final String id;
  final String fileId;
  final String filePath;
  final int line;
  final int column;
  final String message;
  final DiagnosticSeverity severity;
  final String source; // e.g. 'Flake8', 'PyLint', 'SyntaxChecker'

  const DiagnosticIssue({
    required this.id,
    required this.fileId,
    required this.filePath,
    required this.line,
    this.column = 1,
    required this.message,
    this.severity = DiagnosticSeverity.error,
    this.source = 'Python Linter',
  });
}
