import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/models/report_model.dart';
import '../../../core/di/providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/empty_state.dart';

/// Reports list screen with Daily/Weekly/Monthly tabs.
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(allReportsProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reports'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Daily'),
              Tab(text: 'Weekly'),
              Tab(text: 'Monthly'),
            ],
          ),
        ),
        body: reportsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (reports) {
            final daily = reports.where((r) => r.type == ReportType.daily).toList();
            final weekly = reports.where((r) => r.type == ReportType.weekly).toList();
            final monthly = reports.where((r) => r.type == ReportType.monthly).toList();

            return TabBarView(
              children: [
                _buildReportList(context, daily, 'daily'),
                _buildReportList(context, weekly, 'weekly'),
                _buildReportList(context, monthly, 'monthly'),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildReportList(BuildContext context, List<ReportModel> reports, String type) {
    if (reports.isEmpty) {
      return EmptyState(icon: Icons.assessment, title: 'No ${type.substring(0, 1).toUpperCase()}${type.substring(1)} Reports', subtitle: 'Reports will appear here once generated');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return GlassCard(
          onTap: () => context.push('/reports/${report.id}'),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _typeColor(report.type).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_typeIcon(report.type), color: _typeColor(report.type)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${report.startDate} → ${report.endDate}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Generated ${report.generatedAt.toString().substring(0, 16)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4))),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 20),
            ],
          ),
        );
      },
    );
  }

  Color _typeColor(ReportType type) {
    switch (type) {
      case ReportType.daily: return const Color(0xFF10B981);
      case ReportType.weekly: return const Color(0xFF6366F1);
      case ReportType.monthly: return const Color(0xFFF59E0B);
    }
  }

  IconData _typeIcon(ReportType type) {
    switch (type) {
      case ReportType.daily: return Icons.today;
      case ReportType.weekly: return Icons.view_week;
      case ReportType.monthly: return Icons.calendar_month;
    }
  }
}
