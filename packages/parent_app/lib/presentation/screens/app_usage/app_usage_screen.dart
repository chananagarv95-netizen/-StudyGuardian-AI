import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared/models/app_category.dart';
import 'package:shared/utils/duration_utils.dart';
import '../../../core/di/providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/app_usage_tile.dart';
import '../../widgets/section_header.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/charts/pie_chart_widget.dart';

/// App usage screen with category breakdown and per-app list.
class AppUsageScreen extends ConsumerStatefulWidget {
  const AppUsageScreen({super.key});

  @override
  ConsumerState<AppUsageScreen> createState() => _AppUsageScreenState();
}

class _AppUsageScreenState extends ConsumerState<AppUsageScreen> {
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  int _dateIndex = 0; // 0=Today, 1=Yesterday
  AppCategory? _filterCategory;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final usageAsync = ref.watch(dailyUsageProvider(_selectedDate));

    return Scaffold(
      appBar: AppBar(title: const Text('App Usage'), centerTitle: true),
      body: Column(
        children: [
          // Date selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _dateChip('Today', 0),
                const SizedBox(width: 8),
                _dateChip('Yesterday', 1),
              ],
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search apps...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Content
          Expanded(
            child: usageAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (usage) {
                if (usage == null || usage.apps.isEmpty) {
                  return const EmptyState(icon: Icons.apps, title: 'No Usage Data', subtitle: 'No app usage recorded for this day');
                }

                var apps = List.of(usage.apps)..sort((a, b) => b.foregroundTime.compareTo(a.foregroundTime));
                if (_filterCategory != null) apps = apps.where((a) => a.category == _filterCategory).toList();
                if (_searchQuery.isNotEmpty) apps = apps.where((a) => a.appName.toLowerCase().contains(_searchQuery)).toList();

                // Category breakdown
                final categoryMap = <AppCategory, int>{};
                for (final app in usage.apps) {
                  categoryMap[app.category] = (categoryMap[app.category] ?? 0) + app.foregroundTime;
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Summary card
                      GlassCard(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _statColumn(context, DurationUtils.formatDuration(usage.totalScreenTime), 'Screen Time'),
                            _statColumn(context, '${usage.unlockCount}', 'Unlocks'),
                            _statColumn(context, '${usage.apps.length}', 'Apps Used'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Pie chart
                      SectionHeader(title: 'Category Breakdown'),
                      GlassCard(child: CategoryPieChart(data: categoryMap, size: 180)),
                      const SizedBox(height: 16),
                      // Category filter
                      SizedBox(
                        height: 36,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _filterChip(null, 'All'),
                            ...AppCategory.values.where((c) => categoryMap.containsKey(c))
                                .map((c) => _filterChip(c, c.displayName)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // App list
                      ...apps.map((app) => AppUsageTile(
                        appName: app.appName,
                        category: app.category,
                        usageMinutes: app.foregroundTime,
                        totalMinutes: usage.totalScreenTime,
                        openCount: app.openCount,
                        onTap: () => context.push('/usage/detail/${app.packageName}'),
                      )),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateChip(String label, int index) {
    final isSelected = _dateIndex == index;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _dateIndex = index;
            final date = DateTime.now().subtract(Duration(days: index));
            _selectedDate = DateFormat('yyyy-MM-dd').format(date);
          });
        }
      },
    );
  }

  Widget _filterChip(AppCategory? category, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: _filterCategory == category,
        onSelected: (_) => setState(() => _filterCategory = _filterCategory == category ? null : category),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _statColumn(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
      ],
    );
  }
}
