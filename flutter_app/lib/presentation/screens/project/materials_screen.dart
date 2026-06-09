import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/cost_estimate_model.dart';
import '../../providers/project_provider.dart';
import '../../providers/currency_provider.dart';

class MaterialsScreen extends ConsumerStatefulWidget {
  final String projectId;

  const MaterialsScreen({super.key, required this.projectId});

  @override
  ConsumerState<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends ConsumerState<MaterialsScreen> {
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final detailState = ref.watch(projectDetailProvider);
    final currencyState = ref.watch(currencyProvider);
    final colorScheme = Theme.of(context).colorScheme;

    if (detailState.costEstimate == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.materials)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined, size: 64, color: colorScheme.onSurfaceVariant),
              const SizedBox(height: 16),
              Text(l10n.noMaterials, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      );
    }

    final materials = detailState.costEstimate!.materials;
    final byCategory = detailState.costEstimate!.materialsByCategory;
    final categories = byCategory.keys.toList();

    // Filter materials
    List<MaterialItem> filteredMaterials = materials.where((m) {
      final matchesSearch = _searchQuery.isEmpty ||
          m.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.category.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == null || m.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    final totalFiltered = filteredMaterials.fold<double>(0, (sum, m) => sum + m.totalPrice);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.materials),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {},
            tooltip: l10n.share,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                SearchBar(
                  hintText: 'Search materials...',
                  leading: const Icon(Icons.search_rounded),
                  onChanged: (q) => setState(() => _searchQuery = q),
                  backgroundColor: MaterialStatePropertyAll(colorScheme.surfaceVariant),
                  elevation: const MaterialStatePropertyAll(0),
                  shape: MaterialStatePropertyAll(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 8),
                // Category chips
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _categoryChip('All', null, colorScheme),
                      ...categories.map((c) => _categoryChip(c, c, colorScheme)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Summary bar
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredMaterials.length} materials',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Total: ${currencyState.formatAmount(totalFiltered)}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // Materials list
          Expanded(
            child: filteredMaterials.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: colorScheme.onSurfaceVariant),
                        const SizedBox(height: 12),
                        Text('No materials found', style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: filteredMaterials.length,
                    itemBuilder: (context, index) {
                      return _materialCard(context, filteredMaterials[index], currencyState, colorScheme);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(String label, String? value, ColorScheme colorScheme) {
    final isSelected = _selectedCategory == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedCategory = value),
        backgroundColor: colorScheme.surfaceVariant,
        selectedColor: colorScheme.primaryContainer,
        checkmarkColor: colorScheme.primary,
        labelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
        side: BorderSide(
          color: isSelected ? colorScheme.primary : colorScheme.outline,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }

  Widget _materialCard(
    BuildContext context,
    MaterialItem material,
    CurrencyState currencyState,
    ColorScheme colorScheme,
  ) {
    final Map<String, Color> categoryColors = {
      'Concrete & Masonry': const Color(0xFF8B4513),
      'Structural': AppColors.primaryLight,
      'Aggregates': const Color(0xFF9B6B2B),
      'Roofing': const Color(0xFF9B59B6),
      'Finishes': AppColors.accentLight,
      'Openings': const Color(0xFF4A90D9),
      'Electrical': AppColors.warning,
      'Plumbing': const Color(0xFF1ABC9C),
      'HVAC & Insulation': const Color(0xFF3498DB),
    };

    final color = categoryColors[material.category] ?? colorScheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Category color indicator
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    material.name,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      material.category,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '${material.quantity.toStringAsFixed(0)} ${material.unit}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Text(' × ', style: TextStyle(color: Colors.grey)),
                      Text(
                        currencyState.formatAmount(material.unitPrice),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyState.formatAmount(material.totalPrice),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'total',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
