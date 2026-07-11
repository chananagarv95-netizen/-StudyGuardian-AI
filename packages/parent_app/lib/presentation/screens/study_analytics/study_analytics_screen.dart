import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared/utils/duration_utils.dart';
import '../../../core/di/providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/score_gauge.dart';
import '../../widgets/section_header.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/charts/score_comparison_chart.dart';

/// Study analytics dashboard with scores and trend visualization.
class StudyAnalyticsScreen extends ConsumerStatefulWidget {
  const StudyAnalyticsScreen({super.key});

  @override
  ConsumerState<StudyAnalyticsScreen> createState() => _StudyAnalyticsScreenState();
}

class _StudyAnalyticsScreenState extends ConsumerState<StudyAnalyticsScreen> {
  int _periodIndex = 0;

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final analyticsAsync = ref.watch(studyAnalyticsProvider(today));

    return Scaffold(
      appBar: AppBar(title: const Text('Study Analytics'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period selector
            Row(
              children: [
                _periodChip('Today', 0),
                const SizedBox(width: 8),
                _periodChip('This Week', 1),
                const SizedBox(width: 8),
                _periodChip('This Month', 2),
              ],
            ),
            const SizedBox(height: 20),

            analyticsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (analytics) {
                if (analytics == null) {
                  return const EmptyState(icon: Icons.analytics, title: 'No Analytics', subtitle: 'No study analytics data available for this period');
                }

                return Column(
                  children: [
                    // Score gauges
                    Row(
                      children: [
                        Expanded(child: GlassCard(padding: const EdgeInsets.all(12),
                          child: ScoreGauge(score: analytics.studyScore, label: 'Study', color: const Color(0xFF10B981), size: 90))),
                        const SizedBox(width: 10),
                        Expanded(child: GlassCard(padding: const EdgeInsets.all(12),
                          child: ScoreGauge(score: analytics.focusScore, label: 'Focus', color: const Color(0xFF6366F1), size: 90))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: GlassCard(padding: const EdgeInsets.all(12),
                          child: ScoreGauge(score: analytics.distractionScore, label: 'Distract', color: const Color(0xFFEF4444), size: 90))),
                        const SizedBox(width: 10),
                        Expanded(child: GlassCard(padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text('${analytics.productivityPercent.toStringAsFixed(0)}%',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF14B8A6))),
                              const SizedBox(height: 4),
                              Text('Productivity', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
                            ],
                          ))),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // AI Summary
                    if (analytics.aiSummary.isNotEmpty) ...[
                      GlassCard(
                        gradientColors: [const Color(0xFF6366F1).withValues(alpha: 0.12), const Color(0xFF8B5CF6).withValues(alpha: 0.06)],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              const Text('🤖', style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Text('AI Summary', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                            ]),
                            const SizedBox(height: 12),
                            Text(analytics.aiSummary, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic, height: 1.5,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                            )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Time breakdown
                    SectionHeader(title: 'Time Breakdown'),
                    GlassCard(
                      child: Column(
                        children: [
                          _timeRow(context, 'Study Time', DurationUtils.formatDuration(analytics.educationTime), const Color(0xFF10B981)),
                          _timeRow(context, 'Entertainment', DurationUtils.formatDuration(analytics.entertainmentHours.round()), const Color(0xFFF59E0B)),
                          _timeRow(context, 'Social Media', DurationUtils.formatDuration(analytics.socialMediaTime), const Color(0xFFEF4444)),
                          _timeRow(context, 'Games', DurationUtils.formatDuration(analytics.gameTime), const Color(0xFF8B5CF6)),
                          _timeRow(context, 'Total Screen', DurationUtils.formatDuration(analytics.totalScreenTime), Colors.blue),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Longest session & distracting apps
                    Row(
                      children: [
                        Expanded(child: GlassCard(padding: const EdgeInsets.all(16),
                          child: Column(children: [
                            const Icon(Icons.timer, color: Color(0xFF10B981)),
                            const SizedBox(height: 8),
                            Text(DurationUtils.formatDuration(analytics.longestStudySession),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            Text('Longest Session', style: Theme.of(context).textTheme.bodySmall),
                          ]))),
                        const SizedBox(width: 10),
                        Expanded(child: GlassCard(padding: const EdgeInsets.all(16),
                          child: Column(children: [
                            const Icon(Icons.warning_amber, color: Color(0xFFEF4444)),
                            const SizedBox(height: 8),
                            Text(analytics.mostDistractingApps.take(2).join(', '),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                            Text('Top Distractions', style: Theme.of(context).textTheme.bodySmall),
                          ]))),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _periodChip(String label, int index) {
    return ChoiceChip(label: Text(label), selected: _periodIndex == index,
      onSelected: (selected) { if (selected) setState(() => _periodIndex = index); });
  }

  Widget _timeRow(BuildContext context, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(width: 4, height: 20, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
