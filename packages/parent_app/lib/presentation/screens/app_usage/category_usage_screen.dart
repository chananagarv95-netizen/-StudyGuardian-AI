import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared/models/app_category.dart';
import 'package:shared/models/app_usage_model.dart';
import 'package:shared/utils/duration_utils.dart';

import '../../../core/di/providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/section_header.dart';

/// Screen that groups today's app usage by [AppCategory].
///
/// Each category is displayed as an expandable card showing the total
/// foreground time, app count, and percentage of total screen time.
/// Expanding a category reveals the individual apps sorted by usage.
class CategoryUsageScreen extends ConsumerWidget {
  const CategoryUsageScreen({super.key});

  // ─── Brand Colors ──────────────────────────────────────────────────────

  static const _slate800 = Color(0xFF1E293B);
  static const _indigo = Color(0xFF6366F1);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final usageAsync = ref.watch(dailyUsageProvider(today));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Usage'),
        centerTitle: true,
      ),
      body: usageAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (usage) {
          if (usage == null || usage.apps.isEmpty) {
            return const EmptyState(
              icon: Icons.category_rounded,
              title: 'No Usage Data',
              subtitle: 'App usage data will appear once the child\'s '
                  'device starts reporting.',
            );
          }

          final grouped = _groupByCategory(usage.apps);
          final sortedCategories = grouped.entries.toList()
            ..sort((a, b) => b.value.totalTime.compareTo(a.value.totalTime));

          final totalScreenTime = usage.totalScreenTime;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Overview card ────────────────────────────────────
                GlassCard(
                  gradientColors: [
                    _indigo.withValues(alpha: 0.12),
                    const Color(0xFF8B5CF6).withValues(alpha: 0.06),
                  ],
                  child: Row(
                    children: [
                      const Icon(Icons.category_rounded,
                          color: _indigo, size: 28),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${sortedCategories.length} Categories',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${usage.apps.length} apps · '
                              '${DurationUtils.formatDuration(totalScreenTime)} total',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const SectionHeader(title: 'By Category'),

                // ── Category Expansion Tiles ────────────────────────
                ...sortedCategories.map((entry) {
                  final category = entry.key;
                  final categoryData = entry.value;
                  final percentage = totalScreenTime > 0
                      ? (categoryData.totalTime / totalScreenTime * 100)
                      : 0.0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: GlassCard(
                      color: _slate800.withValues(alpha: 0.5),
                      padding: EdgeInsets.zero,
                      child: Theme(
                        // Remove default ExpansionTile dividers
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                        ),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 4),
                          childrenPadding: const EdgeInsets.only(
                              left: 20, right: 20, bottom: 16),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: category.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              category.icon,
                              color: category.color,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            category.displayName,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Row(
                            children: [
                              Text(
                                DurationUtils.formatDuration(
                                    categoryData.totalTime),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: category.color,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '·',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.4),
                                    ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${categoryData.apps.length} '
                                '${categoryData.apps.length == 1 ? 'app' : 'apps'}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.5),
                                    ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color:
                                      category.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${percentage.toStringAsFixed(1)}%',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: category.color,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          iconColor: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                          collapsedIconColor: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.3),
                          children: [
                            // Progress bar for category
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: (percentage / 100.0).clamp(0.0, 1.0),
                                minHeight: 4,
                                backgroundColor:
                                    category.color.withValues(alpha: 0.1),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    category.color),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Individual apps
                            ...categoryData.apps
                                .asMap()
                                .entries
                                .map((appEntry) {
                              final app = appEntry.value;
                              final appPercent = totalScreenTime > 0
                                  ? (app.foregroundTime /
                                      totalScreenTime *
                                      100)
                                  : 0.0;

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: category.color
                                            .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: Center(
                                        child: Text(
                                          app.appName.isNotEmpty
                                              ? app.appName[0].toUpperCase()
                                              : '?',
                                          style: TextStyle(
                                            color: category.color,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            app.appName,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${app.openCount} opens',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withValues(
                                                          alpha: 0.4),
                                                  fontSize: 11,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          DurationUtils.formatDuration(
                                              app.foregroundTime),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${appPercent.toStringAsFixed(1)}%',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.4),
                                                fontSize: 11,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── Data Helpers ────────────────────────────────────────────────────────

  /// Groups a list of [AppUsageModel] by their [AppCategory] and computes
  /// aggregate totals. Apps within each category are sorted by foreground
  /// time descending.
  Map<AppCategory, _CategoryGroup> _groupByCategory(
      List<AppUsageModel> apps) {
    final map = <AppCategory, _CategoryGroup>{};

    for (final app in apps) {
      if (app.foregroundTime <= 0) continue;

      final group = map.putIfAbsent(
        app.category,
        () => _CategoryGroup(category: app.category),
      );
      group.apps.add(app);
      group.totalTime += app.foregroundTime;
    }

    // Sort apps within each category by foreground time descending
    for (final group in map.values) {
      group.apps
          .sort((a, b) => b.foregroundTime.compareTo(a.foregroundTime));
    }

    return map;
  }
}

/// Internal grouping data for a single [AppCategory].
class _CategoryGroup {
  final AppCategory category;
  final List<AppUsageModel> apps;
  int totalTime = 0;

  _CategoryGroup({
    required this.category,
    List<AppUsageModel>? apps,
  }) : apps = apps ?? [];
}
