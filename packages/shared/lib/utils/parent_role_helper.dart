import 'package:shared/models/user_model.dart';

/// Static utility providing role-based permission checks for parent users.
///
/// The primary parent has full administrative control.
/// The secondary parent has limited permissions focused on viewing data
/// and sending reminders.
class ParentRoleHelper {
  ParentRoleHelper._();

  // ═══════════════════════════════════════════════════════════════════════════
  // Primary-only actions
  // ═══════════════════════════════════════════════════════════════════════════

  /// Whether the parent can remove a paired child device.
  static bool canRemoveDevice(ParentRole? role) =>
      role == ParentRole.primary;

  /// Whether the parent can reset the Parent PIN.
  static bool canResetPin(ParentRole? role) =>
      role == ParentRole.primary;

  /// Whether the parent can remove another parent from the family.
  static bool canRemoveParent(ParentRole? role) =>
      role == ParentRole.primary;

  /// Whether the parent can modify family settings (notifications,
  /// study schedule, monitoring configuration).
  static bool canChangeSettings(ParentRole? role) =>
      role == ParentRole.primary;

  /// Whether the parent can delete project data or the family.
  static bool canDeleteData(ParentRole? role) =>
      role == ParentRole.primary;

  /// Whether the parent can add or remove secondary parents.
  static bool canManageParents(ParentRole? role) =>
      role == ParentRole.primary;

  /// Whether the parent can change the child device's performance mode.
  static bool canChangePerformanceMode(ParentRole? role) =>
      role == ParentRole.primary;

  /// Whether the parent can configure the study schedule.
  static bool canConfigureStudySchedule(ParentRole? role) =>
      role == ParentRole.primary;

  /// Whether the parent can configure notification preferences.
  static bool canConfigureNotifications(ParentRole? role) =>
      role == ParentRole.primary;

  /// Whether the parent can change Firebase configuration.
  static bool canChangeFirebaseConfig(ParentRole? role) =>
      role == ParentRole.primary;

  /// Whether the parent can reset reports.
  static bool canResetReports(ParentRole? role) =>
      role == ParentRole.primary;

  // ═══════════════════════════════════════════════════════════════════════════
  // Both primary and secondary can perform these
  // ═══════════════════════════════════════════════════════════════════════════

  /// Whether the parent can lock the child device (if supported).
  static bool canLockDevice(ParentRole? role) =>
      role == ParentRole.primary || role == ParentRole.secondary;

  /// Whether the parent can ring the child device.
  static bool canRingDevice(ParentRole? role) =>
      role == ParentRole.primary || role == ParentRole.secondary;

  /// Whether the parent can send study reminders.
  static bool canSendReminder(ParentRole? role) =>
      role == ParentRole.primary || role == ParentRole.secondary;

  /// Whether the parent can generate and view reports.
  static bool canGenerateReports(ParentRole? role) =>
      role == ParentRole.primary || role == ParentRole.secondary;

  /// Whether the parent can view monitoring information.
  static bool canViewMonitoringData(ParentRole? role) =>
      role == ParentRole.primary || role == ParentRole.secondary;

  /// Whether the parent can receive notifications.
  static bool canReceiveNotifications(ParentRole? role) =>
      role == ParentRole.primary || role == ParentRole.secondary;

  // ═══════════════════════════════════════════════════════════════════════════
  // Convenience
  // ═══════════════════════════════════════════════════════════════════════════

  /// Returns a human-readable list of actions this role can perform.
  static List<String> permissionsFor(ParentRole? role) {
    if (role == ParentRole.primary) {
      return [
        'Full administrative control',
        'Add/remove secondary parents',
        'Change every setting',
        'Reset Parent PIN',
        'Remove paired devices',
        'Configure study schedule',
        'Configure notifications',
        'Manage permissions',
        'View all monitoring information',
        'Generate reports',
        'Lock/ring device',
        'Send study reminders',
      ];
    }
    return [
      'View all monitoring information',
      'Receive notifications',
      'Generate reports',
      'Lock device (if supported)',
      'Ring device',
      'Send study reminders',
    ];
  }
}
