import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Grouped bar chart comparing study vs entertainment vs social media.
class ScoreComparisonChart extends StatelessWidget {
  final List<double> studyData;
  final List<double> entertainmentData;
  final List<double> socialData;
  final List<String> labels;
  final double height;

  const ScoreComparisonChart({
    super.key,
    required this.studyData,
    required this.entertainmentData,
    required this.socialData,
    required this.labels,
    this.height = 220,
  });

  @override
  Widget build(BuildContext context) {
    final count = studyData.length;
    if (count == 0) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('No comparison data')),
      );
    }

    final allValues = [...studyData, ...entertainmentData, ...socialData];
    final maxVal = allValues.isEmpty
        ? 1.0
        : allValues.reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        SizedBox(
          height: height,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxVal * 1.2,
              groupsSpace: 16,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) =>
                      Theme.of(context).colorScheme.inverseSurface,
                ),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < labels.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            labels[index],
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                    reservedSize: 28,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toStringAsFixed(0)}h',
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.4),
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.08),
                  strokeWidth: 1,
                ),
              ),
              barGroups: List.generate(count, (i) {
                return BarChartGroupData(
                  x: i,
                  barsSpace: 4,
                  barRods: [
                    BarChartRodData(
                      toY: studyData[i],
                      color: const Color(0xFF10B981),
                      width: 10,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4)),
                    ),
                    BarChartRodData(
                      toY: entertainmentData[i],
                      color: const Color(0xFFF59E0B),
                      width: 10,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4)),
                    ),
                    BarChartRodData(
                      toY: socialData[i],
                      color: const Color(0xFFEF4444),
                      width: 10,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4)),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendItem(color: const Color(0xFF10B981), label: 'Study'),
            const SizedBox(width: 20),
            _LegendItem(
                color: const Color(0xFFF59E0B), label: 'Entertainment'),
            const SizedBox(width: 20),
            _LegendItem(color: const Color(0xFFEF4444), label: 'Social'),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
