import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/floor_plan_model.dart';
import '../../providers/project_provider.dart';
import '../../widgets/floor_plan/svg_floor_plan_viewer.dart';

class FloorPlanScreen extends ConsumerWidget {
  final String projectId;

  const FloorPlanScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final detailState = ref.watch(projectDetailProvider);
    final colorScheme = Theme.of(context).colorScheme;

    if (detailState.floorPlan == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.floorPlan),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.architecture_outlined, size: 64, color: colorScheme.onSurfaceVariant),
              const SizedBox(height: 16),
              Text('No floor plan available', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.floorPlan),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () => _downloadFloorPlan(context, detailState.floorPlan!),
            tooltip: l10n.download,
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {},
            tooltip: l10n.share,
          ),
        ],
      ),
      body: SvgFloorPlanViewer(floorPlan: detailState.floorPlan!),
    );
  }

  void _downloadFloorPlan(BuildContext context, FloorPlanModel floorPlan) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Floor plan download started...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
