import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/project_provider.dart';
import '../../providers/currency_provider.dart';
import '../../../core/utils/formatters.dart';

class CostEstimateScreen extends ConsumerStatefulWidget {
  final String projectId;
  const CostEstimateScreen({super.key, required this.projectId});

  @override
  ConsumerState<CostEstimateScreen> createState() => _CostEstimateScreenState();
}

class _CostEstimateScreenState extends ConsumerState<CostEstimateScreen> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final projectsState = ref.watch(projectsProvider);
    final project = projectsState.projects.where((p) => p.id == widget.projectId).firstOrNull;
    final currencyState = ref.watch(currencyProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final costData = project?.costEstimate;
    final hasData = costData != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cost Estimate'),
        actions: [
          if (hasData)
            IconButton(
              icon: const Icon(Icons.download_outlined),
              onPressed: () => _downloadReport(context),
            ),
        ],
      ),
      body: !hasData
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calculate_outlined, size: 64, color: colorScheme.onSurfaceVariant.withOpacity(0.4)),
                  const SizedBox(height: 16),
                  Text('No cost estimate yet', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Generate your plan to get cost estimates.', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                ],
              ),
            )
          : _buildCostContent(context, costData, currencyState),
    );
  }

  Widget _buildCostContent(BuildContext context, dynamic costData, dynamic currencyState) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final summary = costData['summary'] ?? {};
    final breakdown = costData['breakdown'] ?? {};
    final timeline = costData['timeline'] ?? {};

    final totalCost = (summary['total_cost'] as num?)?.toDouble() ?? 0;
    final laborCost = (summary['labor_cost'] as num?)?.toDouble() ?? 0;
    final materialCost = (summary['material_cost'] as num?)?.toDouble() ?? 0;
    final contingency = (summary['contingency'] as num?)?.toDouble() ?? 0;

    final formattedTotal = currencyState.formatAmount(totalCost);

    final categoryColors = [
      Colors.blue, Colors.green, Colors.orange, Colors.purple,
      Colors.red, Colors.teal, Colors.indigo, Colors.amber,
      Colors.cyan, Colors.pink, Colors.lime, Colors.brown,
    ];

    final pieData = <PieChartSectionData>[];
    final legendItems = <Map<String, dynamic>>[];
    int colorIdx = 0;

    (breakdown as Map<String, dynamic>).forEach((key, value) {
      final pct = double.tryParse(value['percentage']?.toString() ?? '0') ?? 0;
      final color = categoryColors[colorIdx % categoryColors.length];
      pieData.add(PieChartSectionData(
        value: pct,
        color: color,
        radius: _touchedIndex == colorIdx ? 68 : 58,
        title: pct > 5 ? '${pct.toStringAsFixed(0)}%' : '',
        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
        showTitle: _touchedIndex == colorIdx || pct > 5,
      ));
      legendItems.add({'label': _formatKey(key), 'color': color, 'pct': pct, 'amount': value['amount']});
      colorIdx++;
    });

    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero cost card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.primaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Text('Total Construction Cost', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                Text(formattedTotal, style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _CostPill('Labor', currencyState.formatAmount(laborCost), Icons.construction),
                    _CostPill('Materials', currencyState.formatAmount(materialCost), Icons.inventory_outlined),
                    _CostPill('Contingency', currencyState.formatAmount(contingency), Icons.warning_amber_outlined),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cost breakdown pie chart
                Text('Cost Breakdown', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 180,
                            child: PieChart(
                              PieChartData(
                                pieTouchData: PieTouchData(
                                  touchCallback: (_, p) => setState(() => _touchedIndex = p?.touchedSection?.touchedSectionIndex ?? -1),
                                ),
                                sections: pieData,
                                sectionsSpace: 2,
                                centerSpaceRadius: 40,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: legendItems.take(7).map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  Container(width: 10, height: 10, decoration: BoxDecoration(color: item['color'], borderRadius: BorderRadius.circular(2))),
                                  const SizedBox(width: 6),
                                  Expanded(child: Text(item['label'] as String, style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis)),
                                  Text('${item['pct'].toStringAsFixed(0)}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                // Category cost bars
                Text('Category Details', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...legendItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _CategoryBar(
                    label: item['label'] as String,
                    amount: currencyState.formatAmount((item['amount'] as num?)?.toDouble() ?? 0),
                    percentage: (item['pct'] as double),
                    color: item['color'] as Color,
                  ),
                )),

                const SizedBox(height: 20),
                // Timeline
                if (timeline['phases'] != null) ...[
                  Text('Construction Timeline', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Estimated ${timeline['months'] ?? 12} months total', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 12),
                  ...(timeline['phases'] as List).map((phase) => _TimelineItem(phase: phase)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatKey(String key) => key.split('_').map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');

  void _downloadReport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preparing cost report PDF...')));
  }
}

class _CostPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _CostPill(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, color: Colors.white70, size: 20),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
    ],
  );
}

class _CategoryBar extends StatelessWidget {
  final String label;
  final String amount;
  final double percentage;
  final Color color;
  const _CategoryBar({required this.label, required this.amount, required this.percentage, required this.color});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          Text(amount, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
      const SizedBox(height: 4),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
        ),
      ),
    ],
  );
}

class _TimelineItem extends StatelessWidget {
  final dynamic phase;
  const _TimelineItem({required this.phase});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle)),
            Container(width: 2, height: 40, color: Theme.of(context).colorScheme.outlineVariant),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(phase['phase'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Text(phase['description'] ?? '', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              Text('Month ${phase['start_month']} - ${phase['end_month']} (${phase['duration_months']} months)', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    ),
  );
}
