import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/cost_estimate_model.dart';

class CostBreakdownChart extends StatefulWidget {
  final CostEstimateModel costEstimate;

  const CostBreakdownChart({super.key, required this.costEstimate});

  @override
  State<CostBreakdownChart> createState() => _CostBreakdownChartState();
}

class _CostBreakdownChartState extends State<CostBreakdownChart> {
  int _touchedIndex = -1;

  static const List<Color> _chartColors = [
    Color(0xFF1A3A6B),
    Color(0xFF2D5BE3),
    Color(0xFF00BCD4),
    Color(0xFFFF6B35),
    Color(0xFF27AE60),
    Color(0xFF9B59B6),
    Color(0xFFD4AC0D),
    Color(0xFFE74C3C),
    Color(0xFF2ECC71),
  ];

  @override
  Widget build(BuildContext context) {
    final breakdown = widget.costEstimate.breakdown;
    final entries = breakdown.toMap().entries.toList();
    final total = breakdown.total;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        // Pie Chart
        Expanded(
          flex: 5,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex = response.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sections: entries.asMap().entries.map((entry) {
                final i = entry.key;
                final e = entry.value;
                final isTouched = _touchedIndex == i;
                final percent = e.value / total * 100;

                return PieChartSectionData(
                  color: _chartColors[i % _chartColors.length],
                  value: e.value,
                  title: isTouched ? '${percent.toStringAsFixed(1)}%' : '',
                  radius: isTouched ? 80 : 65,
                  titleStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
              centerSpaceRadius: 45,
              sectionsSpace: 2,
            ),
          ),
        ),

        // Legend
        Expanded(
          flex: 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: entries.asMap().entries.map((entry) {
              final i = entry.key;
              final e = entry.value;
              final percent = e.value / total * 100;
              final color = _chartColors[i % _chartColors.length];
              final isTouched = _touchedIndex == i;

              return GestureDetector(
                onTap: () => setState(() => _touchedIndex = isTouched ? -1 : i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: isTouched ? 4 : 2,
                  ),
                  decoration: BoxDecoration(
                    color: isTouched ? color.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isTouched ? color.withOpacity(0.3) : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          e.key,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: isTouched ? FontWeight.w700 : FontWeight.w400,
                            color: colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${percent.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
