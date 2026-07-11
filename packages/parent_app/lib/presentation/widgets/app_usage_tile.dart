import 'package:flutter/material.dart';
import 'package:shared/models/app_category.dart';
import 'package:shared/utils/duration_utils.dart';
import 'category_badge.dart';

/// List tile for app usage display with category badge and progress bar.
class AppUsageTile extends StatelessWidget {
  final String appName;
  final AppCategory category;
  final int usageMinutes;
  final int totalMinutes;
  final int openCount;
  final VoidCallback? onTap;

  const AppUsageTile({
    super.key,
    required this.appName,
    required this.category,
    required this.usageMinutes,
    required this.totalMinutes,
    required this.openCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalMinutes > 0 ? usageMinutes / totalMinutes : 0.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .outline
                .withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Category color indicator
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: category.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                // App info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appName,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      CategoryBadge(category: category, compact: true),
                    ],
                  ),
                ),
                // Usage stats
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DurationUtils.formatDuration(usageMinutes),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: category.color,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$openCount opens',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5),
                          ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.3),
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: category.color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(category.color),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
