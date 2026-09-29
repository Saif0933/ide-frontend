class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException(this.message, {this.code, this.details});

  @override
  String toString() => 'AppException: $message (Code: $code)';
}

class NetworkException extends AppException {
  NetworkException(super.message, {super.code, super.details});
}

class AuthException extends AppException {
  AuthException(super.message, {super.code, super.details});
}

class ExecutionException extends AppException {
  final int? exitCode;
  final String? stderr;

  ExecutionException(super.message, {super.code, this.exitCode, this.stderr});
}

class ValidationException extends AppException {
  ValidationException(super.message, {super.code, super.details});
}

class FileConflictException extends AppException {
  final int serverRevision;
  final int localRevision;

  FileConflictException(
    super.message, {
    required this.serverRevision,
    required this.localRevision,
  }) : super(code: 'FILE_CONFLICT');
}
