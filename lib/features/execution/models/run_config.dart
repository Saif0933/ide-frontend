class RunConfig {
  final String entryFile;
  final List<String> commandLineArgs;
  final Map<String, String> environmentVars;
  final int timeoutSeconds;
  final int memoryLimitMb;

  const RunConfig({
    required this.entryFile,
    this.commandLineArgs = const [],
    this.environmentVars = const {},
    this.timeoutSeconds = 15,
    this.memoryLimitMb = 128,
  });

  RunConfig copyWith({
    String? entryFile,
    List<String>? commandLineArgs,
    Map<String, String>? environmentVars,
    int? timeoutSeconds,
    int? memoryLimitMb,
  }) {
    return RunConfig(
      entryFile: entryFile ?? this.entryFile,
      commandLineArgs: commandLineArgs ?? this.commandLineArgs,
      environmentVars: environmentVars ?? this.environmentVars,
      timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
      memoryLimitMb: memoryLimitMb ?? this.memoryLimitMb,
    );
  }
}
