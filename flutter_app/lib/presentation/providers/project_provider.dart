import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/project_model.dart';
import '../../data/models/floor_plan_model.dart';
import '../../data/models/cost_estimate_model.dart';
import '../../data/repositories/project_repository.dart';
import '../../data/repositories/ai_repository.dart';
import 'auth_provider.dart';

// Repository providers
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository();
});

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepository();
});

// Projects list state
class ProjectsState {
  final List<ProjectModel> projects;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  const ProjectsState({
    this.projects = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  ProjectsState copyWith({
    List<ProjectModel>? projects,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return ProjectsState(
      projects: projects ?? this.projects,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<ProjectModel> get filteredProjects {
    if (searchQuery.isEmpty) return projects;
    final q = searchQuery.toLowerCase();
    return projects.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.city.toLowerCase().contains(q) ||
          p.country.toLowerCase().contains(q);
    }).toList();
  }
}

class ProjectsNotifier extends StateNotifier<ProjectsState> {
  final ProjectRepository _repository;
  final String _userId;

  ProjectsNotifier(this._repository, this._userId)
      : super(const ProjectsState()) {
    loadProjects();
  }

  Future<void> loadProjects() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final projects = await _repository.getProjects(_userId);
      state = state.copyWith(projects: projects, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<ProjectModel?> createProject(ProjectModel project) async {
    try {
      final newProject = await _repository.createProject(project);
      state = state.copyWith(
        projects: [newProject, ...state.projects],
      );
      return newProject;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<bool> updateProject(ProjectModel project) async {
    try {
      final updated = await _repository.updateProject(project);
      final updatedList = state.projects.map((p) {
        return p.id == updated.id ? updated : p;
      }).toList();
      state = state.copyWith(projects: updatedList);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteProject(String projectId) async {
    try {
      await _repository.deleteProject(projectId, _userId);
      state = state.copyWith(
        projects: state.projects.where((p) => p.id != projectId).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<ProjectModel?> duplicateProject(String projectId) async {
    try {
      final duplicate = await _repository.duplicateProject(projectId, _userId);
      state = state.copyWith(
        projects: [duplicate, ...state.projects],
      );
      return duplicate;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final projectsProvider =
    StateNotifierProvider<ProjectsNotifier, ProjectsState>((ref) {
  final userId = ref.watch(currentUserProvider)?.id ?? 'guest';
  return ProjectsNotifier(ref.watch(projectRepositoryProvider), userId);
});

// Single project state (for detail view)
class ProjectDetailState {
  final ProjectModel? project;
  final FloorPlanModel? floorPlan;
  final CostEstimateModel? costEstimate;
  final bool isGenerating;
  final String? generationStep;
  final String? error;
  final double generationProgress;

  const ProjectDetailState({
    this.project,
    this.floorPlan,
    this.costEstimate,
    this.isGenerating = false,
    this.generationStep,
    this.error,
    this.generationProgress = 0.0,
  });

  ProjectDetailState copyWith({
    ProjectModel? project,
    FloorPlanModel? floorPlan,
    CostEstimateModel? costEstimate,
    bool? isGenerating,
    String? generationStep,
    String? error,
    double? generationProgress,
  }) {
    return ProjectDetailState(
      project: project ?? this.project,
      floorPlan: floorPlan ?? this.floorPlan,
      costEstimate: costEstimate ?? this.costEstimate,
      isGenerating: isGenerating ?? this.isGenerating,
      generationStep: generationStep,
      error: error,
      generationProgress: generationProgress ?? this.generationProgress,
    );
  }

  bool get isComplete => floorPlan != null && costEstimate != null;
}

class ProjectDetailNotifier extends StateNotifier<ProjectDetailState> {
  final ProjectRepository _projectRepository;
  final AiRepository _aiRepository;

  ProjectDetailNotifier(this._projectRepository, this._aiRepository)
      : super(const ProjectDetailState());

  void setProject(ProjectModel project) {
    state = state.copyWith(project: project);
  }

  Future<void> generatePlan(ProjectModel project) async {
    state = state.copyWith(
      project: project,
      isGenerating: true,
      error: null,
      generationProgress: 0.0,
    );

    try {
      // Step 1: Update project status
      state = state.copyWith(
        generationStep: 'Analyzing your requirements...',
        generationProgress: 0.1,
      );
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 2: Generate floor plan
      state = state.copyWith(
        generationStep: 'Generating floor plan layout...',
        generationProgress: 0.3,
      );
      final floorPlan = await _aiRepository.generateFloorPlan(project);

      state = state.copyWith(
        floorPlan: floorPlan,
        generationStep: 'Calculating construction costs...',
        generationProgress: 0.6,
      );

      // Step 3: Generate cost estimate
      final costEstimate = await _aiRepository.generateCostEstimate(project, floorPlan);

      state = state.copyWith(
        costEstimate: costEstimate,
        generationStep: 'Finalizing your project...',
        generationProgress: 0.9,
      );

      await Future.delayed(const Duration(milliseconds: 400));

      // Update project status
      final updatedProject = project.copyWith(
        status: ProjectStatus.completed,
        updatedAt: DateTime.now(),
      );
      await _projectRepository.updateProject(updatedProject);

      state = state.copyWith(
        project: updatedProject,
        isGenerating: false,
        generationStep: null,
        generationProgress: 1.0,
      );
    } catch (e) {
      final failedProject = project.copyWith(status: ProjectStatus.error);
      await _projectRepository.updateProject(failedProject);
      state = state.copyWith(
        project: failedProject,
        isGenerating: false,
        generationStep: null,
        error: 'Failed to generate plan: ${e.toString()}',
      );
    }
  }

  void clearData() {
    state = const ProjectDetailState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final projectDetailProvider =
    StateNotifierProvider<ProjectDetailNotifier, ProjectDetailState>((ref) {
  return ProjectDetailNotifier(
    ref.watch(projectRepositoryProvider),
    ref.watch(aiRepositoryProvider),
  );
});
