enum SyncState {
  clean,
  dirtyLocal,
  saving,
  conflict,
  saveFailed,
}

class EditorTabModel {
  final String id;
  final String fileId;
  final String title;
  final String path;
  final String initialContent;
  final String currentContent;
  final int cursorLine;
  final int cursorColumn;
  final SyncState syncState;
  final int version;

  const EditorTabModel({
    required this.id,
    required this.fileId,
    required this.title,
    required this.path,
    required this.initialContent,
    required this.currentContent,
    this.cursorLine = 1,
    this.cursorColumn = 1,
    this.syncState = SyncState.clean,
    this.version = 1,
  });

  bool get isDirty => syncState == SyncState.dirtyLocal || currentContent != initialContent;

  EditorTabModel copyWith({
    String? id,
    String? fileId,
    String? title,
    String? path,
    String? initialContent,
    String? currentContent,
    int? cursorLine,
    int? cursorColumn,
    SyncState? syncState,
    int? version,
  }) {
    return EditorTabModel(
      id: id ?? this.id,
      fileId: fileId ?? this.fileId,
      title: title ?? this.title,
      path: path ?? this.path,
      initialContent: initialContent ?? this.initialContent,
      currentContent: currentContent ?? this.currentContent,
      cursorLine: cursorLine ?? this.cursorLine,
      cursorColumn: cursorColumn ?? this.cursorColumn,
      syncState: syncState ?? this.syncState,
      version: version ?? this.version,
    );
  }
}
