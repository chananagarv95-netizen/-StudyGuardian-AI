import 'package:flutter_test/flutter_test.dart';
import 'package:shared/utils/validators.dart';

void main() {
  group('Validators', () {
    // ── isValidEmail ─────────────────────────────────────────────────────

    group('isValidEmail', () {
      test('returns null for a valid email', () {
        expect(Validators.isValidEmail('test@example.com'), isNull);
      });

      test('returns null for email with subdomains', () {
        expect(Validators.isValidEmail('user@mail.example.co.uk'), isNull);
      });

      test('returns error for null', () {
        expect(Validators.isValidEmail(null), isNotNull);
      });

      test('returns error for empty string', () {
        expect(Validators.isValidEmail(''), isNotNull);
      });

      test('returns error for invalid format', () {
        expect(Validators.isValidEmail('notanemail'), isNotNull);
      });

      test('returns error for missing domain', () {
        expect(Validators.isValidEmail('user@'), isNotNull);
      });
    });

    // ── isValidPassword ──────────────────────────────────────────────────

    group('isValidPassword', () {
      test('returns null for valid password (6+ chars)', () {
        expect(Validators.isValidPassword('abc123'), isNull);
      });

      test('returns error for null', () {
        expect(Validators.isValidPassword(null), isNotNull);
      });

      test('returns error for empty string', () {
        expect(Validators.isValidPassword(''), isNotNull);
      });

      test('returns error for too short password', () {
        expect(Validators.isValidPassword('ab1'), isNotNull);
      });
    });

    // ── isValidPairingCode ───────────────────────────────────────────────

    group('isValidPairingCode', () {
      test('returns null for valid 6-char alphanumeric code', () {
        expect(Validators.isValidPairingCode('ABC123'), isNull);
      });

      test('returns error for null', () {
        expect(Validators.isValidPairingCode(null), isNotNull);
      });

      test('returns error for empty string', () {
        expect(Validators.isValidPairingCode(''), isNotNull);
      });

      test('returns error for too short code', () {
        expect(Validators.isValidPairingCode('AB'), isNotNull);
      });

      test('returns error for too long code', () {
        expect(Validators.isValidPairingCode('ABCDEFGH'), isNotNull);
      });

      test('returns error for non-alphanumeric characters', () {
        expect(Validators.isValidPairingCode('ABC-12'), isNotNull);
      });
    });

    // ── isValidDisplayName ───────────────────────────────────────────────

    group('isValidDisplayName', () {
      test('returns null for valid name', () {
        expect(Validators.isValidDisplayName('John'), isNull);
      });

      test('returns error for null', () {
        expect(Validators.isValidDisplayName(null), isNotNull);
      });

      test('returns error for empty string', () {
        expect(Validators.isValidDisplayName(''), isNotNull);
      });

      test('returns error for single character', () {
        expect(Validators.isValidDisplayName('A'), isNotNull);
      });

      test('returns error for name exceeding 50 characters', () {
        final longName = 'A' * 51;
        expect(Validators.isValidDisplayName(longName), isNotNull);
      });

      test('returns null for name at boundary (2 chars)', () {
        expect(Validators.isValidDisplayName('Jo'), isNull);
      });

      test('returns null for name at boundary (50 chars)', () {
        final maxName = 'A' * 50;
        expect(Validators.isValidDisplayName(maxName), isNull);
      });
    });
  });
}
