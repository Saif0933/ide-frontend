import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../../../core/network/mock_backend_service.dart';
import 'package:frontend/features/ide/services/file_import_service.dart';

class ProjectController extends ChangeNotifier {
  final MockBackendService _backendService = MockBackendService();

  List<ProjectModel> _projects = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedFilter = 'all'; // 'all', 'python', 'recent'

  List<ProjectModel> get projects {
    if (_searchQuery.trim().isEmpty) {
      return _projects;
    }
    final query = _searchQuery.toLowerCase();
    return _projects.where((p) {
      return p.name.toLowerCase().contains(query) ||
          p.description.toLowerCase().contains(query);
    }).toList();
  }

  List<ProjectModel> get recentProjects => _projects.take(5).toList();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedFilter => _selectedFilter;

  Future<void> fetchProjects() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _projects = await _backendService.getProjects();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  Future<ProjectModel?> createProjectFromFileManager({bool pickFolder = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<ImportedFileItem> items;
      if (pickFolder) {
        items = await FileImportService.pickExternalDirectory();
      } else {
        items = await FileImportService.pickExternalFiles();
      }

      if (items.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return null;
      }

      final firstItem = items.first;
      String projectName = firstItem.name;
      if (!firstItem.isFolder && projectName.contains('.')) {
        projectName = projectName.substring(0, projectName.lastIndexOf('.'));
      }
      if (projectName.trim().isEmpty) {
        projectName = 'Device Project';
      }

      final newProj = await _backendService.createProjectWithFiles(
        name: projectName,
        description: 'Imported from ${pickFolder ? "folder" : "file"} on device',
        importedFiles: items,
      );

      _projects.insert(0, newProj);
      _isLoading = false;
      notifyListeners();
      return newProj;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<ProjectModel?> createProject({
    required String name,
    String description = '',
    String templateId = 'empty_python',
    ProjectVisibility visibility = ProjectVisibility.privateProject,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newProj = await _backendService.createProject(
        name: name,
        description: description,
        templateId: templateId,
        visibility: visibility,
      );
      _projects.insert(0, newProj);
      _isLoading = false;
      notifyListeners();
      return newProj;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> deleteProject(String projectId) async {
    try {
      await _backendService.deleteProject(projectId);
      _projects.removeWhere((p) => p.id == projectId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
