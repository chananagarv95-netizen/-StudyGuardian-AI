import 'dart:math' as math;

/// Calculates various study and productivity scores based on app usage data.
///
/// All scores are integers in the range 0–100 (inclusive) unless otherwise noted.
/// Division-by-zero and edge cases are handled gracefully.
class StudyScoreCalculator {
  StudyScoreCalculator._();

  /// Calculates the study score based on the ratio of educational screen time
  /// to total screen time.
  ///
  /// - [educationMinutes]: Minutes spent in educational apps.
  /// - [totalScreenTime]: Total minutes of device screen time.
  ///
  /// Returns `0` if [totalScreenTime] is zero.
  /// Result is clamped to the range `[0, 100]`.
  ///
  /// Formula: `(educationMinutes / totalScreenTime * 100).round()`
  static int calculateStudyScore(int educationMinutes, int totalScreenTime) {
    if (totalScreenTime <= 0) return 0;

    final double ratio = educationMinutes / totalScreenTime;
    final int score = (ratio * 100).round();
    return score.clamp(0, 100);
  }

  /// Calculates a focus score based on app-switching frequency and
  /// social media usage relative to total screen time.
  ///
  /// - [appSwitchCount]: Number of times the user switched between apps.
  /// - [socialMediaMinutes]: Minutes spent on social media apps.
  /// - [totalMinutes]: Total screen time in minutes.
  ///
  /// Lower app switches and less social media usage yield a higher focus score.
  ///
  /// Formula:
  /// ```
  /// switchPenalty = min(appSwitchCount * 2, 50)
  /// socialPenalty = totalMinutes > 0
  ///     ? min((socialMediaMinutes / totalMinutes * 50).round(), 50)
  ///     : 0
  /// score = 100 - switchPenalty - socialPenalty
  /// ```
  ///
  /// Result is clamped to the range `[0, 100]`.
  static int calculateFocusScore(
    int appSwitchCount,
    int socialMediaMinutes,
    int totalMinutes,
  ) {
    final int switchPenalty = math.min(appSwitchCount * 2, 50);

    final int socialPenalty = totalMinutes > 0
        ? math.min((socialMediaMinutes / totalMinutes * 50).round(), 50)
        : 0;

    final int score = 100 - switchPenalty - socialPenalty;
    return score.clamp(0, 100);
  }

  /// Calculates a distraction score representing the proportion of screen time
  /// spent on distracting apps (entertainment, social media, and games).
  ///
  /// - [entertainmentMins]: Minutes spent on entertainment apps.
  /// - [socialMediaMins]: Minutes spent on social media apps.
  /// - [gameMins]: Minutes spent on gaming apps.
  /// - [totalMins]: Total screen time in minutes.
  ///
  /// A higher score means more distracted usage.
  ///
  /// Returns `0` if [totalMins] is zero.
  /// Result is clamped to the range `[0, 100]`.
  ///
  /// Formula: `((entertainmentMins + socialMediaMins + gameMins) / totalMins * 100).round()`
  static int calculateDistractionScore(
    int entertainmentMins,
    int socialMediaMins,
    int gameMins,
    int totalMins,
  ) {
    if (totalMins <= 0) return 0;

    final int distractingTime = entertainmentMins + socialMediaMins + gameMins;
    final double ratio = distractingTime / totalMins;
    final int score = (ratio * 100).round();
    return score.clamp(0, 100);
  }

  /// Calculates a productivity percentage based on the proportion of
  /// educational time relative to all tracked category time.
  ///
  /// - [educationMins]: Minutes spent on education apps.
  /// - [entertainmentMins]: Minutes spent on entertainment apps.
  /// - [gameMins]: Minutes spent on gaming apps.
  /// - [socialMins]: Minutes spent on social media apps.
  ///
  /// Returns `0.0` if total tracked time is zero.
  /// Result is clamped to `[0.0, 100.0]` and rounded to 1 decimal place.
  ///
  /// Formula: `educationMins / totalTracked * 100`
  static double calculateProductivity(
    int educationMins,
    int entertainmentMins,
    int gameMins,
    int socialMins,
  ) {
    final int totalTracked =
        educationMins + entertainmentMins + gameMins + socialMins;

    if (totalTracked <= 0) return 0.0;

    final double productivity = educationMins / totalTracked * 100;
    final double clamped = productivity.clamp(0.0, 100.0);
    return double.parse(clamped.toStringAsFixed(1));
  }

  /// Calculates a weighted overall score from the component scores.
  ///
  /// - [studyScore]: The study score (0–100).
  /// - [focusScore]: The focus score (0–100).
  /// - [distractionScore]: The distraction score (0–100). Internally inverted
  ///   so that lower distraction yields a higher overall score.
  ///
  /// Formula:
  /// ```
  /// overall = studyScore * 0.4 + focusScore * 0.3 + (100 - distractionScore) * 0.3
  /// ```
  ///
  /// Result is clamped to the range `[0, 100]`.
  static int calculateOverallScore(
    int studyScore,
    int focusScore,
    int distractionScore,
  ) {
    final double overall = studyScore * 0.4 +
        focusScore * 0.3 +
        (100 - distractionScore) * 0.3;

    return overall.round().clamp(0, 100);
  }
}
