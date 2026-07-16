import 'package:flutter_test/flutter_test.dart';
import 'package:shared/utils/app_classifier.dart';
import 'package:shared/models/app_category.dart';

void main() {
  group('AppClassifier', () {
    // ── Known apps (exact lookup) ──────────────────────────────────────

    group('known apps classification', () {
      test('classifies Duolingo as education', () {
        expect(
          AppClassifier.classifyApp('com.duolingo', 'Duolingo'),
          AppCategory.education,
        );
      });

      test('classifies Instagram as socialMedia', () {
        expect(
          AppClassifier.classifyApp('com.instagram.android', 'Instagram'),
          AppCategory.socialMedia,
        );
      });

      test('classifies WhatsApp as communication', () {
        expect(
          AppClassifier.classifyApp('com.whatsapp', 'WhatsApp'),
          AppCategory.communication,
        );
      });

      test('classifies YouTube as entertainment', () {
        expect(
          AppClassifier.classifyApp(
              'com.google.android.youtube', 'YouTube'),
          AppCategory.entertainment,
        );
      });

      test('classifies Khan Academy as education', () {
        expect(
          AppClassifier.classifyApp(
              'com.khanacademy.android', 'Khan Academy'),
          AppCategory.education,
        );
      });
    });

    // ── Unknown apps (keyword fallback) ─────────────────────────────────

    group('keyword-based classification', () {
      test('classifies app with "learn" in name as education', () {
        expect(
          AppClassifier.classifyApp(
              'com.unknown.pkg', 'LearnMaths'),
          AppCategory.education,
        );
      });

      test('classifies app with "game" in name as games', () {
        expect(
          AppClassifier.classifyApp('com.unknown.pkg', 'SuperGame'),
          AppCategory.games,
        );
      });

      test('classifies app with "shop" in name as shopping', () {
        expect(
          AppClassifier.classifyApp(
              'com.unknown.pkg', 'QuickShop'),
          AppCategory.shopping,
        );
      });

      test('classifies totally unknown app as others', () {
        expect(
          AppClassifier.classifyApp(
              'com.totally.unknown.xyz', 'XYZApp'),
          AppCategory.others,
        );
      });
    });

    // ── AppCategory properties ──────────────────────────────────────────

    group('AppCategory properties', () {
      test('education is productive', () {
        expect(AppCategory.education.isProductive, isTrue);
      });

      test('productivity is productive', () {
        expect(AppCategory.productivity.isProductive, isTrue);
      });

      test('games is distracting', () {
        expect(AppCategory.games.isDistracting, isTrue);
      });

      test('entertainment is distracting', () {
        expect(AppCategory.entertainment.isDistracting, isTrue);
      });

      test('socialMedia is distracting', () {
        expect(AppCategory.socialMedia.isDistracting, isTrue);
      });

      test('others is neither productive nor distracting', () {
        expect(AppCategory.others.isProductive, isFalse);
        expect(AppCategory.others.isDistracting, isFalse);
      });
    });
  });
}
