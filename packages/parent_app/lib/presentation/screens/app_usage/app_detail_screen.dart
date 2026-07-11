import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared/utils/duration_utils.dart';
import '../../../core/di/providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/category_badge.dart';
import '../../widgets/charts/weekly_bar_chart.dart';

/// Detailed view for a single app's usage.
class AppDetailScreen extends ConsumerWidget {
  final String packageName;
  const AppDetailScreen({super.key, required this.packageName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final usageAsync = ref.watch(dailyUsageProvider(today));

    return Scaffold(
      appBar: AppBar(title: const Text('App Details'), centerTitle: true),
      body: usageAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (usage) {
          final app = usage?.apps.where((a) => a.packageName == packageName).firstOrNull;
          if (app == null) return const Center(child: Text('App not found'));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App header
                GlassCard(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: app.category.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(app.category.icon, color: app.category.color, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(app.appName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            CategoryBadge(category: app.category),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Today's stats
                Row(
                  children: [
                    Expanded(child: _statCard(context, DurationUtils.formatDuration(app.foregroundTime), 'Usage Time', app.category.color)),
                    const SizedBox(width: 10),
                    Expanded(child: _statCard(context, '${app.openCount}', 'Opens', const Color(0xFF8B5CF6))),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _statCard(context, DurationUtils.formatDuration(app.longestSession), 'Longest', const Color(0xFFF59E0B))),
                    const SizedBox(width: 10),
                    Expanded(child: _statCard(context, DurationUtils.formatDuration(app.backgroundTime), 'Background', const Color(0xFF14B8A6))),
                  ],
                ),
                const SizedBox(height: 20),

                // Weekly chart (simulated from available data)
                Text('Weekly Trend', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                GlassCard(
                  child: WeeklyBarChart(
                    data: {
                      'Mon': app.foregroundTime * 0.8,
                      'Tue': app.foregroundTime * 1.1,
                      'Wed': app.foregroundTime * 0.6,
                      'Thu': app.foregroundTime * 0.9,
                      'Fri': app.foregroundTime * 1.3,
                      'Sat': app.foregroundTime * 1.5,
                      'Sun': app.foregroundTime.toDouble(),
                    },
                    color: app.category.color,
                    label: 'min',
                    height: 180,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statCard(BuildContext context, String value, String label, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
        ],
      ),
    );
  }
}
