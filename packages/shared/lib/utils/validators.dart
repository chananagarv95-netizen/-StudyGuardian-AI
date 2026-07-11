/// Provides static form validation methods for common input fields.
///
/// Each validator returns `null` if the input is valid, or a human-readable
/// error message [String] if validation fails. This matches the convention
/// used by Flutter's [TextFormField.validator].
class Validators {
  Validators._();

  /// Email validation regex pattern.
  ///
  /// Matches standard email formats: `user@domain.tld`
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*\.[a-zA-Z]{2,}$',
  );

  /// Alphanumeric validation regex pattern.
  static final RegExp _alphanumericRegExp = RegExp(r'^[a-zA-Z0-9]+$');

  /// Validates an email address.
  ///
  /// Returns:
  /// - `'Email is required'` if [email] is null or empty.
  /// - `'Please enter a valid email address'` if the format is invalid.
  /// - `null` if the email is valid.
  static String? isValidEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email is required';
    }

    if (!_emailRegExp.hasMatch(email.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validates a password.
  ///
  /// Returns:
  /// - `'Password is required'` if [password] is null or empty.
  /// - `'Password must be at least 6 characters'` if too short.
  /// - `null` if the password is valid.
  static String? isValidPassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  /// Validates a device pairing code.
  ///
  /// A valid pairing code is exactly 6 alphanumeric characters.
  ///
  /// Returns:
  /// - `'Pairing code is required'` if [code] is null or empty.
  /// - `'Pairing code must be 6 characters'` if not exactly 6 characters.
  /// - `'Pairing code must be alphanumeric'` if it contains non-alphanumeric characters.
  /// - `null` if the pairing code is valid.
  static String? isValidPairingCode(String? code) {
    if (code == null || code.trim().isEmpty) {
      return 'Pairing code is required';
    }

    final String trimmed = code.trim();

    if (trimmed.length != 6) {
      return 'Pairing code must be 6 characters';
    }

    if (!_alphanumericRegExp.hasMatch(trimmed)) {
      return 'Pairing code must be alphanumeric';
    }

    return null;
  }

  /// Validates a user display name.
  ///
  /// Returns:
  /// - `'Display name is required'` if [name] is null or empty.
  /// - `'Display name must be at least 2 characters'` if too short.
  /// - `'Display name must not exceed 50 characters'` if too long.
  /// - `null` if the display name is valid.
  static String? isValidDisplayName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Display name is required';
    }

    final String trimmed = name.trim();

    if (trimmed.length < 2) {
      return 'Display name must be at least 2 characters';
    }

    if (trimmed.length > 50) {
      return 'Display name must not exceed 50 characters';
    }

    return null;
  }
}
