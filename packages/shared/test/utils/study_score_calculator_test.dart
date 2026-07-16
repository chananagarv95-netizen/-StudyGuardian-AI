import 'package:flutter_test/flutter_test.dart';
import 'package:shared/utils/study_score_calculator.dart';

void main() {
  group('StudyScoreCalculator', () {
    // ── calculateStudyScore ──────────────────────────────────────────────

    group('calculateStudyScore', () {
      test('returns 0 when totalScreenTime is 0', () {
        expect(StudyScoreCalculator.calculateStudyScore(60, 0), 0);
      });

      test('returns 100 when all time is educational', () {
        expect(StudyScoreCalculator.calculateStudyScore(120, 120), 100);
      });

      test('returns ~50 when half time is educational', () {
        expect(StudyScoreCalculator.calculateStudyScore(60, 120), 50);
      });

      test('returns 25 for quarter educational time', () {
        expect(StudyScoreCalculator.calculateStudyScore(30, 120), 25);
      });

      test('clamps to 100 if education exceeds total', () {
        expect(StudyScoreCalculator.calculateStudyScore(200, 100), 100);
      });
    });

    // ── calculateFocusScore ──────────────────────────────────────────────

    group('calculateFocusScore', () {
      test('returns 100 when no switches and no social media', () {
        expect(StudyScoreCalculator.calculateFocusScore(0, 0, 120), 100);
      });

      test('penalizes high app switching', () {
        final score = StudyScoreCalculator.calculateFocusScore(25, 0, 120);
        expect(score, 50); // 25 * 2 = 50 switch penalty, capped at 50
      });

      test('penalizes social media usage', () {
        final score = StudyScoreCalculator.calculateFocusScore(0, 60, 120);
        // socialPenalty = min((60/120*50).round(), 50) = 25
        expect(score, 75);
      });

      test('returns 100 when totalMinutes is 0', () {
        expect(StudyScoreCalculator.calculateFocusScore(0, 0, 0), 100);
      });

      test('clamps to 0 for extreme penalties', () {
        final score = StudyScoreCalculator.calculateFocusScore(50, 120, 120);
        expect(score, 0);
      });
    });

    // ── calculateDistractionScore ────────────────────────────────────────

    group('calculateDistractionScore', () {
      test('returns 0 when totalMins is 0', () {
        expect(StudyScoreCalculator.calculateDistractionScore(0, 0, 0, 0), 0);
      });

      test('returns 0 when no distracting time', () {
        expect(
            StudyScoreCalculator.calculateDistractionScore(0, 0, 0, 120), 0);
      });

      test('returns 100 when all time is distracting', () {
        expect(
            StudyScoreCalculator.calculateDistractionScore(40, 40, 40, 120),
            100);
      });

      test('returns 50 when half time is distracting', () {
        expect(
            StudyScoreCalculator.calculateDistractionScore(20, 20, 20, 120),
            50);
      });
    });

    // ── calculateProductivity ────────────────────────────────────────────

    group('calculateProductivity', () {
      test('returns 0.0 when all categories are 0', () {
        expect(StudyScoreCalculator.calculateProductivity(0, 0, 0, 0), 0.0);
      });

      test('returns 100.0 when only education time', () {
        expect(
            StudyScoreCalculator.calculateProductivity(120, 0, 0, 0), 100.0);
      });

      test('returns 50.0 when half education', () {
        expect(
            StudyScoreCalculator.calculateProductivity(60, 30, 15, 15), 50.0);
      });
    });

    // ── calculateOverallScore ────────────────────────────────────────────

    group('calculateOverallScore', () {
      test('returns weighted average of scores', () {
        // study*0.4 + focus*0.3 + (100-distraction)*0.3
        // 100*0.4 + 100*0.3 + (100-0)*0.3 = 40 + 30 + 30 = 100
        expect(StudyScoreCalculator.calculateOverallScore(100, 100, 0), 100);
      });

      test('returns 0 for worst case', () {
        // 0*0.4 + 0*0.3 + (100-100)*0.3 = 0
        expect(StudyScoreCalculator.calculateOverallScore(0, 0, 100), 0);
      });

      test('handles mixed scores', () {
        // 80*0.4 + 60*0.3 + (100-40)*0.3 = 32 + 18 + 18 = 68
        expect(StudyScoreCalculator.calculateOverallScore(80, 60, 40), 68);
      });
    });
  });
}
