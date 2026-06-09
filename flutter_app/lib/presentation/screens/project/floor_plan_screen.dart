import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../providers/project_provider.dart';

class FloorPlanScreen extends ConsumerStatefulWidget {
  final String projectId;
  const FloorPlanScreen({super.key, required this.projectId});

  @override
  ConsumerState<FloorPlanScreen> createState() => _FloorPlanScreenState();
}

class _FloorPlanScreenState extends ConsumerState<FloorPlanScreen> {
  final _transformController = TransformationController();
  int _selectedFloor = 1;

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transformController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    final projectsState = ref.watch(projectsProvider);
    final project = projectsState.projects.where((p) => p.id == widget.projectId).firstOrNull;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(project?.name ?? 'Floor Plan'),
        actions: [
          IconButton(icon: const Icon(Icons.zoom_out_map), onPressed: _resetZoom),
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () => _downloadPDF(context, project),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Floor selector (if multi-floor)
          if ((project?.floors ?? 1) > 1) ...[
            Container(
              height: 48,
              color: colorScheme.surface,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: project?.floors ?? 1,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('Floor ${i + 1}'),
                    selected: _selectedFloor == i + 1,
                    onSelected: (_) => setState(() => _selectedFloor = i + 1),
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
          ],

          // Floor plan viewer
          Expanded(
            child: project?.floorPlanSvg != null
                ? _SVGViewer(svgData: project!.floorPlanSvg!, controller: _transformController)
                : _PlaceholderFloorPlan(project: project),
          ),

          // Bottom stats bar
          if (project != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem('Plot', '${project.plotLength ?? 0}×${project.plotWidth ?? 0} ${project.unit ?? "ft"}', Icons.straighten),
                  _StatItem('Floors', '${project.floors ?? 1}', Icons.layers_outlined),
                  _StatItem('Bedrooms', '${project.bedrooms ?? 0}', Icons.bed_outlined),
                  _StatItem('Bathrooms', '${project.bathrooms ?? 0}', Icons.bathroom_outlined),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _downloadPDF(BuildContext context, dynamic project) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preparing PDF download...'), duration: Duration(seconds: 2)),
    );
  }
}

class _SVGViewer extends StatelessWidget {
  final String svgData;
  final TransformationController controller;
  const _SVGViewer({required this.svgData, required this.controller});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: controller,
      minScale: 0.5,
      maxScale: 5.0,
      constrained: false,
      child: SvgPicture.string(
        svgData,
        fit: BoxFit.contain,
        width: MediaQuery.of(context).size.width * 1.5,
      ),
    );
  }
}

class _PlaceholderFloorPlan extends StatelessWidget {
  final dynamic project;
  const _PlaceholderFloorPlan({this.project});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surfaceVariant.withOpacity(0.2),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.architecture, size: 80, color: colorScheme.onSurfaceVariant.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text('No Floor Plan Yet', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text('Generate your plan to view the floor layout.', style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatItem(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
    ],
  );
}
