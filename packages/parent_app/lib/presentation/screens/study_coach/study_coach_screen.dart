import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared/utils/duration_utils.dart';

import '../../../core/di/providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/section_header.dart';

/// AI Study Coach screen providing personalized study insights and
/// recommendations based on today's analytics and usage data.
///
/// Watches [studyAnalyticsProvider] and [dailyUsageProvider] for the current
/// date and renders score breakdowns, usage summaries, and AI-driven
/// study recommendations.
class StudyCoachScreen extends ConsumerWidget {
  const StudyCoachScreen({super.key});

  // ─── Brand Colors ──────────────────────────────────────────────────────

  static const _indigo = Color(0xFF6366F1);
  static const _emerald = Color(0xFF10B981);
  static const _teal = Color(0xFF14B8A6);
  static const _amber = Color(0xFFF59E0B);
  static const _red = Color(0xFFEF4444);
  static const _slate800 = Color(0xFF1E293B);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final analyticsAsync = ref.watch(studyAnalyticsProvider(today));
    final usageAsync = ref.watch(dailyUsageProvider(today));

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Study Coach'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Card ──────────────────────────────────────────
            GlassCard(
              gradientColors: [
                _indigo.withValues(alpha: 0.15),
                const Color(0xFF8B5CF6).withValues(alpha: 0.08),
              ],
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _indigo.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: _indigo,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Study Coach',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Personalized insights for today',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
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
            const SizedBox(height: 16),

            // ── Content ──────────────────────────────────────────────
            analyticsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (analytics) {
                if (analytics == null) {
                  return const EmptyState(
                    icon: Icons.auto_awesome,
                    title: 'No Data Yet',
                    subtitle: 'Study analytics will appear once the '
                        'child\'s device starts reporting data.',
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Today's Summary ──────────────────────────────
                    const SectionHeader(title: "Today's Summary"),
                    GlassCard(
                      color: _slate800.withValues(alpha: 0.5),
                      child: Column(
                        children: [
                          _summaryRow(
                            context,
                            icon: Icons.phone_android,
                            label: 'Total Screen Time',
                            value: DurationUtils.formatDuration(
                                analytics.totalScreenTime),
                            color: _teal,
                          ),
                          const Divider(height: 20, thickness: 0.3),
                          _summaryRow(
                            context,
                            icon: Icons.school_rounded,
                            label: 'Educational Apps',
                            value: DurationUtils.formatDuration(
                                analytics.educationTime),
                            color: _emerald,
                          ),
                          const Divider(height: 20, thickness: 0.3),
                          _summaryRow(
                            context,
                            icon: Icons.movie_rounded,
                            label: 'Entertainment',
                            value:
                                '${analytics.entertainmentHours.toStringAsFixed(1)}h',
                            color: _amber,
                          ),
                          const Divider(height: 20, thickness: 0.3),
                          _summaryRow(
                            context,
                            icon: Icons.trending_up_rounded,
                            label: 'Productivity',
                            value:
                                '${analytics.productivityPercent.toStringAsFixed(0)}%',
                            color: _indigo,
                          ),
                          // Most used app from usage data
                          usageAsync.when(
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                            data: (usage) {
                              if (usage == null ||
                                  usage.topApps.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              final topApp = usage.topApps.first;
                              return Column(
                                children: [
                                  const Divider(
                                      height: 20, thickness: 0.3),
                                  _summaryRow(
                                    context,
                                    icon: Icons.star_rounded,
                                    label: 'Most Used App',
                                    value: topApp.appName,
                                    color: const Color(0xFF8B5CF6),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Score Breakdown ──────────────────────────────
                    const SectionHeader(title: 'Score Breakdown'),
                    _buildScoreCard(
                      context,
                      label: 'Study Score',
                      score: analytics.studyScore,
                      color: _emerald,
                      icon: Icons.school_rounded,
                    ),
                    _buildScoreCard(
                      context,
                      label: 'Focus Score',
                      score: analytics.focusScore,
                      color: _teal,
                      icon: Icons.center_focus_strong_rounded,
                    ),
                    _buildScoreCard(
                      context,
                      label: 'Distraction Score',
                      score: analytics.distractionScore,
                      color: _red,
                      icon: Icons.warning_amber_rounded,
                    ),
                    const SizedBox(height: 20),

                    // ── Study Recommendation ────────────────────────
                    const SectionHeader(title: 'Study Recommendation'),
                    _buildRecommendationCard(context, analytics.studyScore),
                    const SizedBox(height: 20),

                    // ── Most Distracting Apps ───────────────────────
                    if (analytics.mostDistractingApps.isNotEmpty) ...[
                      const SectionHeader(
                          title: 'Most Distracting Apps'),
                      GlassCard(
                        color: _slate800.withValues(alpha: 0.5),
                        child: Column(
                          children: analytics.mostDistractingApps
                              .asMap()
                              .entries
                              .map((entry) {
                            final isLast = entry.key ==
                                analytics.mostDistractingApps.length - 1;
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: _red.withValues(alpha: 0.15),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${entry.key + 1}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: _red,
                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        entry.value,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.block_rounded,
                                      size: 18,
                                      color: _red.withValues(alpha: 0.6),
                                    ),
                                  ],
                                ),
                                if (!isLast)
                                  const Divider(
                                      height: 20, thickness: 0.3),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─── Widget Builders ─────────────────────────────────────────────────────

  Widget _summaryRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(
    BuildContext context, {
    required String label,
    required int score,
    required Color color,
    required IconData icon,
  }) {
    return GlassCard(
      color: _slate800.withValues(alpha: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Text(
                '$score / 100',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (score / 100.0).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(BuildContext context, int studyScore) {
    final _RecommendationData rec;
    if (studyScore >= 80) {
      rec = _RecommendationData(
        title: '🌟 Excellent Performance!',
        message:
            'Outstanding study habits today! Keep up the great work. '
            'Consider tackling a challenging topic while your focus is high.',
        color: _emerald,
        icon: Icons.emoji_events_rounded,
      );
    } else if (studyScore >= 50) {
      rec = _RecommendationData(
        title: '👍 Good Progress',
        message:
            'You\'re on the right track! Try reducing entertainment time '
            'by 30 minutes and channeling that energy into focused study '
            'sessions for even better results.',
        color: _amber,
        icon: Icons.thumb_up_alt_rounded,
      );
    } else {
      rec = _RecommendationData(
        title: '📚 Needs Improvement',
        message:
            'Today\'s study time is below target. Consider setting '
            'app time limits on distracting apps and scheduling dedicated '
            'study blocks to build better habits.',
        color: _red,
        icon: Icons.trending_down_rounded,
      );
    }

    return GlassCard(
      gradientColors: [
        rec.color.withValues(alpha: 0.12),
        rec.color.withValues(alpha: 0.04),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(rec.icon, color: rec.color, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  rec.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: rec.color,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            rec.message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.8),
                ),
          ),
        ],
      ),
    );
  }
}

/// Internal data class for recommendation card rendering.
class _RecommendationData {
  final String title;
  final String message;
  final Color color;
  final IconData icon;

  const _RecommendationData({
    required this.title,
    required this.message,
    required this.color,
    required this.icon,
  });
}
