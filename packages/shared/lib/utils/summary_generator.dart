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

  /// Generates a focused study recommendation based on score ranges.
  ///
  /// Returns a paragraph with actionable advice tailored to the
  /// student's current study, focus, and distraction scores.
  static String generateStudyRecommendation(
    int studyScore,
    int focusScore,
    int distractionScore,
  ) {
    final StringBuffer buffer = StringBuffer();

    // Study score recommendation
    if (studyScore >= 80) {
      buffer.writeln(
        '🌟 Excellent study habits! Keep maintaining this level of '
        'dedication to educational content.',
      );
    } else if (studyScore >= 60) {
      buffer.writeln(
        '👍 Good study engagement. Try increasing educational app '
        'usage by 15–20 minutes daily for even better results.',
      );
    } else if (studyScore >= 40) {
      buffer.writeln(
        '📚 Moderate study time. Consider setting a daily study goal '
        'of at least 1 hour on educational apps.',
      );
    } else {
      buffer.writeln(
        '⚠️ Low study engagement today. Encourage using educational '
        'apps like Khan Academy, Duolingo, or study tools.',
      );
    }

    // Focus recommendation
    if (focusScore < 50) {
      buffer.writeln(
        '🎯 Focus is low — frequent app switching detected. '
        'Try enabling "Do Not Disturb" during study sessions.',
      );
    } else if (focusScore >= 80) {
      buffer.writeln(
        '🎯 Great focus! Minimal app switching and low social media '
        'usage during study time.',
      );
    }

    // Distraction recommendation
    if (distractionScore >= 70) {
      buffer.writeln(
        '📱 High distraction level. Entertainment and social media '
        'are consuming a large portion of screen time. Consider '
        'setting time limits.',
      );
    } else if (distractionScore >= 40) {
      buffer.writeln(
        '📱 Moderate distractions. A healthy balance, but reducing '
        'entertainment time by 15 minutes could improve productivity.',
      );
    }

    return buffer.toString().trim();
  }

  /// Generates a weekly insight summary from a list of daily analytics.
  ///
  /// Analyzes trends across the week and provides a high-level overview.
  static String generateWeeklyInsight(
    List<StudyAnalyticsModel> weekHistory,
  ) {
    if (weekHistory.isEmpty) {
      return 'No analytics data available for this week.';
    }

    final StringBuffer buffer = StringBuffer();

    // Average scores
    final avgStudy = weekHistory
        .map((a) => a.studyScore)
        .reduce((a, b) => a + b) ~/ weekHistory.length;
    final avgFocus = weekHistory
        .map((a) => a.focusScore)
        .reduce((a, b) => a + b) ~/ weekHistory.length;
    final avgDistraction = weekHistory
        .map((a) => a.distractionScore)
        .reduce((a, b) => a + b) ~/ weekHistory.length;

    buffer.writeln(
      'Weekly averages: Study $avgStudy/100, '
      'Focus $avgFocus/100, Distraction $avgDistraction/100.',
    );

    // Trend detection
    if (weekHistory.length >= 3) {
      final firstHalf = weekHistory.sublist(0, weekHistory.length ~/ 2);
      final secondHalf = weekHistory.sublist(weekHistory.length ~/ 2);

      final firstAvg = firstHalf
          .map((a) => a.studyScore)
          .reduce((a, b) => a + b) ~/ firstHalf.length;
      final secondAvg = secondHalf
          .map((a) => a.studyScore)
          .reduce((a, b) => a + b) ~/ secondHalf.length;

      if (secondAvg > firstAvg + 5) {
        buffer.writeln('📈 Study performance is improving over the week!');
      } else if (secondAvg < firstAvg - 5) {
        buffer.writeln('📉 Study performance has declined. Consider a check-in.');
      } else {
        buffer.writeln('➡️ Study performance has been consistent this week.');
      }
    }

    // Best day
    final bestDay = weekHistory.reduce(
        (a, b) => a.studyScore > b.studyScore ? a : b);
    buffer.writeln('Best study day: ${bestDay.date} (score: ${bestDay.studyScore}).');

    // Total screen time
    final totalScreenTime = weekHistory
        .map((a) => a.totalScreenTime)
        .reduce((a, b) => a + b);
    final avgDailyScreen = totalScreenTime ~/ weekHistory.length;
    buffer.writeln(
      'Average daily screen time: ${DurationUtils.formatMinutes(avgDailyScreen)}.',
    );

    return buffer.toString().trim();
  }
}
