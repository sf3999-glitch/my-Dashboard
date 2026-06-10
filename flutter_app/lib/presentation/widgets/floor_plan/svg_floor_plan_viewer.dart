import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/floor_plan_model.dart';

class SvgFloorPlanViewer extends StatefulWidget {
  final FloorPlanModel floorPlan;

  const SvgFloorPlanViewer({super.key, required this.floorPlan});

  @override
  State<SvgFloorPlanViewer> createState() => _SvgFloorPlanViewerState();
}

class _SvgFloorPlanViewerState extends State<SvgFloorPlanViewer> {
  final TransformationController _transformController = TransformationController();
  int _selectedFloor = 0;
  bool _showLabels = true;

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _resetView() {
    _transformController.value = Matrix4.identity();
  }

  void _zoomIn() {
    final Matrix4 newMatrix = _transformController.value.clone()..scale(1.2);
    _transformController.value = newMatrix;
  }

  void _zoomOut() {
    final Matrix4 newMatrix = _transformController.value.clone()..scale(0.8);
    _transformController.value = newMatrix;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final floorPlan = widget.floorPlan;

    return Column(
      children: [
        // Floor selector
        if (floorPlan.totalFloors > 1)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(floorPlan.totalFloors, (i) {
                  final isSelected = _selectedFloor == i;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(floorPlan.floorLabels[i]),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedFloor = i),
                      backgroundColor: colorScheme.surfaceVariant,
                      selectedColor: colorScheme.primaryContainer,
                      checkmarkColor: colorScheme.primary,
                      labelStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

        // SVG viewer
        Expanded(
          child: Stack(
            children: [
              Container(
                color: colorScheme.surfaceVariant,
                child: InteractiveViewer(
                  transformationController: _transformController,
                  minScale: 0.3,
                  maxScale: 5.0,
                  constrained: false,
                  child: _buildFloorPlanView(context, colorScheme),
                ),
              ),

              // Controls
              Positioned(
                right: 16,
                bottom: 24,
                child: Column(
                  children: [
                    _controlButton(
                      icon: Icons.zoom_in_rounded,
                      onTap: _zoomIn,
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(height: 8),
                    _controlButton(
                      icon: Icons.zoom_out_rounded,
                      onTap: _zoomOut,
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(height: 8),
                    _controlButton(
                      icon: Icons.center_focus_strong_rounded,
                      onTap: _resetView,
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(height: 8),
                    _controlButton(
                      icon: _showLabels ? Icons.label_rounded : Icons.label_off_rounded,
                      onTap: () => setState(() => _showLabels = !_showLabels),
                      colorScheme: colorScheme,
                    ),
                  ],
                ),
              ),

              // Legend
              Positioned(
                left: 16,
                bottom: 16,
                child: _buildLegend(context, colorScheme),
              ),
            ],
          ),
        ),

        // Stats bar
        _buildStatsBar(context, floorPlan, colorScheme),
      ],
    );
  }

  Widget _buildFloorPlanView(BuildContext context, ColorScheme colorScheme) {
    final svgData = widget.floorPlan.svgData;

    if (svgData != null && svgData.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SvgPicture.string(
            svgData,
            fit: BoxFit.contain,
            width: MediaQuery.of(context).size.width * 1.5,
          ),
        ),
      );
    }

    // Fallback: Custom drawn floor plan
    return _buildCustomFloorPlan(context, colorScheme);
  }

  Widget _buildCustomFloorPlan(BuildContext context, ColorScheme colorScheme) {
    final rooms = widget.floorPlan.getRoomsForFloor(_selectedFloor);
    const scale = 30.0;

    if (rooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.architecture_outlined, size: 64, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            const Text('No rooms to display'),
          ],
        ),
      );
    }

    // Calculate bounds
    double maxX = 0, maxY = 0;
    for (final room in rooms) {
      if (room.x + room.width > maxX) maxX = room.x + room.width;
      if (room.y + room.height > maxY) maxY = room.y + room.height;
    }

