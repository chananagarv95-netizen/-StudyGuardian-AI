import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared/models/app_usage_model.dart';
import 'package:shared/utils/duration_utils.dart';

/// Horizontal bar chart for top apps by usage time.
class TopAppsBarChart extends StatelessWidget {
  final List<AppUsageModel> apps;
  final int maxItems;
  final double height;

  const TopAppsBarChart({
    super.key,
    required this.apps,
    this.maxItems = 5,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    final topApps = apps.take(maxItems).toList();
    if (topApps.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('No app usage data')),
      );
    }

    final maxVal = topApps.first.foregroundTime.toDouble();

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxVal * 1.2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) =>
                  Theme.of(context).colorScheme.inverseSurface,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final app = topApps[groupIndex];
                return BarTooltipItem(
                  '${app.appName}\n${DurationUtils.formatDuration(app.foregroundTime)}',
                  TextStyle(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < topApps.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        topApps[index].appName.length > 8
                            ? '${topApps[index].appName.substring(0, 8)}...'
                            : topApps[index].appName,
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
                reservedSize: 30,
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barGroups: List.generate(topApps.length, (i) {
            final app = topApps[i];
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: app.foregroundTime.toDouble(),
                  gradient: LinearGradient(
                    colors: [
                      app.category.color.withValues(alpha: 0.6),
                      app.category.color,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  width: 28,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(8)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
