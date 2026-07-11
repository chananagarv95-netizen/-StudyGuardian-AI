import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/models/notification_model.dart';
import '../../../core/di/providers.dart';
import '../../../core/utils/extensions.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/empty_state.dart';

/// Notifications screen with real-time list.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications'), centerTitle: true),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const EmptyState(icon: Icons.notifications_none, title: 'No Notifications', subtitle: 'You\'ll see alerts about the monitored device here');
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return GlassCard(
                onTap: () async {
                  if (!notif.read) {
                    final family = ref.read(familyProvider).valueOrNull;
                    if (family != null) {
                      await ref.read(firestoreServiceProvider).markNotificationAsRead(family.id, notif.id);
                    }
                  }
                },
                gradientColors: !notif.read
                    ? [const Color(0xFF6366F1).withValues(alpha: 0.1), Colors.transparent]
                    : null,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _typeColor(notif.type).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_typeIcon(notif.type), color: _typeColor(notif.type), size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(notif.title,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: notif.read ? FontWeight.normal : FontWeight.bold))),
                              if (!notif.read)
                                Container(width: 8, height: 8,
                                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF6366F1))),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(notif.body, style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                          const SizedBox(height: 6),
                          Text(notif.timestamp.timeAgo, style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3), fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _typeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.batteryLow: return Icons.battery_alert;
      case NotificationType.batteryFull: return Icons.battery_full;
      case NotificationType.deviceOffline: return Icons.wifi_off;
      case NotificationType.deviceOnline: return Icons.wifi;
      case NotificationType.newAppInstalled: return Icons.app_registration;
      case NotificationType.studyGoalAchieved: return Icons.emoji_events;
      case NotificationType.dailyReportReady: return Icons.assessment;
      case NotificationType.tabletRestarted: return Icons.restart_alt;
      case NotificationType.appRemoved: return Icons.delete;
    }
  }

  Color _typeColor(NotificationType type) {
    switch (type) {
      case NotificationType.batteryLow: return const Color(0xFFEF4444);
      case NotificationType.batteryFull: return const Color(0xFF10B981);
      case NotificationType.deviceOffline: return const Color(0xFFEF4444);
      case NotificationType.deviceOnline: return const Color(0xFF10B981);
      case NotificationType.newAppInstalled: return const Color(0xFF6366F1);
      case NotificationType.studyGoalAchieved: return const Color(0xFFF59E0B);
      case NotificationType.dailyReportReady: return const Color(0xFF14B8A6);
      case NotificationType.tabletRestarted: return const Color(0xFFF59E0B);
      case NotificationType.appRemoved: return const Color(0xFFEF4444);
    }
  }
}
