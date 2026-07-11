import '../models/daily_usage_model.dart';
import '../models/study_analytics_model.dart';
import 'duration_utils.dart';

/// Generates human-readable natural language summaries from usage and analytics data.
///
/// Designed for displaying daily summary cards and generating parent reports.
class SummaryGenerator {
  SummaryGenerator._();

  /// Generates a comprehensive daily summary in natural language.
  ///
  /// Combines data from [usage] (raw screen time and app data) and
  /// [analytics] (computed study scores and classifications) to produce
  /// a multi-sentence paragraph describing the day's device usage.
  ///
  /// Returns `'No device usage was recorded today.'` if total screen time is zero.
  ///
  /// The summary includes:
  /// - Total screen time
  /// - Educational app usage (if any)
  /// - Entertainment app usage (if any)
  /// - Gaming app usage (if any)
  /// - Social media usage (if any)
  /// - Top 3 most-used apps by foreground time
  /// - Study performance assessment
  /// - Overall study score
  /// - Most distracting apps (if any)
  static String generateDailySummary(
    DailyUsageModel usage,
    StudyAnalyticsModel analytics,
  ) {
    final int totalScreenTime = usage.totalScreenTime;

    // Edge case: no usage recorded.
    if (totalScreenTime <= 0) {
      return 'No device usage was recorded today.';
    }

    final StringBuffer buffer = StringBuffer();

    // Total screen time.
    buffer.writeln(
      'Today the device was used for ${DurationUtils.formatMinutes(totalScreenTime)}.',
    );

    // Educational time.
    final int educationTime = analytics.educationTime;
    if (educationTime > 0) {
      buffer.writeln(
        'Educational apps were used for ${DurationUtils.formatMinutes(educationTime)}.',
      );
    }

    // Entertainment time (stored in hours in the analytics model).
    final double entertainmentHours = analytics.entertainmentHours;
    if (entertainmentHours > 0) {
      final int entertainmentMinutes = (entertainmentHours * 60).round();
      buffer.writeln(
        'Entertainment apps were used for ${DurationUtils.formatMinutes(entertainmentMinutes)}.',
      );
    }

    // Game time.
    final int gameTime = analytics.gameTime;
    if (gameTime > 0) {
      buffer.writeln(
        'Gaming apps were used for ${DurationUtils.formatMinutes(gameTime)}.',
      );
    }

    // Social media time.
    final int socialMediaTime = analytics.socialMediaTime;
    if (socialMediaTime > 0) {
      buffer.writeln(
        'Social media was used for ${DurationUtils.formatMinutes(socialMediaTime)}.',
      );
    }

    // Top 3 apps by foreground time.
    if (usage.apps.isNotEmpty) {
      final List<AppUsageEntry> sortedApps = List<AppUsageEntry>.from(usage.apps)
        ..sort((a, b) => b.foregroundTime.compareTo(a.foregroundTime));

      final int topCount = sortedApps.length < 3 ? sortedApps.length : 3;
      final List<String> topAppNames = sortedApps
          .take(topCount)
          .map((app) => '${app.appName} (${DurationUtils.formatDuration(app.foregroundTime)})')
          .toList();

      buffer.writeln(
        'Top apps: ${topAppNames.join(', ')}.',
      );
    }

    // Study performance assessment.
    final int studyScore = analytics.studyScore;
    if (studyScore > 80) {
      buffer.writeln('Excellent study performance!');
    } else if (studyScore > 50) {
      buffer.writeln('Moderate study performance.');
    } else {
      buffer.writeln('Study performance needs improvement.');
    }

    // Overall study score.
    buffer.writeln('Overall study score: $studyScore/100.');

    // Most distracting apps.
    if (analytics.mostDistractingApps.isNotEmpty) {
      buffer.writeln(
        'Most distracting apps: ${analytics.mostDistractingApps.join(', ')}.',
      );
    }

    return buffer.toString().trim();
  }
}
