class CostBreakdown {
  final double foundation;
  final double structure;
  final double roofing;
  final double electrical;
  final double plumbing;
  final double hvac;
  final double interior;
  final double exterior;
  final double landscaping;

  const CostBreakdown({
    required this.foundation,
    required this.structure,
    required this.roofing,
    required this.electrical,
    required this.plumbing,
    required this.hvac,
    required this.interior,
    required this.exterior,
    required this.landscaping,
  });

  double get total =>
      foundation +
      structure +
      roofing +
      electrical +
      plumbing +
      hvac +
      interior +
      exterior +
      landscaping;

  factory CostBreakdown.fromJson(Map<String, dynamic> json) {
    return CostBreakdown(
      foundation: (json['foundation'] as num).toDouble(),
      structure: (json['structure'] as num).toDouble(),
      roofing: (json['roofing'] as num).toDouble(),
      electrical: (json['electrical'] as num).toDouble(),
      plumbing: (json['plumbing'] as num).toDouble(),
      hvac: (json['hvac'] as num).toDouble(),
      interior: (json['interior'] as num).toDouble(),
      exterior: (json['exterior'] as num).toDouble(),
      landscaping: (json['landscaping'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'foundation': foundation,
      'structure': structure,
      'roofing': roofing,
      'electrical': electrical,
      'plumbing': plumbing,
      'hvac': hvac,
      'interior': interior,
      'exterior': exterior,
      'landscaping': landscaping,
    };
  }

  Map<String, double> toMap() {
    return {
      'Foundation': foundation,
      'Structure': structure,
      'Roofing': roofing,
      'Electrical': electrical,
      'Plumbing': plumbing,
      'HVAC': hvac,
      'Interior': interior,
      'Exterior': exterior,
      'Landscaping': landscaping,
    };
  }

  CostBreakdown operator *(double factor) {
    return CostBreakdown(
      foundation: foundation * factor,
      structure: structure * factor,
      roofing: roofing * factor,
      electrical: electrical * factor,
      plumbing: plumbing * factor,
      hvac: hvac * factor,
      interior: interior * factor,
      exterior: exterior * factor,
      landscaping: landscaping * factor,
    );
  }
}

class MaterialItem {
  final String id;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final double unitPrice;
  final String currency;

  const MaterialItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.currency,
  });

  double get totalPrice => quantity * unitPrice;

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      unitPrice: (json['unit_price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'unit_price': unitPrice,
      'currency': currency,
    };
  }

  MaterialItem withCurrency(String newCurrency, double rate) {
    return MaterialItem(
      id: id,
      name: name,
      category: category,
      quantity: quantity,
      unit: unit,
      unitPrice: unitPrice * rate,
      currency: newCurrency,
    );
  }
}

class CostEstimateModel {
  final String id;
  final String projectId;
  final double totalCost;
  final String currency;
  final CostBreakdown breakdown;
  final double laborCost;
  final double materialCost;
  final double contingency;
  final String timeline; // e.g., "8-12 months"
  final double areaInSqFt;
  final double areaInSqM;
  final double costPerSqFt;
  final double costPerSqM;
  final List<MaterialItem> materials;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CostEstimateModel({
    required this.id,
    required this.projectId,
    required this.totalCost,
    required this.currency,
    required this.breakdown,
    required this.laborCost,
    required this.materialCost,
    required this.contingency,
    required this.timeline,
    required this.areaInSqFt,
    required this.areaInSqM,
    required this.costPerSqFt,
    required this.costPerSqM,
    this.materials = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory CostEstimateModel.fromJson(Map<String, dynamic> json) {
    return CostEstimateModel(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      totalCost: (json['total_cost'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      breakdown: CostBreakdown.fromJson(json['breakdown'] as Map<String, dynamic>),
      laborCost: (json['labor_cost'] as num).toDouble(),
      materialCost: (json['material_cost'] as num).toDouble(),
      contingency: (json['contingency'] as num).toDouble(),
      timeline: json['timeline'] as String,
      areaInSqFt: (json['area_in_sq_ft'] as num).toDouble(),
      areaInSqM: (json['area_in_sq_m'] as num).toDouble(),
      costPerSqFt: (json['cost_per_sq_ft'] as num).toDouble(),
      costPerSqM: (json['cost_per_sq_m'] as num).toDouble(),
      materials: (json['materials'] as List<dynamic>?)
              ?.map((m) => MaterialItem.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'total_cost': totalCost,
      'currency': currency,
      'breakdown': breakdown.toJson(),
      'labor_cost': laborCost,
      'material_cost': materialCost,
      'contingency': contingency,
      'timeline': timeline,
      'area_in_sq_ft': areaInSqFt,
      'area_in_sq_m': areaInSqM,
      'cost_per_sq_ft': costPerSqFt,
      'cost_per_sq_m': costPerSqM,
      'materials': materials.map((m) => m.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  CostEstimateModel convertToCurrency(String newCurrency, double rate) {
    return CostEstimateModel(
      id: id,
      projectId: projectId,
      totalCost: totalCost * rate,
      currency: newCurrency,
      breakdown: breakdown * rate,
      laborCost: laborCost * rate,
      materialCost: materialCost * rate,
      contingency: contingency * rate,
      timeline: timeline,
      areaInSqFt: areaInSqFt,
      areaInSqM: areaInSqM,
      costPerSqFt: costPerSqFt * rate,
      costPerSqM: costPerSqM * rate,
      materials: materials.map((m) => m.withCurrency(newCurrency, rate)).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, List<MaterialItem>> get materialsByCategory {
    final grouped = <String, List<MaterialItem>>{};
    for (final material in materials) {
      grouped.putIfAbsent(material.category, () => []).add(material);
    }
    return grouped;
  }
}
