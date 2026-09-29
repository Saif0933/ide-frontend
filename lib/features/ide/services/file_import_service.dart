import 'dart:convert';
import 'dart:io' as io;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class ImportedFileItem {
  final String name;
  final String path;
  final String content;
  final bool isFolder;
  final List<ImportedFileItem> children;

  const ImportedFileItem({
    required this.name,
    required this.path,
    required this.content,
    this.isFolder = false,
    this.children = const [],
  });
}

class FileImportService {
  static Future<List<ImportedFileItem>> pickExternalFiles() async {
    final files = await FilePicker.pickFiles(
      type: FileType.any,
    );

    if (files.isEmpty) {
      return [];
    }

    final List<ImportedFileItem> items = [];

    for (final file in files) {
      String content = '';
      try {
        final bytes = await file.readAsBytes();
        try {
          content = utf8.decode(bytes);
        } catch (_) {
          content = String.fromCharCodes(bytes);
        }
      } catch (_) {
        if (!kIsWeb && file.path != null) {
          try {
            content = await io.File(file.path!).readAsString();
          } catch (_) {
            content = '# Imported file\n';
          }
        }
      }

      items.add(
        ImportedFileItem(
          name: file.name,
          path: file.name,
          content: content,
          isFolder: false,
        ),
      );
    }

    return items;
  }

  static Future<List<ImportedFileItem>> pickExternalDirectory() async {
    if (!kIsWeb) {
      final selectedDirectory = await FilePicker.getDirectoryPath();
      if (selectedDirectory == null) return [];

      final dir = io.Directory(selectedDirectory);
      if (!await dir.exists()) return [];

      final folderName = dir.uri.pathSegments.where((s) => s.isNotEmpty).lastOrNull ?? 'imported_folder';
      final children = await _readDirectoryContents(dir, '');

      return [
        ImportedFileItem(
          name: folderName,
          path: folderName,
          content: '',
          isFolder: true,
          children: children,
        ),
      ];
    } else {
      // Fallback on web: pick multiple files
      return pickExternalFiles();
    }
  }

  static Future<List<ImportedFileItem>> _readDirectoryContents(io.Directory dir, String relativePrefix) async {
    final List<ImportedFileItem> items = [];
    try {
      final entities = dir.listSync();
      for (final entity in entities) {
        final name = entity.uri.pathSegments.where((s) => s.isNotEmpty).last;
        // Ignore hidden folders like .git, .dart_tool, __pycache__
        if (name.startsWith('.') || name == '__pycache__' || name == 'node_modules') continue;

        final relPath = relativePrefix.isEmpty ? name : '$relativePrefix/$name';

        if (entity is io.File) {
          String content = '';
          try {
            content = await entity.readAsString();
          } catch (_) {
            content = '# Binary or unreadable file\n';
          }
          items.add(
            ImportedFileItem(
              name: name,
              path: relPath,
              content: content,
              isFolder: false,
            ),
          );
        } else if (entity is io.Directory) {
          final subChildren = await _readDirectoryContents(entity, relPath);
          items.add(
            ImportedFileItem(
              name: name,
              path: relPath,
              content: '',
              isFolder: true,
              children: subChildren,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error reading directory: $e');
    }
    return items;
  }

  static Future<String?> saveFileToDevice({
    required String fileName,
    required String content,
  }) async {
    try {
      final bytes = Uint8List.fromList(utf8.encode(content));
      final resultUri = await FilePicker.saveFile(
        dialogTitle: 'Save File to Phone/Desktop',
        fileName: fileName,
        bytes: bytes,
      );
      return resultUri?.toString();
    } catch (e) {
      debugPrint('Error saving file to device: $e');
      return null;
    }
  }

  static Future<bool> saveProjectToDeviceFolder({
    required String projectName,
    required List<Map<String, String>> files,
  }) async {
    try {
      if (!kIsWeb) {
        final targetDir = await FilePicker.getDirectoryPath(
          dialogTitle: 'Select Destination Folder on Phone/Desktop',
        );
        if (targetDir == null) return false;

        final projectRoot = io.Directory('$targetDir/$projectName');
        if (!await projectRoot.exists()) {
          await projectRoot.create(recursive: true);
        }

        for (final file in files) {
          final relPath = file['path'] ?? 'main.py';
          final content = file['content'] ?? '';
          final fullFile = io.File('${projectRoot.path}/$relPath');
          final parent = fullFile.parent;
          if (!await parent.exists()) {
            await parent.create(recursive: true);
          }
          await fullFile.writeAsString(content);
        }
        return true;
      } else {
        // On Web: Save each file
        for (final file in files) {
          final relPath = file['path'] ?? 'main.py';
          final content = file['content'] ?? '';
          final fileName = relPath.contains('/') ? relPath.split('/').last : relPath;
          await saveFileToDevice(fileName: fileName, content: content);
        }
        return true;
      }
    } catch (e) {
      debugPrint('Error saving project to device: $e');
      return false;
    }
  }
}
