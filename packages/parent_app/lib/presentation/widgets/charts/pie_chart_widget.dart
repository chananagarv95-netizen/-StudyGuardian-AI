import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared/models/app_category.dart';
import 'package:shared/utils/duration_utils.dart';

/// Interactive pie chart showing app usage by category.
class CategoryPieChart extends StatefulWidget {
  final Map<AppCategory, int> data;
  final double size;

  const CategoryPieChart({
    super.key,
    required this.data,
    this.size = 200,
  });

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final total = widget.data.values.fold(0, (a, b) => a + b);
    if (total == 0) {
      return SizedBox(
        height: widget.size,
        child: const Center(child: Text('No usage data')),
      );
    }

    final sortedEntries = widget.data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        SizedBox(
          height: widget.size,
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
                    _touchedIndex =
                        response.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: widget.size * 0.2,
              sections: _buildSections(sortedEntries, total),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Legend
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: sortedEntries.map((entry) {
            final percentage =
                (entry.value / total * 100).toStringAsFixed(1);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: entry.key.color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${entry.key.displayName} ($percentage%)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildSections(
    List<MapEntry<AppCategory, int>> entries,
    int total,
  ) {
    return List.generate(entries.length, (i) {
      final entry = entries[i];
      final isTouched = i == _touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 70.0 : 60.0;
      final percentage = (entry.value / total * 100).toStringAsFixed(0);

      return PieChartSectionData(
        color: entry.key.color,
        value: entry.value.toDouble(),
        title: isTouched
            ? '${entry.key.displayName}\n${DurationUtils.formatDuration(entry.value)}'
            : '$percentage%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [
            Shadow(color: Colors.black26, blurRadius: 2),
          ],
        ),
      );
    });
  }
}
