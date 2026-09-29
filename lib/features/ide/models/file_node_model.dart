enum FileNodeType {
  file,
  folder,
}

class FileNodeModel {
  final String id;
  final String projectId;
  final String? parentId;
  final String name;
  final FileNodeType type;
  final String path;
  final int size;
  final int version;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isExpanded;
  final List<FileNodeModel> children;

  const FileNodeModel({
    required this.id,
    required this.projectId,
    this.parentId,
    required this.name,
    required this.type,
    required this.path,
    this.size = 0,
    this.version = 1,
    this.content = '',
    required this.createdAt,
    required this.updatedAt,
    this.isExpanded = true,
    this.children = const [],
  });

  bool get isFolder => type == FileNodeType.folder;
  bool get isPythonFile => name.endsWith('.py');
  bool get isMarkdown => name.endsWith('.md');
  bool get isJson => name.endsWith('.json');

  FileNodeModel copyWith({
    String? id,
    String? projectId,
    String? parentId,
    String? name,
    FileNodeType? type,
    String? path,
    int? size,
    int? version,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isExpanded,
    List<FileNodeModel>? children,
  }) {
    return FileNodeModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      type: type ?? this.type,
      path: path ?? this.path,
      size: size ?? this.size,
      version: version ?? this.version,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isExpanded: isExpanded ?? this.isExpanded,
      children: children ?? this.children,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'parentId': parentId,
      'name': name,
      'type': type.name,
      'path': path,
      'size': size,
      'version': version,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isExpanded': isExpanded,
      'children': children.map((c) => c.toJson()).toList(),
    };
  }

  factory FileNodeModel.fromJson(Map<String, dynamic> json) {
    return FileNodeModel(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      parentId: json['parentId'] as String?,
      name: json['name'] as String,
      type: json['type'] == 'folder' ? FileNodeType.folder : FileNodeType.file,
      path: json['path'] as String,
      size: json['size'] as int? ?? 0,
      version: json['version'] as int? ?? 1,
      content: json['content'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isExpanded: json['isExpanded'] as bool? ?? true,
      children: (json['children'] as List<dynamic>?)
              ?.map((c) => FileNodeModel.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
