enum ProjectVisibility {
  privateProject,
  publicProject,
}

enum ProjectExecutionStatus {
  idle,
  running,
  success,
  failed,
}

class ProjectModel {
  final String id;
  final String ownerId;
  final String name;
  final String description;
  final String language;
  final ProjectVisibility visibility;
  final ProjectExecutionStatus lastExecutionStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int fileCount;
  final String defaultFile;

  const ProjectModel({
    required this.id,
    required this.ownerId,
    required this.name,
    this.description = '',
    this.language = 'python',
    this.visibility = ProjectVisibility.privateProject,
    this.lastExecutionStatus = ProjectExecutionStatus.idle,
    required this.createdAt,
    required this.updatedAt,
    this.fileCount = 1,
    this.defaultFile = 'main.py',
  });

  ProjectModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? description,
    String? language,
    ProjectVisibility? visibility,
    ProjectExecutionStatus? lastExecutionStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? fileCount,
    String? defaultFile,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      language: language ?? this.language,
      visibility: visibility ?? this.visibility,
      lastExecutionStatus: lastExecutionStatus ?? this.lastExecutionStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fileCount: fileCount ?? this.fileCount,
      defaultFile: defaultFile ?? this.defaultFile,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'description': description,
      'language': language,
      'visibility': visibility.name,
      'lastExecutionStatus': lastExecutionStatus.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'fileCount': fileCount,
      'defaultFile': defaultFile,
    };
  }

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      language: json['language'] as String? ?? 'python',
      visibility: json['visibility'] == 'publicProject'
          ? ProjectVisibility.publicProject
          : ProjectVisibility.privateProject,
      lastExecutionStatus: ProjectExecutionStatus.values.firstWhere(
        (e) => e.name == json['lastExecutionStatus'],
        orElse: () => ProjectExecutionStatus.idle,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      fileCount: json['fileCount'] as int? ?? 1,
      defaultFile: json['defaultFile'] as String? ?? 'main.py',
    );
  }
}
