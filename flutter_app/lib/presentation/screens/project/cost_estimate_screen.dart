import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/project_provider.dart';
import '../../providers/currency_provider.dart';
import '../../widgets/charts/cost_breakdown_chart.dart';

class CostEstimateScreen extends ConsumerStatefulWidget {
  final String projectId;

  const CostEstimateScreen({super.key, required this.projectId});

  @override
  ConsumerState<CostEstimateScreen> createState() => _CostEstimateScreenState();
}

class _CostEstimateScreenState extends ConsumerState<CostEstimateScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final detailState = ref.watch(projectDetailProvider);
    final currencyState = ref.watch(currencyProvider);
    final colorScheme = Theme.of(context).colorScheme;

    if (detailState.costEstimate == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.costEstimate)),
        body: Center(child: Text('No cost estimate available')),
      );
    }

    final estimate = detailState.costEstimate!;
    final rate = currencyState.getConversionRate('USD');
    final converted = estimate.convertToCurrency(
      currencyState.selectedCurrencyCode,
      rate,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.costEstimate),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Currency selector
          PopupMenuButton<String>(
            icon: const Icon(Icons.currency_exchange_rounded),
            tooltip: l10n.changeCurrency,
            onSelected: (code) => ref.read(currencyProvider.notifier).setCurrency(code),
            itemBuilder: (context) => AppConstants.supportedCurrencies.map((c) {
              return PopupMenuItem<String>(
                value: c['code'] as String,
                child: Row(
                  children: [
                    Text(c['symbol'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text('${c['code']} - ${c['name']}'),
                    if (currencyState.selectedCurrencyCode == c['code']) ...[
                      const Spacer(),
                      const Icon(Icons.check_rounded, size: 16),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total cost hero card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryLight.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.attach_money_rounded, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.totalCost,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          currencyState.selectedCurrencyCode,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currencyState.formatAmount(estimate.totalCost),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _heroStatChip('${currencyState.formatAmount(estimate.costPerSqFt)}/sq ft', Icons.straighten_rounded),
                      const SizedBox(width: 12),
                      _heroStatChip(estimate.timeline, Icons.schedule_rounded),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Labor vs Material breakdown
            Row(
              children: [
                Expanded(
                  child: _splitCard(
                    context,
                    'Labor Cost',
                    currencyState.formatAmount(estimate.laborCost),
                    estimate.laborCost / estimate.totalCost,
                    AppColors.primaryLight,
                    colorScheme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _splitCard(
                    context,
                    'Material Cost',
                    currencyState.formatAmount(estimate.materialCost),
                    estimate.materialCost / estimate.totalCost,
                    AppColors.success,
                    colorScheme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _splitCard(
                    context,
                    'Contingency',
                    currencyState.formatAmount(estimate.contingency),
                    estimate.contingency / estimate.totalCost,
                    AppColors.warning,
                    colorScheme,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Pie Chart
            Text(l10n.costBreakdown, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SizedBox(
              height: 280,
              child: CostBreakdownChart(costEstimate: estimate),
            ),

            const SizedBox(height: 24),

            // Category breakdown
            Text('Category Breakdown', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),

            ...estimate.breakdown.toMap().entries.map((entry) {
              final percentage = entry.value / estimate.breakdown.total * 100;
              return _categoryRow(
                context,
                entry.key,
                currencyState.formatAmount(entry.value),
                percentage,
                colorScheme,
              );
            }).toList(),

            const SizedBox(height: 24),

            // Timeline & Area info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  _infoRow(context, Icons.schedule_rounded, 'Estimated Timeline', estimate.timeline, colorScheme),
                  Divider(color: colorScheme.outline, height: 24),
                  _infoRow(context, Icons.square_foot_rounded, 'Built-up Area', '${estimate.areaInSqFt.toStringAsFixed(0)} sq ft (${estimate.areaInSqM.toStringAsFixed(0)} sq m)', colorScheme),
                  Divider(color: colorScheme.outline, height: 24),
                  _infoRow(context, Icons.calculate_rounded, 'Cost Per Sq Ft', currencyState.formatAmount(estimate.costPerSqFt), colorScheme),
                  Divider(color: colorScheme.outline, height: 24),
                  _infoRow(context, Icons.calculate_rounded, 'Cost Per Sq M', currencyState.formatAmount(estimate.costPerSqM), colorScheme),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _heroStatChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white.withOpacity(0.9)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _splitCard(
    BuildContext context,
    String label,
    String value,
    double percentage,
    Color color,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
          const SizedBox(height: 4),
          Text(
            '${(percentage * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryRow(
    BuildContext context,
    String category,
    String amount,
    double percentage,
    ColorScheme colorScheme,
  ) {
    final Map<String, Color> categoryColors = {
      'Foundation': const Color(0xFF8B4513),
      'Structure': AppColors.primaryLight,
      'Roofing': const Color(0xFF9B59B6),
      'Electrical': AppColors.warning,
      'Plumbing': const Color(0xFF4A90D9),
      'HVAC': const Color(0xFF1ABC9C),
      'Interior': AppColors.accentLight,
      'Exterior': const Color(0xFF27AE60),
      'Landscaping': const Color(0xFF2ECC71),
    };

    final color = categoryColors[category] ?? colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(category, style: Theme.of(context).textTheme.bodyMedium),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  amount,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: color.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 12),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
