enum ProjectStatus { draft, generating, completed, error }

class ProjectModel {
  final String id;
  final String userId;
  final String name;
  final String country;
  final String city;
  final double plotLength;
  final double plotWidth;
  final String unit; // 'feet' or 'meter'
  final int floors;
  final int bedrooms;
  final int bathrooms;
  final bool hasKitchen;
  final bool hasLivingRoom;
  final bool hasGarage;
  final bool hasGarden;
  final bool hasBalcony;
  final String houseStyle;
  final String constructionQuality;
  final ProjectStatus status;
  final String? thumbnailUrl;
  final String? floorPlanId;
  final String? costEstimateId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  const ProjectModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.country,
    required this.city,
    required this.plotLength,
    required this.plotWidth,
    required this.unit,
    required this.floors,
    required this.bedrooms,
    required this.bathrooms,
    required this.hasKitchen,
    required this.hasLivingRoom,
    required this.hasGarage,
    required this.hasGarden,
    required this.hasBalcony,
    required this.houseStyle,
    required this.constructionQuality,
    this.status = ProjectStatus.draft,
    this.thumbnailUrl,
    this.floorPlanId,
    this.costEstimateId,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      country: json['country'] as String,
      city: json['city'] as String,
      plotLength: (json['plot_length'] as num).toDouble(),
      plotWidth: (json['plot_width'] as num).toDouble(),
      unit: json['unit'] as String? ?? 'feet',
      floors: json['floors'] as int? ?? 1,
      bedrooms: json['bedrooms'] as int? ?? 3,
      bathrooms: json['bathrooms'] as int? ?? 2,
      hasKitchen: json['has_kitchen'] as bool? ?? true,
      hasLivingRoom: json['has_living_room'] as bool? ?? true,
      hasGarage: json['has_garage'] as bool? ?? false,
      hasGarden: json['has_garden'] as bool? ?? false,
      hasBalcony: json['has_balcony'] as bool? ?? false,
      houseStyle: json['house_style'] as String? ?? 'modern',
      constructionQuality: json['construction_quality'] as String? ?? 'standard',
      status: ProjectStatus.values.firstWhere(
        (s) => s.name == (json['status'] as String? ?? 'draft'),
        orElse: () => ProjectStatus.draft,
      ),
      thumbnailUrl: json['thumbnail_url'] as String?,
      floorPlanId: json['floor_plan_id'] as String?,
      costEstimateId: json['cost_estimate_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'country': country,
      'city': city,
      'plot_length': plotLength,
      'plot_width': plotWidth,
      'unit': unit,
      'floors': floors,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'has_kitchen': hasKitchen,
      'has_living_room': hasLivingRoom,
      'has_garage': hasGarage,
      'has_garden': hasGarden,
      'has_balcony': hasBalcony,
      'house_style': houseStyle,
      'construction_quality': constructionQuality,
      'status': status.name,
      'thumbnail_url': thumbnailUrl,
      'floor_plan_id': floorPlanId,
      'cost_estimate_id': costEstimateId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  ProjectModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? country,
    String? city,
    double? plotLength,
    double? plotWidth,
    String? unit,
    int? floors,
    int? bedrooms,
    int? bathrooms,
    bool? hasKitchen,
    bool? hasLivingRoom,
    bool? hasGarage,
    bool? hasGarden,
    bool? hasBalcony,
    String? houseStyle,
    String? constructionQuality,
    ProjectStatus? status,
    String? thumbnailUrl,
    String? floorPlanId,
    String? costEstimateId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      country: country ?? this.country,
      city: city ?? this.city,
      plotLength: plotLength ?? this.plotLength,
      plotWidth: plotWidth ?? this.plotWidth,
      unit: unit ?? this.unit,
      floors: floors ?? this.floors,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      hasKitchen: hasKitchen ?? this.hasKitchen,
      hasLivingRoom: hasLivingRoom ?? this.hasLivingRoom,
      hasGarage: hasGarage ?? this.hasGarage,
      hasGarden: hasGarden ?? this.hasGarden,
      hasBalcony: hasBalcony ?? this.hasBalcony,
      houseStyle: houseStyle ?? this.houseStyle,
      constructionQuality: constructionQuality ?? this.constructionQuality,
      status: status ?? this.status,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      floorPlanId: floorPlanId ?? this.floorPlanId,
      costEstimateId: costEstimateId ?? this.costEstimateId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  double get plotAreaInSqFt {
    if (unit == 'meter') {
      return plotLength * plotWidth * 10.764;
    }
    return plotLength * plotWidth;
  }

  double get plotAreaInSqM {
    if (unit == 'feet') {
      return plotLength * plotWidth * 0.0929;
    }
    return plotLength * plotWidth;
  }

  String get locationDisplay => '$city, $country';

  String get sizeDisplay {
    if (unit == 'feet') {
      return '${plotLength.toStringAsFixed(0)} × ${plotWidth.toStringAsFixed(0)} ft';
    }
    return '${plotLength.toStringAsFixed(0)} × ${plotWidth.toStringAsFixed(0)} m';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProjectModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
