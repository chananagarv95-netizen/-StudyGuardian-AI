import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/models/report_model.dart';
import '../../../core/di/providers.dart';
import '../../widgets/glass_card.dart';

/// Report detail screen showing full report data pulled from Firestore.
class ReportDetailScreen extends ConsumerWidget {
  final String reportId;
  const ReportDetailScreen({super.key, required this.reportId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(allReportsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share coming soon')),
              );
            },
          ),
        ],
      ),
      body: reportsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error loading report: $e'),
        ),
        data: (reports) {
          final report = reports.where((r) => r.id == reportId).firstOrNull;
          if (report == null) {
            return const Center(
              child: Text('Report not found.'),
            );
          }
          return _buildReportContent(context, report);
        },
      ),
    );
  }

  Widget _buildReportContent(BuildContext context, ReportModel report) {
    final data = report.data;
    final theme = Theme.of(context);

    // Extract data from the flexible map
    final studyScore = data['studyScore'] as num? ?? 0;
    final focusScore = data['focusScore'] as num? ?? 0;
    final distractionScore = data['distractionScore'] as num? ?? 0;
    final productivityPercent = data['productivityPercent'] as num? ?? 0;
    final totalScreenTime = data['totalScreenTime'] as num? ?? 0;
    final studyHours = data['studyHours'] as num? ?? 0;
    final entertainmentHours = data['entertainmentHours'] as num? ?? 0;
    final educationTime = data['educationTime'] as num? ?? 0;
    final socialMediaTime = data['socialMediaTime'] as num? ?? 0;
    final gameTime = data['gameTime'] as num? ?? 0;
    final topApps = (data['topApps'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final summary = data['summary'] as String? ?? '';
    final trend = data['trend'] as String?;

    final screenTimeStr = _formatMinutes(totalScreenTime.toInt());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Card ──────────────────────────────────────────────
          GlassCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _scoreColor(studyScore.toInt()).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${studyScore.toInt()}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _scoreColor(studyScore.toInt()),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.type.displayName,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatDate(report.startDate)} – ${_formatDate(report.endDate)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      if (trend != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _trendLabel(trend),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _trendColor(trend),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Key Metrics ──────────────────────────────────────────────
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Key Metrics',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _infoRow(context, 'Screen Time', screenTimeStr),
                _infoRow(context, 'Study Hours',
                    '${studyHours.toStringAsFixed(1)}h'),
                _infoRow(context, 'Entertainment',
                    '${entertainmentHours.toStringAsFixed(1)}h'),
                _infoRow(context, 'Education',
                    _formatMinutes(educationTime.toInt())),
                _infoRow(context, 'Social Media',
                    _formatMinutes(socialMediaTime.toInt())),
                _infoRow(
                    context, 'Games', _formatMinutes(gameTime.toInt())),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Score Breakdown ───────────────────────────────────────────
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Score Breakdown',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _scoreBar(context, 'Study Score', studyScore.toInt()),
                const SizedBox(height: 10),
                _scoreBar(context, 'Focus Score', focusScore.toInt()),
                const SizedBox(height: 10),
                _scoreBar(
                    context, 'Distraction', distractionScore.toInt()),
                const SizedBox(height: 10),
                _infoRow(context, 'Productivity',
                    '${productivityPercent.toStringAsFixed(1)}%'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Top Apps ──────────────────────────────────────────────────
          if (topApps.isNotEmpty)
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Top Apps',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...topApps.take(5).map((app) {
                    final name = app['appName'] as String? ??
                        app['packageName'] as String? ??
                        'Unknown';
                    final minutes =
                        (app['foregroundTime'] as num?)?.toInt() ?? 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.apps, size: 20, color: Colors.grey),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(name,
                                style: theme.textTheme.bodyMedium),
                          ),
                          Text(
                            _formatMinutes(minutes),
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // ── AI Summary ────────────────────────────────────────────────
          if (summary.isNotEmpty)
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome,
                          size: 20, color: Color(0xFF6366F1)),
                      const SizedBox(width: 8),
                      Text('AI Summary',
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(summary, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Helper Widgets ────────────────────────────────────────────────────

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _scoreBar(BuildContext context, String label, int score) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Text('$score/100',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _scoreColor(score))),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: score / 100.0,
            minHeight: 8,
            backgroundColor: Colors.grey[800],
            valueColor: AlwaysStoppedAnimation<Color>(_scoreColor(score)),
          ),
        ),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  String _formatMinutes(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m > 0 ? '${h}h ${m}m' : '${h}h';
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  Color _scoreColor(int score) {
    if (score >= 80) return const Color(0xFF10B981); // Green
    if (score >= 60) return const Color(0xFF6366F1); // Indigo
    if (score >= 40) return const Color(0xFFF59E0B); // Amber
    return const Color(0xFFEF4444); // Red
  }

  String _trendLabel(String trend) {
    switch (trend) {
      case 'improving':
        return '📈 Improving';
      case 'declining':
        return '📉 Declining';
      case 'stable':
        return '➡️ Stable';
      default:
        return trend;
    }
  }

  Color _trendColor(String trend) {
    switch (trend) {
      case 'improving':
        return const Color(0xFF10B981);
      case 'declining':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }
}
