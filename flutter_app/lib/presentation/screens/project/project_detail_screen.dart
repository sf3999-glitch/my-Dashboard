import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/project_provider.dart';
import '../../widgets/common/custom_button.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  final String projectId;
  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  ConsumerState<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _generatePlan() async {
    setState(() => _isGenerating = true);
    // TODO: integrate with AI generation via projectDetailProvider
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) setState(() => _isGenerating = false);
  }

  @override
  Widget build(BuildContext context) {
    final projectsState = ref.watch(projectsProvider);
    final project = projectsState.projects.where((p) => p.id == widget.projectId).firstOrNull;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (project == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Project')),
        body: const Center(child: Text('Project not found')),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(project.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.primaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(child: Icon(Icons.home_work_rounded, size: 72, color: Colors.white24)),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () => context.push('/project/${widget.projectId}/report'),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {},
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.dashboard_outlined), text: 'Overview'),
                Tab(icon: Icon(Icons.architecture), text: 'Floor Plan'),
                Tab(icon: Icon(Icons.attach_money), text: 'Cost'),
                Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Materials'),
              ],
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              labelStyle: const TextStyle(fontSize: 11),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _OverviewTab(project: project, onGenerate: _generatePlan, isGenerating: _isGenerating),
            _FloorPlanTab(projectId: widget.projectId, project: project),
            _CostTab(projectId: widget.projectId, project: project),
            _MaterialsTab(projectId: widget.projectId),
          ],
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final dynamic project;
  final VoidCallback onGenerate;
  final bool isGenerating;

  const _OverviewTab({required this.project, required this.onGenerate, required this.isGenerating});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCompleted = project.status?.toString().contains('completed') ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status & Generate section
          if (!isCompleted) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.auto_awesome, size: 40, color: colorScheme.primary),
                    const SizedBox(height: 12),
                    Text('Generate AI Plan', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Let AI generate your floor plan, cost estimates, and material report.', textAlign: TextAlign.center, style: TextStyle(color: colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 16),
                    CustomButton(label: 'Generate Now', onPressed: isGenerating ? null : onGenerate, isLoading: isGenerating, icon: Icons.auto_awesome, width: double.infinity),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Project summary cards
          _SectionHeader('Project Summary'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12, runSpacing: 12,
            children: [
              _InfoCard('Location', '${project.city ?? ''} ${project.country ?? ''}'.trim(), Icons.location_on_outlined),
              _InfoCard('Plot Size', '${project.plotLength ?? 0} × ${project.plotWidth ?? 0} ${project.unit ?? "ft"}', Icons.straighten),
              _InfoCard('Floors', '${project.floors ?? 1}', Icons.layers_outlined),
              _InfoCard('Bedrooms', '${project.bedrooms ?? 0}', Icons.bed_outlined),
              _InfoCard('Bathrooms', '${project.bathrooms ?? 0}', Icons.bathroom_outlined),
              _InfoCard('Style', project.houseStyle ?? 'Modern', Icons.architecture),
              _InfoCard('Quality', project.constructionQuality ?? 'Standard', Icons.star_outline),
            ],
          ),
          const SizedBox(height: 24),

          // Amenities
          _SectionHeader('Amenities'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              if (project.hasKitchen ?? true) _AmenityChip('Kitchen', Icons.kitchen_outlined),
              if (project.hasLivingRoom ?? true) _AmenityChip('Living Room', Icons.weekend_outlined),
              if (project.hasGarage ?? false) _AmenityChip('Garage', Icons.garage_outlined),
              if (project.hasGarden ?? false) _AmenityChip('Garden', Icons.yard_outlined),
              if (project.hasBalcony ?? false) _AmenityChip('Balcony', Icons.balcony_outlined),
            ],
          ),
        ],
      ),
    );
  }
}

class _FloorPlanTab extends StatelessWidget {
  final String projectId;
  final dynamic project;
  const _FloorPlanTab({required this.projectId, required this.project});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.architecture, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text('Floor Plan', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Generate your plan to view the floor plan.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.push('/project/$projectId/floor-plan'),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open Floor Plan Viewer'),
          ),
        ],
      ),
    );
  }
}

class _CostTab extends StatelessWidget {
  final String projectId;
  final dynamic project;
  const _CostTab({required this.projectId, required this.project});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.attach_money, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text('Cost Estimate', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Generate your plan to view cost estimates.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.push('/project/$projectId/cost'),
            icon: const Icon(Icons.open_in_new),
            label: const Text('View Full Cost Report'),
          ),
        ],
      ),
    );
  }
}

class _MaterialsTab extends StatelessWidget {
  final String projectId;
  const _MaterialsTab({required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text('Materials Report', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Generate your plan to view material quantities.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.push('/project/$projectId/materials'),
            icon: const Icon(Icons.open_in_new),
            label: const Text('View Materials Report'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: Theme.of(context).textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.primary,
      letterSpacing: 0.5,
    ),
  );
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _InfoCard(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - 52) / 2,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AmenityChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _AmenityChip(this.label, this.icon);

  @override
  Widget build(BuildContext context) => Chip(
    avatar: Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
    label: Text(label, style: const TextStyle(fontSize: 12)),
    backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
    side: BorderSide.none,
    padding: const EdgeInsets.symmetric(horizontal: 4),
  );
}
