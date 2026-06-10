import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/project_model.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail / Header
            Container(
              height: 130,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                gradient: LinearGradient(
                  colors: _getGradientColors(project.houseStyle),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // Background pattern
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: CustomPaint(
                        painter: _HousePainter(project),
                      ),
                    ),
                  ),

                  // Status badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _buildStatusBadge(project.status),
                  ),

                  // Floor info
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Row(
                      children: [
                        _infoChip(Icons.layers_rounded, '${project.floors}F'),
                        const SizedBox(width: 6),
                        _infoChip(Icons.bed_rounded, '${project.bedrooms}B'),
                        const SizedBox(width: 6),
                        _infoChip(Icons.bathtub_rounded, '${project.bathrooms}Ba'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          project.name,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildPopupMenu(context),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          project.locationDisplay,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          project.sizeDisplay,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          project.houseStyle,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatDate(project.updatedAt),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ProjectStatus status) {
    final Map<ProjectStatus, Color> colors = {
      ProjectStatus.completed: AppColors.success,
      ProjectStatus.generating: AppColors.warning,
      ProjectStatus.draft: Colors.grey,
      ProjectStatus.error: AppColors.error,
    };

    final Map<ProjectStatus, IconData> icons = {
      ProjectStatus.completed: Icons.check_circle_rounded,
      ProjectStatus.generating: Icons.pending_rounded,
      ProjectStatus.draft: Icons.edit_rounded,
      ProjectStatus.error: Icons.error_rounded,
    };

    final color = colors[status] ?? Colors.grey;
    final icon = icons[status] ?? Icons.circle;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            _statusLabel(status),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Colors.white),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'duplicate', child: Row(children: [Icon(Icons.copy_rounded, size: 16), SizedBox(width: 8), Text('Duplicate')])),
        const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error), SizedBox(width: 8), Text('Delete', style: TextStyle(color: AppColors.error))])),
      ],
      onSelected: (value) {
        if (value == 'delete') onDelete?.call();
        if (value == 'duplicate') onDuplicate?.call();
      },
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }

  List<Color> _getGradientColors(String style) {
    final gradients = {
      'modern': [const Color(0xFF1A3A6B), const Color(0xFF2D5BE3)],
      'contemporary': [const Color(0xFF0E4D3D), const Color(0xFF1B8A6B)],
      'traditional': [const Color(0xFF6B3A1A), const Color(0xFFB0692A)],
      'colonial': [const Color(0xFF3A1A6B), const Color(0xFF6B3AB5)],
      'mediterranean': [const Color(0xFF6B4A1A), const Color(0xFFD4822A)],
      'craftsman': [const Color(0xFF2A5A1A), const Color(0xFF5AA82A)],
      'ranch': [const Color(0xFF6B1A2A), const Color(0xFFB52A4A)],
      'victorian': [const Color(0xFF1A506B), const Color(0xFF2A8AB5)],
    };
    return gradients[style] ?? [const Color(0xFF1A3A6B), const Color(0xFF2D5BE3)];
  }

  String _statusLabel(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.completed:
        return 'Done';
      case ProjectStatus.generating:
        return 'Generating';
      case ProjectStatus.draft:
        return 'Draft';
      case ProjectStatus.error:
        return 'Error';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _HousePainter extends CustomPainter {
  final ProjectModel project;

  _HousePainter(this.project);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw simplified house floor plan
    final w = size.width;
    final h = size.height;
    final scale = w / 10;

    // Outer boundary
    canvas.drawRect(
      Rect.fromLTWH(scale, scale, w - 2 * scale, h - 2 * scale),
      paint,
    );

    // Interior walls
    canvas.drawLine(
      Offset(w * 0.45, scale),
      Offset(w * 0.45, h * 0.65),
      paint,
    );
    canvas.drawLine(
      Offset(scale, h * 0.5),
      Offset(w - scale, h * 0.5),
      paint,
    );

    // Rooms with fill
    final fillPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(scale, scale, (w - 2 * scale) * 0.45, (h - 2 * scale) * 0.5),
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
