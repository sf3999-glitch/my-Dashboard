import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/project_provider.dart';
import '../widgets/project/project_card.dart';
import '../widgets/common/loading_overlay.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);
    final projectsState = ref.watch(projectsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 700;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: _buildAppBar(context, l10n, user, colorScheme),
      body: RefreshIndicator(
        onRefresh: () => ref.read(projectsProvider.notifier).loadProjects(),
        child: CustomScrollView(
          slivers: [
            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: _buildSearchBar(context, l10n, colorScheme),
              ),
            ),

            // Header stats
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildStats(context, projectsState, colorScheme),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // Projects section header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.myProjects,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (projectsState.projects.isNotEmpty)
                      Text(
                        '${projectsState.filteredProjects.length} projects',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            ),

            // Projects Grid/List
            projectsState.isLoading
                ? const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : projectsState.error != null
                    ? SliverFillRemaining(
                        child: _buildErrorState(context, l10n, colorScheme),
                      )
                    : projectsState.filteredProjects.isEmpty
                        ? SliverFillRemaining(
                            child: _buildEmptyState(context, l10n, colorScheme),
                          )
                        : SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                            sliver: isWide
                                ? SliverGrid(
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: size.width > 1100 ? 3 : 2,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: 0.82,
                                    ),
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        final project = projectsState.filteredProjects[index];
                                        return ProjectCard(
                                          project: project,
                                          onTap: () => context.push(
                                            '/project/${project.id}',
                                            extra: project,
                                          ),
                                          onDelete: () => _confirmDelete(context, l10n, project.id),
                                          onDuplicate: () => _duplicateProject(project.id),
                                        );
                                      },
                                      childCount: projectsState.filteredProjects.length,
                                    ),
                                  )
                                : SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        final project = projectsState.filteredProjects[index];
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 16),
                                          child: ProjectCard(
                                            project: project,
                                            onTap: () => context.push(
                                              '/project/${project.id}',
                                              extra: project,
                                            ),
                                            onDelete: () => _confirmDelete(context, l10n, project.id),
                                            onDuplicate: () => _duplicateProject(project.id),
                                          ),
                                        );
                                      },
                                      childCount: projectsState.filteredProjects.length,
                                    ),
                                  ),
                          ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.newProject),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.newProject),
        backgroundColor: AppColors.accentLight,
        foregroundColor: Colors.white,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AppLocalizations l10n,
    dynamic user,
    ColorScheme colorScheme,
  ) {
    return AppBar(
      title: _isSearching
          ? null
          : Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.home_work_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  l10n.appName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
      actions: [
        // Settings
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => context.push(AppRoutes.settings),
          tooltip: l10n.settings,
        ),

        // User Avatar
        GestureDetector(
          onTap: () => context.push(AppRoutes.profile),
          child: Container(
            margin: const EdgeInsets.only(right: 16, left: 4),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                user?.initials ?? 'U',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    return SearchBar(
      controller: _searchController,
      hintText: '${l10n.search} projects...',
      leading: const Icon(Icons.search_rounded),
      trailing: _searchController.text.isNotEmpty
          ? [
              IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () {
                  _searchController.clear();
                  ref.read(projectsProvider.notifier).setSearchQuery('');
                  setState(() {});
                },
              )
            ]
          : null,
      onChanged: (query) {
        ref.read(projectsProvider.notifier).setSearchQuery(query);
        setState(() {});
      },
      backgroundColor: MaterialStatePropertyAll(colorScheme.surfaceVariant),
      elevation: const MaterialStatePropertyAll(0),
      shape: MaterialStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildStats(
    BuildContext context,
    ProjectsState state,
    ColorScheme colorScheme,
  ) {
    final completed = state.projects.where((p) => p.status.name == 'completed').length;
    final inProgress = state.projects.where((p) => p.status.name == 'generating').length;

    return Row(
      children: [
        _statCard(context, '${state.projects.length}', 'Total', Icons.folder_outlined, colorScheme.primary),
        const SizedBox(width: 12),
        _statCard(context, '$completed', 'Completed', Icons.check_circle_outline, AppColors.success),
        const SizedBox(width: 12),
        _statCard(context, '$inProgress', 'In Progress', Icons.pending_outlined, AppColors.warning),
      ],
    );
  }

  Widget _statCard(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.home_work_outlined,
                size: 48,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noProjects,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noProjectsDesc,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.push(AppRoutes.newProject),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.createFirstProject),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(l10n.errorGeneral, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref.read(projectsProvider.notifier).loadProjects(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AppLocalizations l10n,
    String projectId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteProject),
        content: Text(l10n.deleteProjectConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success =
          await ref.read(projectsProvider.notifier).deleteProject(projectId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.projectDeleted),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _duplicateProject(String projectId) async {
    final duplicate =
        await ref.read(projectsProvider.notifier).duplicateProject(projectId);
    if (duplicate != null && mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Project duplicated'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}
