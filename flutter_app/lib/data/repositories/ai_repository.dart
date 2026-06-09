import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/project_model.dart';
import '../models/floor_plan_model.dart';
import '../models/cost_estimate_model.dart';

class AiRepository {
  static const _uuid = Uuid();
  final _random = Random();

  // Generate floor plan based on project parameters
  Future<FloorPlanModel> generateFloorPlan(ProjectModel project) async {
    // Simulate AI processing time
    await Future.delayed(const Duration(seconds: 3));

    final rooms = _generateRooms(project);
    final walls = _generateWalls(project);
    final svgData = _generateSvgData(rooms, project);

    double totalArea = project.unit == 'meter'
        ? project.plotLength * project.plotWidth
        : project.plotLength * project.plotWidth * 0.0929;

    double builtUpArea = totalArea * 0.75;

    return FloorPlanModel(
      id: _uuid.v4(),
      projectId: project.id,
      rooms: rooms,
      walls: walls,
      doors: _generateDoors(rooms),
      windows: _generateWindows(rooms),
      svgData: svgData,
      totalArea: totalArea,
      builtUpArea: builtUpArea,
      totalFloors: project.floors,
      unit: project.unit,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Generate cost estimate
  Future<CostEstimateModel> generateCostEstimate(
    ProjectModel project,
    FloorPlanModel floorPlan,
  ) async {
    await Future.delayed(const Duration(seconds: 2));

    final areaInSqFt = floorPlan.totalArea * 10.764;
    final areaInSqM = floorPlan.totalArea;

    // Base cost per sqft based on quality
    final Map<String, double> baseCostPerSqFt = {
      'basic': 85.0,
      'standard': 130.0,
      'premium': 195.0,
      'luxury': 285.0,
    };

    final double qualityMultiplier = {
      'basic': 0.7,
      'standard': 1.0,
      'premium': 1.5,
      'luxury': 2.2,
    }[project.constructionQuality] ?? 1.0;

    final costPerSqFt = baseCostPerSqFt[project.constructionQuality] ?? 130.0;
    final baseTotalCost = costPerSqFt * areaInSqFt * project.floors;

    final breakdown = CostBreakdown(
      foundation: baseTotalCost * 0.12,
      structure: baseTotalCost * 0.22,
      roofing: baseTotalCost * 0.08,
      electrical: baseTotalCost * 0.08,
      plumbing: baseTotalCost * 0.07,
      hvac: baseTotalCost * 0.06,
      interior: baseTotalCost * 0.20,
      exterior: baseTotalCost * 0.10,
      landscaping: baseTotalCost * 0.07,
    );

    final laborCost = baseTotalCost * 0.35;
    final materialCost = baseTotalCost * 0.55;
    final contingency = baseTotalCost * 0.10;
    final totalCost = baseTotalCost + contingency;

    // Generate timeline based on size and quality
    final String timeline = _estimateTimeline(areaInSqFt, project.floors);

    final materials = _generateMaterials(
      areaInSqFt: areaInSqFt,
      areaInSqM: areaInSqM,
      qualityMultiplier: qualityMultiplier,
      floors: project.floors,
    );

    return CostEstimateModel(
      id: _uuid.v4(),
      projectId: project.id,
      totalCost: totalCost,
      currency: 'USD',
      breakdown: breakdown,
      laborCost: laborCost,
      materialCost: materialCost,
      contingency: contingency,
      timeline: timeline,
      areaInSqFt: areaInSqFt,
      areaInSqM: areaInSqM,
      costPerSqFt: totalCost / areaInSqFt,
      costPerSqM: totalCost / areaInSqM,
      materials: materials,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Generate full report data
  Future<Map<String, dynamic>> generateFullReport(
    ProjectModel project,
    FloorPlanModel floorPlan,
    CostEstimateModel costEstimate,
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'project': project.toJson(),
      'floor_plan': floorPlan.toJson(),
      'cost_estimate': costEstimate.toJson(),
      'generated_at': DateTime.now().toIso8601String(),
      'report_id': _uuid.v4(),
    };
  }

  // Generate AI suggestions
  Future<List<String>> generateSuggestions(ProjectModel project) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      'Consider adding a utility room for better storage management',
      'The plot size allows for a spacious master bedroom with en-suite',
      'South-facing living room will maximize natural light',
      'Recommend double-glazed windows for energy efficiency',
      'Adding a home office could increase property value',
      'Consider open-plan kitchen and dining for modern living',
    ];
  }

  List<Room> _generateRooms(ProjectModel project) {
    final rooms = <Room>[];
    int roomId = 0;

    // Calculate dimensions based on unit
    final double scale = project.unit == 'feet' ? 0.3048 : 1.0;
    final double plotW = project.plotWidth * scale;
    final double plotL = project.plotLength * scale;

    for (int floor = 0; floor < project.floors; floor++) {
      double currentX = 0;
      double currentY = 0;
      double rowHeight = 0;

      // Living room (if present)
      if (project.hasLivingRoom) {
        final w = plotW * 0.45;
        final h = plotL * 0.35;
        rooms.add(Room(
          id: 'room_${roomId++}',
          name: 'Living Room',
          type: RoomType.livingRoom,
          x: currentX,
          y: currentY,
          width: w,
          height: h,
          floor: floor,
        ));
        currentX += w;
        rowHeight = h;
      }

      // Kitchen (if present)
      if (project.hasKitchen) {
        final w = plotW * 0.30;
        final h = plotL * 0.25;
        rooms.add(Room(
          id: 'room_${roomId++}',
          name: 'Kitchen',
          type: RoomType.kitchen,
          x: currentX,
          y: currentY,
          width: w,
          height: h,
          floor: floor,
        ));
        if (rowHeight < h) rowHeight = h;
      }

      currentX = 0;
      currentY += rowHeight + 0.1;
      rowHeight = 0;

      // Bedrooms
      final bedroomsOnFloor = floor == 0
          ? (project.bedrooms > 2 ? 1 : project.bedrooms)
          : project.bedrooms - 1;

      for (int i = 0; i < bedroomsOnFloor; i++) {
        final w = plotW / max(bedroomsOnFloor, 1);
        final h = plotL * 0.28;
        rooms.add(Room(
          id: 'room_${roomId++}',
          name: i == 0 ? 'Master Bedroom' : 'Bedroom ${i + 1}',
          type: RoomType.bedroom,
          x: currentX,
          y: currentY,
          width: w,
          height: h,
          floor: floor,
        ));
        currentX += w;
        rowHeight = h;
      }

      currentX = 0;
      currentY += rowHeight + 0.1;
      rowHeight = 0;

      // Bathrooms
      for (int i = 0; i < min(project.bathrooms, 3); i++) {
        final w = plotW / min(project.bathrooms, 3);
        final h = plotL * 0.15;
        rooms.add(Room(
          id: 'room_${roomId++}',
          name: i == 0 ? 'Master Bathroom' : 'Bathroom ${i + 1}',
          type: RoomType.bathroom,
          x: currentX,
          y: currentY,
          width: w,
          height: h,
          floor: floor,
        ));
        currentX += w;
        rowHeight = h;
      }

      // Garage (ground floor only)
      if (project.hasGarage && floor == 0) {
        currentX = 0;
        currentY += rowHeight + 0.1;
        final w = plotW * 0.35;
        final h = plotL * 0.20;
        rooms.add(Room(
          id: 'room_${roomId++}',
          name: 'Garage',
          type: RoomType.garage,
          x: currentX,
          y: currentY,
          width: w,
          height: h,
          floor: floor,
        ));
      }
    }

    return rooms;
  }

  List<WallSegment> _generateWalls(ProjectModel project) {
    final walls = <WallSegment>[];
    int wallId = 0;

    final double scale = project.unit == 'feet' ? 0.3048 : 1.0;
    final double plotW = project.plotWidth * scale;
    final double plotL = project.plotLength * scale;

    for (int floor = 0; floor < project.floors; floor++) {
      // Exterior walls
      walls.addAll([
        WallSegment(id: 'wall_${wallId++}', x1: 0, y1: 0, x2: plotW, y2: 0, floor: floor),
        WallSegment(id: 'wall_${wallId++}', x1: plotW, y1: 0, x2: plotW, y2: plotL, floor: floor),
        WallSegment(id: 'wall_${wallId++}', x1: plotW, y1: plotL, x2: 0, y2: plotL, floor: floor),
        WallSegment(id: 'wall_${wallId++}', x1: 0, y1: plotL, x2: 0, y2: 0, floor: floor),
      ]);

      // Interior walls
      walls.add(WallSegment(
        id: 'wall_${wallId++}',
        x1: plotW * 0.45,
        y1: 0,
        x2: plotW * 0.45,
        y2: plotL * 0.60,
        floor: floor,
        thickness: 0.2,
      ));
      walls.add(WallSegment(
        id: 'wall_${wallId++}',
        x1: 0,
        y1: plotL * 0.35,
        x2: plotW,
        y2: plotL * 0.35,
        floor: floor,
        thickness: 0.2,
      ));
      walls.add(WallSegment(
        id: 'wall_${wallId++}',
        x1: 0,
        y1: plotL * 0.63,
        x2: plotW,
        y2: plotL * 0.63,
        floor: floor,
        thickness: 0.2,
      ));
    }

    return walls;
  }

  List<DoorWindow> _generateDoors(List<Room> rooms) {
    final doors = <DoorWindow>[];
    int doorId = 0;

    for (final room in rooms) {
      doors.add(DoorWindow(
        id: 'door_${doorId++}',
        type: 'door',
        x: room.x + room.width * 0.4,
        y: room.y,
        width: 0.9,
        height: 2.1,
        orientation: 'horizontal',
        floor: room.floor,
      ));
    }

    return doors;
  }

  List<DoorWindow> _generateWindows(List<Room> rooms) {
    final windows = <DoorWindow>[];
    int windowId = 0;

    for (final room in rooms) {
      if (room.type == RoomType.bedroom || room.type == RoomType.livingRoom) {
        windows.add(DoorWindow(
          id: 'window_${windowId++}',
          type: 'window',
          x: room.x + room.width * 0.2,
          y: room.y,
          width: 1.2,
          height: 1.4,
          orientation: 'horizontal',
          floor: room.floor,
        ));
        windows.add(DoorWindow(
          id: 'window_${windowId++}',
          type: 'window',
          x: room.x + room.width * 0.6,
          y: room.y,
          width: 1.2,
          height: 1.4,
          orientation: 'horizontal',
          floor: room.floor,
        ));
      }
    }

    return windows;
  }

  String _generateSvgData(List<Room> rooms, ProjectModel project) {
    if (rooms.isEmpty) return '';

    const double scale = 30.0;
    final double svgWidth = (project.plotWidth + 2) * scale;
    final double svgHeight = (project.plotLength + 2) * scale;

    final buffer = StringBuffer();
    buffer.write(
        '<svg xmlns="http://www.w3.org/2000/svg" width="$svgWidth" height="$svgHeight" viewBox="0 0 $svgWidth $svgHeight">');

    // Background
    buffer.write('<rect width="$svgWidth" height="$svgHeight" fill="#F8F9FC"/>');

    // Grid
    buffer.write('<defs><pattern id="grid" width="${scale}" height="${scale}" patternUnits="userSpaceOnUse">');
    buffer.write('<path d="M ${scale} 0 L 0 0 0 ${scale}" fill="none" stroke="#E0E6EF" stroke-width="0.5"/>');
    buffer.write('</pattern></defs>');
    buffer.write('<rect width="$svgWidth" height="$svgHeight" fill="url(#grid)"/>');

    // Room colors
    final Map<RoomType, String> roomColors = {
      RoomType.livingRoom: '#E8F4F8',
      RoomType.bedroom: '#F0F8F0',
      RoomType.kitchen: '#FFF8E8',
      RoomType.bathroom: '#F0F0FF',
      RoomType.garage: '#F8F0E8',
      RoomType.garden: '#E8F8E8',
      RoomType.balcony: '#F8F8E8',
      RoomType.hallway: '#F5F5F5',
      RoomType.staircase: '#EFEFEF',
      RoomType.other: '#F8F8F8',
    };

    final Map<RoomType, String> roomBorderColors = {
      RoomType.livingRoom: '#4A90D9',
      RoomType.bedroom: '#5CA85C',
      RoomType.kitchen: '#D9A44A',
      RoomType.bathroom: '#7A7AD9',
      RoomType.garage: '#D97A4A',
      RoomType.garden: '#4AD94A',
      RoomType.balcony: '#D9D94A',
      RoomType.other: '#888888',
    };

    final floorRooms = rooms.where((r) => r.floor == 0).toList();

    for (final room in floorRooms) {
      final x = (room.x * scale) + scale;
      final y = (room.y * scale) + scale;
      final w = room.width * scale;
      final h = room.height * scale;
      final fillColor = roomColors[room.type] ?? '#F8F8F8';
      final borderColor = roomBorderColors[room.type] ?? '#888888';

      buffer.write('<rect x="$x" y="$y" width="$w" height="$h" fill="$fillColor" stroke="$borderColor" stroke-width="2" rx="2"/>');

      // Room label
      final labelX = x + w / 2;
      final labelY = y + h / 2;
      final areaText = '${(room.area).toStringAsFixed(1)} m²';
      buffer.write('<text x="$labelX" y="${labelY - 8}" text-anchor="middle" font-family="Arial, sans-serif" font-size="11" font-weight="bold" fill="#1A3A6B">${room.name}</text>');
      buffer.write('<text x="$labelX" y="${labelY + 8}" text-anchor="middle" font-family="Arial, sans-serif" font-size="9" fill="#666666">$areaText</text>');
    }

    // Compass
    buffer.write('<g transform="translate(${svgWidth - 50}, 40)">');
    buffer.write('<circle r="20" fill="white" stroke="#1A3A6B" stroke-width="2"/>');
    buffer.write('<text text-anchor="middle" y="-6" font-size="12" font-weight="bold" fill="#FF6B35">N</text>');
    buffer.write('<path d="M 0 -15 L 4 0 L 0 4 L -4 0 Z" fill="#FF6B35"/>');
    buffer.write('<path d="M 0 15 L 4 0 L 0 -4 L -4 0 Z" fill="#1A3A6B"/>');
    buffer.write('</g>');

    buffer.write('</svg>');
    return buffer.toString();
  }

  String _estimateTimeline(double areaInSqFt, int floors) {
    final totalArea = areaInSqFt * floors;
    if (totalArea < 1000) return '4-6 months';
    if (totalArea < 2000) return '6-9 months';
    if (totalArea < 3500) return '9-14 months';
    if (totalArea < 5000) return '14-20 months';
    return '20-30 months';
  }

  List<MaterialItem> _generateMaterials({
    required double areaInSqFt,
    required double areaInSqM,
    required double qualityMultiplier,
    required int floors,
  }) {
    final materials = <MaterialItem>[];
    int matId = 0;
    final totalArea = areaInSqFt * floors;
    final totalAreaM = areaInSqM * floors;

    // Cement
    materials.add(MaterialItem(
      id: 'mat_${matId++}',
      name: 'Portland Cement (50kg bags)',
      category: 'Concrete & Masonry',
      quantity: (totalArea * 0.5).roundToDouble(),
      unit: 'bags',
      unitPrice: 12.0 * qualityMultiplier,
      currency: 'USD',
    ));

    // Steel/Rebar
    materials.add(MaterialItem(
      id: 'mat_${matId++}',
      name: 'Steel Rebar (12mm)',
      category: 'Structural',
      quantity: (totalAreaM * 8.5).roundToDouble(),
      unit: 'kg',
      unitPrice: 0.85 * qualityMultiplier,
      currency: 'USD',
    ));

    // Bricks
    materials.add(MaterialItem(
      id: 'mat_${matId++}',
      name: 'Concrete Blocks (200x200x400mm)',
      category: 'Concrete & Masonry',
      quantity: (totalAreaM * 65).roundToDouble(),
      unit: 'pcs',
      unitPrice: 0.65 * qualityMultiplier,
      currency: 'USD',
    ));

    // Sand
    materials.add(MaterialItem(
      id: 'mat_${matId++}',
      name: 'River Sand',
      category: 'Aggregates',
      quantity: (totalAreaM * 0.35).roundToDouble(),
      unit: 'tons',
      unitPrice: 28.0,
      currency: 'USD',
    ));

    // Gravel
    materials.add(MaterialItem(
      id: 'mat_${matId++}',
      name: 'Crushed Stone / Gravel',
      category: 'Aggregates',
      quantity: (totalAreaM * 0.45).roundToDouble(),
      unit: 'tons',
      unitPrice: 22.0,
      currency: 'USD',
    ));

    // Concrete Ready-Mix
    materials.add(MaterialItem(
      id: 'mat_${matId++}',
      name: 'Ready-Mix Concrete (C25)',
      category: 'Concrete & Masonry',
      quantity: (totalAreaM * 0.25).roundToDouble(),
      unit: 'cu m',
      unitPrice: 110.0 * qualityMultiplier,
      currency: 'USD',
    ));

    // Roofing
    materials.add(MaterialItem(
      id: 'mat_${matId++}',
      name: 'Roofing Tiles / Shingles',
      category: 'Roofing',
      quantity: (areaInSqM * 1.15).roundToDouble(),
      unit: 'sq m',
      unitPrice: 22.0 * qualityMultiplier,
      currency: 'USD',
    ));

    // Waterproofing
    materials.add(MaterialItem(
      id: 'mat_${matId++}',
      name: 'Waterproofing Membrane',
      category: 'Roofing',
      quantity: (areaInSqM * 0.3).roundToDouble(),
      unit: 'sq m',
      unitPrice: 8.5 * qualityMultiplier,
      currency: 'USD',
    ));

    // Floor tiles
    materials.add(MaterialItem(
      id: 'mat_${matId++}',
      name: 'Ceramic Floor Tiles (600x600mm)',
      category: 'Finishes',
      quantity: (totalAreaM * 1.1).roundToDouble(),
      unit: 'sq m',
      unitPrice: 18.0 * qualityMultiplier,
      currency: 'USD',
    ));

    // Wall Tiles (bathrooms and kitchen)
    materials.add(MaterialItem(
      id: 'mat_${matId++}',
      name: 'Wall Tiles (300x600mm)',
      category: 'Finishes',
      quantity: (totalAreaM * 0.35).roundToDouble(),
      unit: 'sq m',
      unitPrice: 14.0 * qualityMultiplier,
      currency: 'USD',
    ));

    // Paint
    materials.add(MaterialItem(
      id: 'mat_${matId++}',
      name: 'Interior Emulsion Paint',
      category: 'Finishes',
      quantity: (totalAreaM * 0.5).roundToDouble(),
      unit: 'liters',
      unitPrice: 6.5 * qualityMultiplier,
      currency: 'USD',
    ));

    materials.add(MaterialItem(
      id: 'mat_${matId++}',
      name: 'Exterior Weatherproof Paint',
      category: 'Finishes',
      quantity: (areaInSqM * 0.6).roundToDouble(),
      unit: 'liters',
      unitPrice: 8.0 * qualityMultiplier,
      currency: 'USD',
    ));

    // Wood / Lumber
    materials.add(MaterialItem(
      id: 'mat_${matId++}',
      name: 'Structural Timber',
      category: 'Structural',
      quantity: (totalAreaM * 0.08).roundToDouble(),
      unit: 'cu m',
      unitPrice: 450.0 * qualityMultiplier,
      currency: 'USD',
    ));

    // Doors
    materials.add(MaterialItem(
      id: 'mat_${matId++}',
      name: 'Interior Door Sets',
      category: 'Openings',
      quantity: (totalAreaM / 15).roundToDouble() + 2,
      unit: 'pcs',
      unitPrice: 180.0 * qualityMultiplier,
      currency: 'USD',
    ));

    materials.add(MaterialItem(
      id: 'mat_${matId++}',
      name: 'Main Entrance Door',
      category: 'Openings',
      quantity: floors.toDouble(),
      unit: 'pcs',
      unitPrice: 550.0 * qualityMultiplier,
      currency: 'USD',
    ));

    // Windows
    materials.add(MaterialItem(
      id: 'mat_${matId++}',
      name: 'Double-Glazed Windows',
      category: 'Openings',
      quantity: (totalAreaM / 10).roundToDouble() + 4,
      unit: 'pcs',
      unitPrice: 220.0 * qualityMultiplier,
      currency: 'USD',
    ));

    // Electrical
    materials.add(MaterialItem(
      id: 'mat_${matId++}',
      name: 'Electrical Wiring (2.5mm²)',
      category: 'Electrical',
      quantity: (totalAreaM * 3.5).roundToDouble(),
      unit: 'meters',
      unitPrice: 1.2 * qualityMultiplier,
      currency: 'USD',
    ));

    materials.add(MaterialItem(
      id: 'mat_${matId++}',
      name: 'Circuit Breaker Panel (20-way)',
      category: 'Electrical',
      quantity: floors.toDouble(),
      unit: 'pcs',
      unitPrice: 180.0 * qualityMultiplier,
      currency: 'USD',
    ));

    materials.add(MaterialItem(
      id: 'mat_${matId++}',
      name: 'Light Fixtures & Switches',
      category: 'Electrical',
      quantity: (totalAreaM / 12).roundToDouble(),
      unit: 'sets',
      unitPrice: 45.0 * qualityMultiplier,
      currency: 'USD',
    ));

    // Plumbing
    materials.add(MaterialItem(
      id: 'mat_${matId++}',
      name: 'UPVC Plumbing Pipes',
      category: 'Plumbing',
      quantity: (totalAreaM * 2.5).roundToDouble(),
      unit: 'meters',
      unitPrice: 3.5 * qualityMultiplier,
      currency: 'USD',
    ));

    materials.add(MaterialItem(
      id: 'mat_${matId++}',
      name: 'Bathroom Fixtures Set',
      category: 'Plumbing',
      quantity: (totalAreaM / 30).roundToDouble() + 1,
      unit: 'sets',
      unitPrice: 380.0 * qualityMultiplier,
      currency: 'USD',
    ));

    materials.add(MaterialItem(
      id: 'mat_${matId++}',
      name: 'Kitchen Sink & Faucet',
      category: 'Plumbing',
      quantity: 1,
      unit: 'sets',
      unitPrice: 220.0 * qualityMultiplier,
      currency: 'USD',
    ));

    // Insulation
    materials.add(MaterialItem(
      id: 'mat_${matId++}',
      name: 'Thermal Insulation (50mm)',
      category: 'HVAC & Insulation',
      quantity: (totalAreaM * 0.8).roundToDouble(),
      unit: 'sq m',
      unitPrice: 12.0 * qualityMultiplier,
      currency: 'USD',
    ));

    return materials;
  }
}
