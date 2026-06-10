import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/project_model.dart';

class ProjectRepository {
  static const String _projectsKey = 'local_projects';
  static const _uuid = Uuid();

  Future<List<ProjectModel>> getProjects(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final projectsJson = prefs.getString('${_projectsKey}_$userId');
      if (projectsJson == null) return [];

      final List<dynamic> projectsList = jsonDecode(projectsJson) as List<dynamic>;
      return projectsList
          .map((p) => ProjectModel.fromJson(p as Map<String, dynamic>))
          .where((p) => p.userId == userId)
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (e) {
      return [];
    }
  }

  Future<ProjectModel?> getProject(String projectId, String userId) async {
    final projects = await getProjects(userId);
    try {
      return projects.firstWhere((p) => p.id == projectId);
    } catch (e) {
      return null;
    }
  }

  Future<ProjectModel> createProject(ProjectModel project) async {
    try {
      final newProject = ProjectModel(
        id: _uuid.v4(),
        userId: project.userId,
        name: project.name,
        country: project.country,
        city: project.city,
        plotLength: project.plotLength,
        plotWidth: project.plotWidth,
        unit: project.unit,
        floors: project.floors,
        bedrooms: project.bedrooms,
        bathrooms: project.bathrooms,
        hasKitchen: project.hasKitchen,
        hasLivingRoom: project.hasLivingRoom,
        hasGarage: project.hasGarage,
        hasGarden: project.hasGarden,
        hasBalcony: project.hasBalcony,
        houseStyle: project.houseStyle,
        constructionQuality: project.constructionQuality,
        status: ProjectStatus.draft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _saveProject(newProject);
      return newProject;
    } catch (e) {
      throw Exception('Failed to create project: $e');
    }
  }

  Future<ProjectModel> updateProject(ProjectModel project) async {
    try {
      final updatedProject = project.copyWith(updatedAt: DateTime.now());
      await _saveProject(updatedProject);
      return updatedProject;
    } catch (e) {
      throw Exception('Failed to update project: $e');
    }
  }

  Future<void> deleteProject(String projectId, String userId) async {
    try {
      final projects = await getProjects(userId);
      final updatedProjects = projects.where((p) => p.id != projectId).toList();
      await _saveProjects(updatedProjects, userId);
    } catch (e) {
      throw Exception('Failed to delete project: $e');
    }
  }

  Future<ProjectModel> duplicateProject(String projectId, String userId) async {
    final project = await getProject(projectId, userId);
    if (project == null) throw Exception('Project not found');

    final duplicate = ProjectModel(
      id: _uuid.v4(),
      userId: userId,
      name: '${project.name} (Copy)',
      country: project.country,
      city: project.city,
      plotLength: project.plotLength,
      plotWidth: project.plotWidth,
      unit: project.unit,
      floors: project.floors,
      bedrooms: project.bedrooms,
      bathrooms: project.bathrooms,
      hasKitchen: project.hasKitchen,
      hasLivingRoom: project.hasLivingRoom,
      hasGarage: project.hasGarage,
      hasGarden: project.hasGarden,
      hasBalcony: project.hasBalcony,
      houseStyle: project.houseStyle,
      constructionQuality: project.constructionQuality,
      status: ProjectStatus.draft,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _saveProject(duplicate);
    return duplicate;
  }

  Future<void> updateProjectStatus(
    String projectId,
    String userId,
    ProjectStatus status,
  ) async {
    final project = await getProject(projectId, userId);
    if (project == null) return;
    await updateProject(project.copyWith(status: status));
  }

  Future<void> _saveProject(ProjectModel project) async {
    final projects = await getProjects(project.userId);
    final existingIndex = projects.indexWhere((p) => p.id == project.id);

    if (existingIndex >= 0) {
      projects[existingIndex] = project;
    } else {
      projects.insert(0, project);
    }

    await _saveProjects(projects, project.userId);
  }

  Future<void> _saveProjects(List<ProjectModel> projects, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final projectsJson = jsonEncode(projects.map((p) => p.toJson()).toList());
    await prefs.setString('${_projectsKey}_$userId', projectsJson);
  }

  Future<List<ProjectModel>> searchProjects(String userId, String query) async {
    final projects = await getProjects(userId);
    if (query.isEmpty) return projects;

    final lowerQuery = query.toLowerCase();
    return projects.where((p) {
      return p.name.toLowerCase().contains(lowerQuery) ||
          p.city.toLowerCase().contains(lowerQuery) ||
          p.country.toLowerCase().contains(lowerQuery) ||
          p.houseStyle.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
