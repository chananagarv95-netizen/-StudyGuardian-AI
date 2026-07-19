import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared/utils/duration_utils.dart';
import 'package:shared/models/app_usage_model.dart';
import '../../../core/di/providers.dart';
import '../../../core/utils/extensions.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/animated_stat_card.dart';
import '../../widgets/status_indicator.dart';
import '../../widgets/battery_indicator.dart';
import '../../widgets/score_gauge.dart';
import '../../widgets/section_header.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/charts/usage_bar_chart.dart';

/// Main dashboard screen — the heart of the parent app.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceId = ref.watch(activeDeviceProvider);
    final statusAsync = ref.watch(deviceStatusStreamProvider);
    final devicesAsync = ref.watch(devicesProvider);
    final unreadCount = ref.watch(unreadCountProvider);
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final usageAsync = ref.watch(dailyUsageProvider(today));
    final analyticsAsync = ref.watch(studyAnalyticsProvider(today));

    return Scaffold(
      appBar: AppBar(
        title: const Text('StudyGuardian AI', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          // Device selector
          devicesAsync.when(
            data: (devices) {
              if (devices.isEmpty) return const SizedBox.shrink();
              return PopupMenuButton<String>(
                icon: const Icon(Icons.tablet_android),
                tooltip: 'Select Device',
                onSelected: (id) => ref.read(selectedDeviceIdProvider.notifier).state = id,
                itemBuilder: (_) => devices.map((d) => PopupMenuItem(
                  value: d.id,
                  child: Row(
                    children: [
                      StatusIndicator(isOnline: d.isOnline, size: 8),
                      const SizedBox(width: 8),
                      Text(d.deviceName),
                    ],
                  ),
                )).toList(),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          // Notification bell
          IconButton(
            icon: Badge(
              isLabelVisible: unreadCount > 0,
              label: Text('$unreadCount'),
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () => context.push('/notifications'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: deviceId == null
          ? _buildNoPairedDevice(context)
          : RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(deviceStatusStreamProvider);
                ref.invalidate(dailyUsageProvider(today));
                ref.invalidate(studyAnalyticsProvider(today));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Device Status Header
                    _buildStatusHeader(context, ref, statusAsync, devicesAsync),
                    const SizedBox(height: 16),

                    // Section 2: Quick Stats Grid
                    _buildQuickStats(context, statusAsync, usageAsync, analyticsAsync),
                    const SizedBox(height: 16),

                    // Section 3: Study Progress
                    _buildStudyProgress(context, analyticsAsync),
                    const SizedBox(height: 16),

                    // Section 4: Device Health
                    _buildDeviceHealth(context, statusAsync),
                    const SizedBox(height: 16),

                    // Section 5: Today's Top Apps
                    _buildTopApps(context, ref, usageAsync),
                    const SizedBox(height: 16),

                    // Section 6: Quick Actions
                    _buildQuickActions(context, ref, today),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildNoPairedDevice(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.devices, size: 80, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
          const SizedBox(height: 24),
          Text('No Device Paired', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Pair a child device to start monitoring', style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.push('/pairing'),
            icon: const Icon(Icons.qr_code),
            label: const Text('Pair Device'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(BuildContext context, WidgetRef ref, dynamic statusAsync, dynamic devicesAsync) {
    return statusAsync.when(
      data: (status) {
        if (status == null) return const ShimmerCard(height: 100);
        final device = devicesAsync.valueOrNull?.firstOrNull;
        return GlassCard(
          gradientColors: [
            const Color(0xFF6366F1).withValues(alpha: 0.15),
            const Color(0xFF8B5CF6).withValues(alpha: 0.08),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(device?.deviceName ?? 'Child Device',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(device?.model ?? '', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      StatusIndicator(isOnline: device?.isOnline ?? false),
                      const SizedBox(width: 8),
                      Text(device?.isOnline == true ? 'Online' : 'Offline',
                          style: TextStyle(
                            color: device?.isOnline == true ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            fontWeight: FontWeight.w600, fontSize: 13,
                          )),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  BatteryIndicator(percentage: status.battery, isCharging: status.isCharging),
                  const Spacer(),
                  if (status.updatedAt != null)
                    Text('Updated ${status.updatedAt!.timeAgo}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4))),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const ShimmerCard(height: 100),
      error: (_, __) => const ShimmerCard(height: 100),
    );
  }

  Widget _buildQuickStats(BuildContext context, dynamic statusAsync, dynamic usageAsync, dynamic analyticsAsync) {
    final status = statusAsync.valueOrNull;
    final usage = usageAsync.valueOrNull;
    final analytics = analyticsAsync.valueOrNull;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.35,
      children: [
        AnimatedStatCard(
          icon: Icons.phone_android,
          label: 'Screen Time',
          value: DurationUtils.formatDuration(usage?.totalScreenTime ?? 0),
          color: Colors.blue,
          index: 0,
        ),
        AnimatedStatCard(
          icon: Icons.school,
          label: 'Study Time',
          value: DurationUtils.formatDuration(analytics?.educationTime ?? 0),
          color: const Color(0xFF10B981),
          index: 1,
        ),
        AnimatedStatCard(
          icon: Icons.emoji_events,
          label: 'Study Score',
          value: '${analytics?.studyScore ?? 0}/100',
          color: const Color(0xFFF59E0B),
          index: 2,
        ),
        AnimatedStatCard(
          icon: Icons.lock_open,
          label: 'Unlocks',
          value: '${usage?.unlockCount ?? 0}',
          color: const Color(0xFF8B5CF6),
          index: 3,
        ),
        AnimatedStatCard(
          icon: Icons.apps,
          label: 'Current App',
          value: status?.foregroundApp?.split('.')?.last ?? 'None',
          color: const Color(0xFF14B8A6),
          index: 4,
        ),
        AnimatedStatCard(
          icon: status?.wifiConnected == true ? Icons.wifi : Icons.wifi_off,
          label: 'WiFi',
          value: status?.wifiConnected == true ? (status?.wifiSSID ?? 'Connected') : 'Disconnected',
          color: const Color(0xFF06B6D4),
          index: 5,
        ),
      ],
    );
  }

  Widget _buildStudyProgress(BuildContext context, dynamic analyticsAsync) {
    final analytics = analyticsAsync.valueOrNull;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Study Progress', padding: EdgeInsets.zero),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ScoreGauge(score: analytics?.studyScore ?? 0, label: 'Study', color: const Color(0xFF10B981), size: 85),
              ScoreGauge(score: analytics?.focusScore ?? 0, label: 'Focus', color: const Color(0xFF6366F1), size: 85),
              ScoreGauge(score: analytics?.distractionScore ?? 0, label: 'Distract', color: const Color(0xFFEF4444), size: 85),
            ],
          ),
          if (analytics?.aiSummary != null && analytics!.aiSummary.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.15)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(analytics.aiSummary,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                          height: 1.4,
                        )),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeviceHealth(BuildContext context, dynamic statusAsync) {
    final status = statusAsync.valueOrNull;
    if (status == null) return const ShimmerCard(height: 130);

    return SizedBox(
      height: 130,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _healthCard(context, Icons.battery_std, 'Battery',
              '${status.battery}%', 'Temp: ${status.temperature.toStringAsFixed(1)}°C',
              status.isCharging ? const Color(0xFF10B981) : const Color(0xFFF59E0B)),
          _healthCard(context, Icons.storage, 'Storage',
              '${(status.storageUsed / 1073741824).toStringAsFixed(1)} GB',
              'of ${(status.storageTotal / 1073741824).toStringAsFixed(0)} GB',
              const Color(0xFF6366F1)),
          _healthCard(context, Icons.memory, 'RAM',
              '${(status.ramUsed / 1073741824).toStringAsFixed(1)} GB',
              'of ${(status.ramTotal / 1073741824).toStringAsFixed(1)} GB',
              const Color(0xFF8B5CF6)),
          _healthCard(context, Icons.wifi, 'Network',
              status.wifiSSID.isNotEmpty ? status.wifiSSID : 'N/A',
              status.networkType,
              const Color(0xFF14B8A6)),
        ],
      ),
    );
  }

  Widget _healthCard(BuildContext context, IconData icon, String title, String value, String subtitle, Color color) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopApps(BuildContext context, WidgetRef ref, dynamic usageAsync) {
    final usage = usageAsync.valueOrNull;
    final List<AppUsageModel> apps = (usage?.apps as List<AppUsageModel>?) ?? [];
    final sorted = List<AppUsageModel>.of(apps)..sort((a, b) => b.foregroundTime.compareTo(a.foregroundTime));
    final top5 = sorted.take(5).toList();

    return Column(
      children: [
        SectionHeader(title: "Today's Top Apps", actionText: 'View All', onAction: () => context.go('/usage')),
        if (top5.isEmpty)
          const GlassCard(child: Center(child: Text('No usage data yet')))
        else
          GlassCard(child: TopAppsBarChart(apps: top5, height: 180)),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref, String today) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _actionButton(context, Icons.refresh, 'Refresh', () {
          ref.invalidate(deviceStatusStreamProvider);
          ref.invalidate(dailyUsageProvider(today));
        }),
        _actionButton(context, Icons.assessment, 'Reports', () => context.go('/reports')),
        _actionButton(context, Icons.auto_awesome, 'Coach', () => context.push('/study-coach')),
        _actionButton(context, Icons.category_outlined, 'Categories', () => context.push('/category-usage')),
        _actionButton(context, Icons.notifications_outlined, 'Alerts', () => context.push('/notifications')),
      ],
    );
  }

  Widget _actionButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF6366F1)),
          ),
          const SizedBox(height: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
