import 'package:flutter/material.dart';

/// Battery level indicator with color-coded fill and charging animation.
class BatteryIndicator extends StatelessWidget {
  final int percentage;
  final bool isCharging;
  final double size;

  const BatteryIndicator({
    super.key,
    required this.percentage,
    this.isCharging = false,
    this.size = 28,
  });

  Color get _color {
    if (percentage > 50) return const Color(0xFF10B981);
    if (percentage > 20) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  IconData get _icon {
    if (isCharging) return Icons.battery_charging_full;
    if (percentage > 90) return Icons.battery_full;
    if (percentage > 60) return Icons.battery_5_bar;
    if (percentage > 40) return Icons.battery_4_bar;
    if (percentage > 20) return Icons.battery_2_bar;
    return Icons.battery_1_bar;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_icon, color: _color, size: size),
        const SizedBox(width: 4),
        Text(
          '$percentage%',
          style: TextStyle(
            color: _color,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.5,
          ),
        ),
        if (isCharging) ...[
          const SizedBox(width: 2),
          Icon(Icons.bolt, color: _color, size: size * 0.6),
        ],
      ],
    );
  }
}
