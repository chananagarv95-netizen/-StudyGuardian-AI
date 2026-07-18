import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/providers.dart';

/// Child app home screen displaying monitoring status and key stats.
///
/// Displays: Study Time, Battery, Sync Status, Device Status, Current Goal.
/// Does NOT allow changing settings or disabling monitoring.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyAsync = ref.watch(familyProvider);
    final isForegroundRunning =
        ref.watch(foregroundServiceProvider).valueOrNull ?? false;
    final deviceStatusAsync = ref.watch(localDeviceStatusProvider);
    final deviceAsync = ref.watch(deviceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('StudyGuardian'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Monitoring Status Banner ─────────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isForegroundRunning
                      ? [
                          const Color(0xFF10B981).withValues(alpha: 0.2),
                          const Color(0xFF059669).withValues(alpha: 0.1),
                        ]
                      : [
                          const Color(0xFFEF4444).withValues(alpha: 0.2),
                          const Color(0xFFDC2626).withValues(alpha: 0.1),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: (isForegroundRunning
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444))
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    isForegroundRunning
                        ? Icons.shield_rounded
                        : Icons.shield_outlined,
                    size: 64,
                    color: isForegroundRunning
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isForegroundRunning
                        ? 'Monitoring Active'
                        : 'Monitoring Stopped',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isForegroundRunning
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isForegroundRunning
                        ? 'Your device is connected and protected.'
                        : 'Please ensure permissions are granted.',
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ─── Quick Stats Grid ─────────────────────────────────────
            deviceStatusAsync.when(
              data: (status) {
                final battery = status['battery'] as int? ?? 0;
                final isCharging = status['isCharging'] as bool? ?? false;
                final networkType = status['networkType'] as String? ?? 'Unknown';
                final storageUsed = status['storageUsed'] as int? ?? 0;
                final storageTotal = status['storageTotal'] as int? ?? 1;
                final storagePercent =
                    ((storageUsed / storageTotal) * 100).round();

                return GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.5,
                  children: [
                    _StatCard(
                      icon: Icons.battery_charging_full,
                      iconColor: battery < 20
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF10B981),
                      label: 'Battery',
                      value: '$battery%',
                      subtitle: isCharging ? 'Charging' : 'Not Charging',
                    ),
                    _StatCard(
                      icon: Icons.wifi,
                      iconColor: const Color(0xFF6366F1),
                      label: 'Network',
                      value: networkType,
                      subtitle: 'Connection',
                    ),
                    _StatCard(
                      icon: Icons.storage,
                      iconColor: const Color(0xFFF59E0B),
                      label: 'Storage',
                      value: '$storagePercent%',
                      subtitle: 'Used',
                    ),
                    _StatCard(
                      icon: Icons.sync,
                      iconColor: const Color(0xFF14B8A6),
                      label: 'Sync',
                      value: deviceAsync.when(
                        data: (d) => d != null
                            ? d.performanceMode.displayName
                            : 'N/A',
                        loading: () => '...',
                        error: (_, __) => 'N/A',
                      ),
                      subtitle: deviceAsync.when(
                        data: (d) => d?.lastSeen != null
                            ? _timeAgo(d!.lastSeen)
                            : 'Never',
                        loading: () => '...',
                        error: (_, __) => 'Error',
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (_, __) => const Center(
                child: Text(
                  'Unable to read device status',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ─── Connection Status Card ───────────────────────────────
            Card(
              elevation: 0,
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    familyAsync.when(
                      data: (family) => _StatusRow(
                        icon: Icons.family_restroom,
                        title: 'Family',
                        value: family?.name ?? 'Not Connected',
                        isOk: family != null,
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, __) => const _StatusRow(
                        icon: Icons.error,
                        title: 'Family',
                        value: 'Error',
                        isOk: false,
                      ),
                    ),
                    const Divider(height: 32, color: Colors.white10),
                    _StatusRow(
                      icon: Icons.monitor_heart,
                      title: 'Service',
                      value: isForegroundRunning ? 'Running' : 'Stopped',
                      isOk: isForegroundRunning,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isOk;

  const _StatusRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.isOk,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Text(title, style: const TextStyle(fontSize: 16)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isOk
                ? Colors.green.withValues(alpha: 0.2)
                : Colors.red.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: isOk ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
