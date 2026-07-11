import 'package:flutter/material.dart';

/// 24-hour activity heatmap showing intensity per hour.
class HourlyHeatmap extends StatelessWidget {
  final Map<int, int> data;
  final double height;

  const HourlyHeatmap({
    super.key,
    required this.data,
    this.height = 120,
  });

  Color _getColor(int minutes, int maxMinutes, BuildContext context) {
    if (minutes == 0) {
      return Theme.of(context).colorScheme.surface;
    }
    final intensity = maxMinutes > 0 ? minutes / maxMinutes : 0.0;
    return Color.lerp(
      const Color(0xFF6366F1).withValues(alpha: 0.15),
      const Color(0xFF6366F1),
      intensity,
    )!;
  }

  @override
  Widget build(BuildContext context) {
    final maxMinutes = data.values.isEmpty
        ? 1
        : data.values.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: height,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: List.generate(24, (hour) {
                final minutes = data[hour] ?? 0;
                return Expanded(
                  child: Tooltip(
                    message: '${_formatHour(hour)}: ${minutes}m',
                    child: Container(
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: _getColor(minutes, maxMinutes, context),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '12 AM',
                style: TextStyle(
                  fontSize: 9,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.4),
                ),
              ),
              Text(
                '6 AM',
                style: TextStyle(
                  fontSize: 9,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.4),
                ),
              ),
              Text(
                '12 PM',
                style: TextStyle(
                  fontSize: 9,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.4),
                ),
              ),
              Text(
                '6 PM',
                style: TextStyle(
                  fontSize: 9,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.4),
                ),
              ),
              Text(
                '12 AM',
                style: TextStyle(
                  fontSize: 9,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
  }
}
