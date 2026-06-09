import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  String? _categoryFilter;

  @override
  Widget build(BuildContext context) {
    final projectsState = ref.watch(projectsProvider);
    final project = projectsState.projects.where((p) => p.id == widget.projectId).firstOrNull;
    final currencyState = ref.watch(currencyProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final materials = (project?.materialReport as List<dynamic>?) ?? [];

    if (materials.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Materials Report')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined, size: 64, color: colorScheme.onSurfaceVariant.withOpacity(0.4)),
              const SizedBox(height: 16),
              Text('No materials report yet', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('Generate your plan to view materials list.', style: TextStyle(color: colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      );
    }

    // Get categories
    final categories = materials.map((m) => m['category'] as String? ?? 'Other').toSet().toList()..sort();

    final filtered = materials.where((m) {
      final name = m['name'] as String? ?? '';
      final category = m['category'] as String? ?? '';
      final matchSearch = _searchQuery.isEmpty || name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchCategory = _categoryFilter == null || category == _categoryFilter;
      return matchSearch && matchCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Materials Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preparing materials report PDF...'))),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search materials...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                filled: true,
                fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),

          // Category filter chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('All'),
                    selected: _categoryFilter == null,
                    onSelected: (_) => setState(() => _categoryFilter = null),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
                  ),
                ),
                ...categories.map((cat) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: _categoryFilter == cat,
                    onSelected: (_) => setState(() => _categoryFilter = cat == _categoryFilter ? null : cat),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
                  ),
                )),
              ],
            ),
          ),

          // Summary row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text('${filtered.length} items', style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                const Spacer(),
                Text('Showing for ${project?.constructionQuality ?? "standard"} quality', style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),

          // Materials list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final item = filtered[i];
                return _MaterialCard(item: item, currencyState: currencyState);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MaterialCard extends StatelessWidget {
  final dynamic item;
  final dynamic currencyState;
  const _MaterialCard({required this.item, required this.currencyState});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final category = item['category'] as String? ?? 'Other';
    final name = item['name'] as String? ?? '';
    final quantity = item['quantity'];
    final unit = item['unit'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _categoryColor(category).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_categoryIcon(category), color: _categoryColor(category), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(category, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(unit, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'structure': return Colors.blue;
      case 'roofing': return Colors.orange;
      case 'electrical': return Colors.yellow.shade800;
      case 'plumbing': return Colors.cyan;
      case 'interior': return Colors.purple;
      case 'insulation': return Colors.green;
      case 'doors & windows': return Colors.teal;
      default: return Colors.grey;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'structure': return Icons.foundation;
      case 'roofing': return Icons.roofing;
      case 'electrical': return Icons.electrical_services;
      case 'plumbing': return Icons.plumbing;
      case 'interior': return Icons.format_paint;
      case 'insulation': return Icons.layers;
      case 'doors & windows': return Icons.door_back_door_outlined;
      default: return Icons.inventory_2_outlined;
    }
  }
}
