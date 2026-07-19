import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared/models/app_category.dart';
import '../../../core/di/providers.dart';
import '../../widgets/app_usage_tile.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/empty_state.dart';

/// Category breakdown screen showing apps within a specific category.
class CategoryBreakdownScreen extends ConsumerWidget {
  final AppCategory category;
  const CategoryBreakdownScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final usageAsync = ref.watch(dailyUsageProvider(today));

    return Scaffold(
      appBar: AppBar(
        title: Text(category.displayName),
        centerTitle: true,
      ),
      body: usageAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (usage) {
          final apps = usage?.apps.where((a) => a.category == category).toList() ?? [];
          apps.sort((a, b) => b.foregroundTime.compareTo(a.foregroundTime));

          if (apps.isEmpty) {
            return EmptyState(icon: category.icon, title: 'No ${category.displayName} Apps', subtitle: 'No apps in this category were used today');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GlassCard(
                  child: Column(
                    children: [
                      Icon(category.icon, color: category.color, size: 40),
                      const SizedBox(height: 8),
                      Text('${apps.length} apps', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ...apps.map((app) => AppUsageTile(
                  appName: app.appName,
                  category: app.category,
                  usageMinutes: app.foregroundTime,
                  totalMinutes: usage!.totalScreenTime,
                  openCount: app.openCount,
                )),
              ],
            ),
          );
        },
      ),
    );
  }
}
