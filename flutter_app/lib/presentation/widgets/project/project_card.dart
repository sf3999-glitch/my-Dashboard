import 'package:flutter/material.dart';
import '../../../data/models/project_model.dart';
import '../../../core/utils/formatters.dart';

class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    this.onDelete,
    this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header / Thumbnail
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _getGradient(project.houseStyle),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(Icons.home_work_rounded, size: 56, color: Colors.white.withOpacity(0.3)),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: Colors.white.withOpacity(0.8)),
                        onSelected: (v) {
                          if (v == 'delete' && onDelete != null) onDelete!();
                          if (v == 'duplicate' && onDuplicate != null) onDuplicate!();
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'duplicate', child: Row(children: [Icon(Icons.copy, size: 18), SizedBox(width: 8), Text('Duplicate')])),
                          const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(project.status).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getStatusLabel(project.status),
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 12, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            '${project.city ?? ''} ${project.country ?? ''}'.trim(),
                            style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        _InfoChip(icon: Icons.layers_outlined, label: '${project.floors ?? 1}F'),
                        const SizedBox(width: 6),
                        _InfoChip(icon: Icons.bed_outlined, label: '${project.bedrooms ?? 0}B'),
                        const Spacer(),
                        Text(
                          Formatters.relativeDate(project.updatedAt ?? project.createdAt ?? DateTime.now()),
                          style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getGradient(String? style) {
    switch (style?.toLowerCase()) {
      case 'modern': return [const Color(0xFF1565C0), const Color(0xFF1976D2)];
      case 'contemporary': return [const Color(0xFF00695C), const Color(0xFF00897B)];
      case 'traditional': return [const Color(0xFF6A1B9A), const Color(0xFF8E24AA)];
      case 'colonial': return [const Color(0xFF4E342E), const Color(0xFF6D4C41)];
      case 'mediterranean': return [const Color(0xFFE65100), const Color(0xFFF4511E)];
      case 'minimalist': return [const Color(0xFF37474F), const Color(0xFF546E7A)];
      default: return [const Color(0xFF1565C0), const Color(0xFF0D47A1)];
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'completed': return Colors.green;
      case 'shared': return Colors.blue;
      default: return Colors.orange;
    }
  }

  String _getStatusLabel(String? status) {
    switch (status) {
      case 'completed': return 'Completed';
      case 'shared': return 'Shared';
      default: return 'Draft';
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 2),
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
