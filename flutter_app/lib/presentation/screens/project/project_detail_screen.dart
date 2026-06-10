import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/project_model.dart';
import '../../providers/project_provider.dart';
import '../../providers/currency_provider.dart';
import '../../widgets/floor_plan/svg_floor_plan_viewer.dart';
import '../../widgets/charts/cost_breakdown_chart.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  ConsumerState<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _initProject();
  }

  Future<void> _initProject() async {
    final projectsState = ref.read(projectsProvider);
    final project = projectsState.projects.firstWhere(
      (p) => p.id == widget.projectId,
      orElse: () => projectsState.projects.first,
    );

    final detailNotifier = ref.read(projectDetailProvider.notifier);
    detailNotifier.setProject(project);

    if (project.status == ProjectStatus.generating ||
        (project.status == ProjectStatus.draft && projectsState.projects.any((p) => p.id == widget.projectId))) {
      await detailNotifier.generatePlan(project);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final detailState = ref.watch(projectDetailProvider);
    final colorScheme = Theme.of(context).colorScheme;

    if (detailState.isGenerating) {
      return _buildGeneratingScreen(context, l10n, detailState, colorScheme);
    }

    final project = detailState.project;
    if (project == null) {
      return Scaffold(
        appBar: AppBar(leading: BackButton()),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(context, project, colorScheme),
          _buildTabBar(context, l10n, colorScheme),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(context, l10n, project, detailState, colorScheme),
            _buildFloorPlanTab(context, l10n, detailState, colorScheme),
            _buildCostTab(context, l10n, detailState, colorScheme),
            _buildMaterialsTab(context, l10n, detailState, colorScheme),
            _buildReportTab(context, l10n, project, detailState, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratingScreen(
    BuildContext context,
    AppLocalizations l10n,
    ProjectDetailState state,
    ColorScheme colorScheme,
  ) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorScheme.background, colorScheme.primaryContainer.withOpacity(0.3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(seconds: 2),
                    builder: (context, value, child) {
                      return CircularProgressIndicator(
                        value: state.generationProgress > 0 ? state.generationProgress : null,
                        color: colorScheme.primary,
                        strokeWidth: 3,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                l10n.generatingPlan,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  state.generationStep ?? l10n.generatingPlanDesc,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: state.generationProgress,
                        backgroundColor: colorScheme.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(state.generationProgress * 100).toInt()}%',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _aiFeatureChip('Floor Plan', Icons.architecture_rounded, colorScheme),
                  _aiFeatureChip('Cost Analysis', Icons.calculate_rounded, colorScheme),
                  _aiFeatureChip('Materials', Icons.inventory_rounded, colorScheme),
                  _aiFeatureChip('Timeline', Icons.schedule_rounded, colorScheme),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _aiFeatureChip(String label, IconData icon, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(
    BuildContext context,
    ProjectModel project,
    ColorScheme colorScheme,
  ) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
        ),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          project.name,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 60),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on_rounded, size: 14, color: Colors.white.withOpacity(0.8)),
                            const SizedBox(width: 4),
                            Text(
                              project.locationDisplay,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.square_foot_rounded, size: 14, color: Colors.white.withOpacity(0.8)),
                            const SizedBox(width: 4),
                            Text(
                              project.sizeDisplay,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _statusBadge(project.status),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(ProjectStatus status) {
    final Map<ProjectStatus, Color> colors = {
      ProjectStatus.completed: AppColors.success,
      ProjectStatus.generating: AppColors.warning,
      ProjectStatus.draft: Colors.grey,
      ProjectStatus.error: AppColors.error,
    };
    final Map<ProjectStatus, String> labels = {
      ProjectStatus.completed: 'Completed',
      ProjectStatus.generating: 'Generating',
      ProjectStatus.draft: 'Draft',
      ProjectStatus.error: 'Error',
    };

    final color = colors[status] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        labels[status] ?? '',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, AppLocalizations l10n, ColorScheme colorScheme) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            fontSize: 13,
          ),
          tabs: [
            Tab(text: l10n.overview),
            Tab(text: l10n.floorPlan),
            Tab(text: l10n.costEstimate),
            Tab(text: l10n.materials),
            Tab(text: l10n.report),
          ],
        ),
        colorScheme.surface,
      ),
    );
  }

  Widget _buildOverviewTab(
    BuildContext context,
    AppLocalizations l10n,
    ProjectModel project,
    ProjectDetailState state,
    ColorScheme colorScheme,
  ) {
    final currencyState = ref.watch(currencyProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          Row(
            children: [
              Expanded(child: _overviewCard(context, Icons.square_foot_rounded, 'Plot Size', project.sizeDisplay, colorScheme.primary, colorScheme)),
              const SizedBox(width: 12),
              Expanded(child: _overviewCard(context, Icons.layers_rounded, 'Floors', '${project.floors}', const Color(0xFF9B59B6), colorScheme)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _overviewCard(context, Icons.bed_rounded, 'Bedrooms', '${project.bedrooms}', const Color(0xFF5CA85C), colorScheme)),
              const SizedBox(width: 12),
              Expanded(child: _overviewCard(context, Icons.bathtub_rounded, 'Bathrooms', '${project.bathrooms}', const Color(0xFF4A90D9), colorScheme)),
            ],
          ),

          if (state.costEstimate != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _overviewCard(
                  context,
                  Icons.attach_money_rounded,
                  'Total Cost',
                  currencyState.formatAmount(state.costEstimate!.totalCost),
                  AppColors.accentLight,
                  colorScheme,
                )),
                const SizedBox(width: 12),
                Expanded(child: _overviewCard(
                  context,
                  Icons.schedule_rounded,
                  'Timeline',
                  state.costEstimate!.timeline,
                  AppColors.warning,
                  colorScheme,
                )),
              ],
            ),
          ],

          const SizedBox(height: 24),

          // Project details
          Text('Project Details', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _detailCard(context, colorScheme, [
            _detailRow(context, 'House Style', project.houseStyle.capitalize(), colorScheme),
            _detailRow(context, 'Quality', project.constructionQuality.capitalize(), colorScheme),
            _detailRow(context, 'Country', project.country, colorScheme),
            _detailRow(context, 'City', project.city, colorScheme),
            _detailRow(context, 'Has Kitchen', project.hasKitchen ? 'Yes' : 'No', colorScheme),
            _detailRow(context, 'Living Room', project.hasLivingRoom ? 'Yes' : 'No', colorScheme),
            _detailRow(context, 'Garage', project.hasGarage ? 'Yes' : 'No', colorScheme),
            _detailRow(context, 'Garden', project.hasGarden ? 'Yes' : 'No', colorScheme),
            _detailRow(context, 'Balcony', project.hasBalcony ? 'Yes' : 'No', colorScheme),
            _detailRow(context, 'Created', _formatDate(project.createdAt), colorScheme),
          ]),

          if (state.costEstimate != null) ...[
            const SizedBox(height: 24),
            Text('Cost Summary', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: CostBreakdownChart(costEstimate: state.costEstimate!),
            ),
          ],

          const SizedBox(height: 24),

          // Quick actions
          Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _actionButton(
                context,
                Icons.architecture_rounded,
                'Floor Plan',
                () => _tabController.animateTo(1),
                colorScheme.primaryContainer,
                colorScheme.primary,
              )),
              const SizedBox(width: 12),
              Expanded(child: _actionButton(
                context,
                Icons.calculate_rounded,
                'Cost Est.',
                () => _tabController.animateTo(2),
                const Color(0xFFE8F8F0),
                AppColors.success,
              )),
              const SizedBox(width: 12),
              Expanded(child: _actionButton(
                context,
                Icons.picture_as_pdf_rounded,
                'Report',
                () => _tabController.animateTo(4),
                const Color(0xFFFFF3E0),
                AppColors.accentLight,
              )),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFloorPlanTab(
    BuildContext context,
    AppLocalizations l10n,
    ProjectDetailState state,
    ColorScheme colorScheme,
  ) {
    if (state.floorPlan == null) {
      return _emptyStateWidget(
        context,
        Icons.architecture_outlined,
        'No floor plan yet',
        colorScheme,
      );
    }

    return SvgFloorPlanViewer(floorPlan: state.floorPlan!);
  }

  Widget _buildCostTab(
    BuildContext context,
    AppLocalizations l10n,
    ProjectDetailState state,
    ColorScheme colorScheme,
  ) {
    if (state.costEstimate == null) {
      return _emptyStateWidget(
        context,
        Icons.calculate_outlined,
        'No cost estimate yet',
        colorScheme,
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Navigate to full screen
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: () => context.push('/project/${widget.projectId}/cost'),
              icon: const Icon(Icons.open_in_full_rounded),
              label: const Text('View Full Cost Report'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsTab(
    BuildContext context,
    AppLocalizations l10n,
    ProjectDetailState state,
    ColorScheme colorScheme,
  ) {
    if (state.costEstimate == null) {
      return _emptyStateWidget(
        context,
        Icons.inventory_2_outlined,
        'No materials data yet',
        colorScheme,
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: OutlinedButton.icon(
          onPressed: () => context.push('/project/${widget.projectId}/materials'),
          icon: const Icon(Icons.open_in_full_rounded),
          label: const Text('View Full Materials List'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 44),
          ),
        ),
      ),
    );
  }

  Widget _buildReportTab(
    BuildContext context,
    AppLocalizations l10n,
    ProjectModel project,
    ProjectDetailState state,
    ColorScheme colorScheme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 36),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Full Project Report',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Floor plan, cost breakdown, materials list',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.push('/project/${widget.projectId}/report'),
            icon: const Icon(Icons.download_rounded),
            label: const Text('Generate & Download Report'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _overviewCard(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }

  Widget _detailCard(
    BuildContext context,
    ColorScheme colorScheme,
    List<Widget> children,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _detailRow(
    BuildContext context,
    String label,
    String value,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
    Color bgColor,
    Color iconColor,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyStateWidget(
    BuildContext context,
    IconData icon,
    String message,
    ColorScheme colorScheme,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(message, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _TabBarDelegate(this.tabBar, this.backgroundColor);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}

extension _CapExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
