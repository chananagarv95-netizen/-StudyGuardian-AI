import 'package:flutter/material.dart';
import 'package:shared/models/app_category.dart';

/// Small category badge showing icon and name with category color.
class CategoryBadge extends StatelessWidget {
  final AppCategory category;
  final bool compact;

  const CategoryBadge({
    super.key,
    required this.category,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: category.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            category.icon,
            size: compact ? 12 : 14,
            color: category.color,
          ),
          if (!compact) ...[
            const SizedBox(width: 4),
            Text(
              category.displayName,
              style: TextStyle(
                fontSize: compact ? 10 : 11,
                fontWeight: FontWeight.w600,
                color: category.color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
