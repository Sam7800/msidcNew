import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/project.dart';
import '../../core/database/repositories/project_repository.dart';
import 'repository_providers.dart';

/// Project State
class ProjectState {
  final List<Project> projects;
  final bool isLoading;
  final String? error;
  final int? selectedCategoryId;

  const ProjectState({
    this.projects = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategoryId,
  });

  ProjectState copyWith({
    List<Project>? projects,
    bool? isLoading,
    String? error,
    int? selectedCategoryId,
  }) {
    return ProjectState(
      projects: projects ?? this.projects,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
    );
  }
}

/// Project Notifier
class ProjectNotifier extends StateNotifier<ProjectState> {
  final ProjectRepository _repository;

  ProjectNotifier(this._repository) : super(const ProjectState());

  /// Load all projects
  Future<void> loadAllProjects() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final projects = await _repository.getAllProjects();
      state = state.copyWith(
        projects: projects,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Load projects by category ID
  Future<void> loadProjectsByCategoryId(int categoryId) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      selectedCategoryId: categoryId,
    );

    try {
      final projects = await _repository.getProjectsByCategoryId(categoryId);
      state = state.copyWith(
        projects: projects,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Search projects
  Future<void> searchProjects(String query) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final projects = await _repository.searchProjects(query);
      state = state.copyWith(
        projects: projects,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Get project by ID
  Future<Project?> getProjectById(int id) async {
    try {
      return await _repository.getProjectById(id);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Add project
  Future<bool> addProject(Project project) async {
    try {
      await _repository.insertProject(project);
      await loadAllProjects(); // Reload
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Update project
  Future<bool> updateProject(Project project) async {
    try {
      await _repository.updateProject(project);
      await loadAllProjects(); // Reload
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Delete project
  Future<bool> deleteProject(int id) async {
    try {
      await _repository.deleteProject(id);
      await loadAllProjects(); // Reload
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Project Provider
final projectProvider = StateNotifierProvider<ProjectNotifier, ProjectState>((ref) {
  final repository = ref.watch(projectRepositoryProvider);
  return ProjectNotifier(repository);
});

/// Project count by category provider
final projectCountByCategoryProvider = FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.getProjectCountByCategory();
});

/// Single project provider (by ID)
final singleProjectProvider = FutureProvider.family<Project?, int>((ref, id) async {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.getProjectById(id);
});
