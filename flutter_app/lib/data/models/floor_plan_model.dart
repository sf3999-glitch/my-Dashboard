enum RoomType {
  bedroom,
  bathroom,
  kitchen,
  livingRoom,
  diningRoom,
  garage,
  garden,
  balcony,
  hallway,
  staircase,
  storage,
  utility,
  office,
  other,
}

class Room {
  final String id;
  final String name;
  final RoomType type;
  final double x;
  final double y;
  final double width;
  final double height;
  final int floor;
  final Map<String, dynamic>? properties;

  const Room({
    required this.id,
    required this.name,
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.floor = 0,
    this.properties,
  });

  double get area => width * height;

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as String,
      name: json['name'] as String,
      type: RoomType.values.firstWhere(
        (t) => t.name == (json['type'] as String),
        orElse: () => RoomType.other,
      ),
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      floor: json['floor'] as int? ?? 0,
      properties: json['properties'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'floor': floor,
      'properties': properties,
    };
  }
}

class WallSegment {
  final String id;
  final double x1;
  final double y1;
  final double x2;
  final double y2;
  final double thickness;
  final int floor;

  const WallSegment({
    required this.id,
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    this.thickness = 0.3,
    this.floor = 0,
  });

  factory WallSegment.fromJson(Map<String, dynamic> json) {
    return WallSegment(
      id: json['id'] as String,
      x1: (json['x1'] as num).toDouble(),
      y1: (json['y1'] as num).toDouble(),
      x2: (json['x2'] as num).toDouble(),
      y2: (json['y2'] as num).toDouble(),
      thickness: (json['thickness'] as num?)?.toDouble() ?? 0.3,
      floor: json['floor'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'x1': x1,
      'y1': y1,
      'x2': x2,
      'y2': y2,
      'thickness': thickness,
      'floor': floor,
    };
  }
}

class DoorWindow {
  final String id;
  final String type; // 'door' or 'window'
  final double x;
  final double y;
  final double width;
  final double height;
  final String orientation; // 'horizontal' or 'vertical'
  final int floor;

  const DoorWindow({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.orientation,
    this.floor = 0,
  });

  factory DoorWindow.fromJson(Map<String, dynamic> json) {
    return DoorWindow(
      id: json['id'] as String,
      type: json['type'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      orientation: json['orientation'] as String,
      floor: json['floor'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'orientation': orientation,
      'floor': floor,
    };
  }
}

class FloorPlanModel {
  final String id;
  final String projectId;
  final List<Room> rooms;
  final List<WallSegment> walls;
  final List<DoorWindow> doors;
  final List<DoorWindow> windows;
  final String? svgData;
  final double totalArea;
  final double builtUpArea;
  final int totalFloors;
  final String unit; // 'feet' or 'meter'
  final DateTime createdAt;
  final DateTime updatedAt;

  const FloorPlanModel({
    required this.id,
    required this.projectId,
    required this.rooms,
    required this.walls,
    required this.doors,
    required this.windows,
    this.svgData,
    required this.totalArea,
    required this.builtUpArea,
    required this.totalFloors,
    required this.unit,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FloorPlanModel.fromJson(Map<String, dynamic> json) {
    return FloorPlanModel(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      rooms: (json['rooms'] as List<dynamic>)
          .map((r) => Room.fromJson(r as Map<String, dynamic>))
          .toList(),
      walls: (json['walls'] as List<dynamic>?)
              ?.map((w) => WallSegment.fromJson(w as Map<String, dynamic>))
              .toList() ??
          [],
      doors: (json['doors'] as List<dynamic>?)
              ?.map((d) => DoorWindow.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
      windows: (json['windows'] as List<dynamic>?)
              ?.map((w) => DoorWindow.fromJson(w as Map<String, dynamic>))
              .toList() ??
          [],
      svgData: json['svg_data'] as String?,
      totalArea: (json['total_area'] as num).toDouble(),
      builtUpArea: (json['built_up_area'] as num).toDouble(),
      totalFloors: json['total_floors'] as int? ?? 1,
      unit: json['unit'] as String? ?? 'feet',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'rooms': rooms.map((r) => r.toJson()).toList(),
      'walls': walls.map((w) => w.toJson()).toList(),
      'doors': doors.map((d) => d.toJson()).toList(),
      'windows': windows.map((w) => w.toJson()).toList(),
      'svg_data': svgData,
      'total_area': totalArea,
      'built_up_area': builtUpArea,
      'total_floors': totalFloors,
      'unit': unit,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  List<Room> getRoomsForFloor(int floor) {
    return rooms.where((r) => r.floor == floor).toList();
  }

  List<String> get floorLabels {
    return List.generate(totalFloors, (i) {
      if (i == 0) return 'Ground Floor';
      if (i == 1) return '1st Floor';
      if (i == 2) return '2nd Floor';
      if (i == 3) return '3rd Floor';
      return '${i}th Floor';
    });
  }
}
