/// Performance mode controlling sync frequency and battery usage.\n///
/// The child device can operate in one of three modes, configurable
/// by the parent from the dashboard.
enum PerformanceMode {
  /// Sync every 30–60 minutes. Lowest battery usage.
  eco,

  /// Sync every 15 minutes. Default balanced mode.
  balanced,

  /// Sync every 1–5 minutes. Temporary mode that auto-disables
  /// after a configurable duration (default: 1 hour).
  live;

  /// Human-readable display name.
  String get displayName {
    switch (this) {
      case PerformanceMode.eco:
        return 'Eco Mode';
      case PerformanceMode.balanced:
        return 'Balanced';
      case PerformanceMode.live:
        return 'Live Mode';
    }
  }

  /// Short description of the mode's behavior.
  String get description {
    switch (this) {
      case PerformanceMode.eco:
        return 'Syncs every 30–60 min. Lowest battery usage.';
      case PerformanceMode.balanced:
        return 'Syncs every 15 min. Recommended for daily use.';
      case PerformanceMode.live:
        return 'Syncs every 1–5 min. Auto-disables after 1 hour.';
    }
  }

  /// The sync interval for this mode.
  Duration get syncInterval {
    switch (this) {
      case PerformanceMode.eco:
        return const Duration(minutes: 60);
      case PerformanceMode.balanced:
        return const Duration(minutes: 15);
      case PerformanceMode.live:
        return const Duration(minutes: 3);
    }
  }

  /// Whether this mode is temporary and should auto-disable.
  bool get isTemporary => this == PerformanceMode.live;

  /// Default auto-disable duration for temporary modes.
  Duration get autoDisableAfter => const Duration(hours: 1);

  /// Parses a [String] into a [PerformanceMode].
  /// Returns [PerformanceMode.balanced] if the value is unrecognized.
  static PerformanceMode fromString(String? value) {
    switch (value) {
      case 'eco':
        return PerformanceMode.eco;
      case 'live':
        return PerformanceMode.live;
      case 'balanced':
      default:
        return PerformanceMode.balanced;
    }
  }
}