    return Container(
      margin: const EdgeInsets.all(24),
      width: (maxX + 2) * scale,
      height: (maxY + 2) * scale,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Grid background
          CustomPaint(
            size: Size((maxX + 2) * scale, (maxY + 2) * scale),
            painter: _GridPainter(scale: scale),
          ),

          // Rooms
          ...rooms.map((room) {
            return Positioned(
              left: (room.x + 1) * scale,
              top: (room.y + 1) * scale,
              width: room.width * scale,
              height: room.height * scale,
              child: _buildRoomWidget(room, scale, colorScheme),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRoomWidget(Room room, double scale, ColorScheme colorScheme) {
    final Map<RoomType, Color> roomColors = {
      RoomType.livingRoom: const Color(0xFFE3F2FD),
      RoomType.bedroom: const Color(0xFFE8F5E9),
      RoomType.kitchen: const Color(0xFFFFF9C4),
      RoomType.bathroom: const Color(0xFFEDE7F6),
      RoomType.garage: const Color(0xFFF3E5F5),
      RoomType.garden: const Color(0xFFE0F2F1),
      RoomType.balcony: const Color(0xFFFFF3E0),
      RoomType.other: const Color(0xFFF5F5F5),
    };

    final Map<RoomType, Color> borderColors = {
      RoomType.livingRoom: const Color(0xFF1E88E5),
      RoomType.bedroom: const Color(0xFF43A047),
      RoomType.kitchen: const Color(0xFFFB8C00),
      RoomType.bathroom: const Color(0xFF7B1FA2),
      RoomType.garage: const Color(0xFF616161),
      RoomType.garden: const Color(0xFF00897B),
      RoomType.balcony: const Color(0xFFFF6F00),
      RoomType.other: const Color(0xFF9E9E9E),
    };

    final bgColor = roomColors[room.type] ?? const Color(0xFFF5F5F5);
    final borderColor = borderColors[room.type] ?? const Color(0xFF9E9E9E);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: 2),
      ),
      child: _showLabels
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    room.name,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: room.width * scale > 100 ? 11 : 8,
                      fontWeight: FontWeight.w700,
                      color: borderColor.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (room.width * scale > 80 && room.height * scale > 50)
                    Text(
                      '${(room.area).toStringAsFixed(0)} m²',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 8,
                        color: borderColor.withOpacity(0.7),
                      ),
                    ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _controlButton({
    required IconData icon,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: colorScheme.onSurface),
      ),
    );
  }

  Widget _buildLegend(BuildContext context, ColorScheme colorScheme) {
    final entries = [
      (const Color(0xFF1E88E5), 'Living Room'),
      (const Color(0xFF43A047), 'Bedroom'),
      (const Color(0xFFFB8C00), 'Kitchen'),
      (const Color(0xFF7B1FA2), 'Bathroom'),
    ];

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: entries.map((e) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: e.$1, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(e.$2, style: const TextStyle(fontFamily: 'Poppins', fontSize: 10)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatsBar(BuildContext context, FloorPlanModel floorPlan, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outline, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('Total Area', '${floorPlan.totalArea.toStringAsFixed(0)} m²', Icons.square_foot_rounded, colorScheme),
          Container(width: 1, height: 40, color: colorScheme.outline),
          _statItem('Built Area', '${floorPlan.builtUpArea.toStringAsFixed(0)} m²', Icons.home_rounded, colorScheme),
          Container(width: 1, height: 40, color: colorScheme.outline),
          _statItem('Rooms', '${floorPlan.rooms.length}', Icons.meeting_room_rounded, colorScheme),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon, ColorScheme colorScheme) {
    return Column(
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 14, color: colorScheme.onSurface)),
        Text(label, style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  final double scale;

  _GridPainter({required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE0E6EF)
      ..strokeWidth = 0.5;

    for (double x = 0; x <= size.width; x += scale) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += scale) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
