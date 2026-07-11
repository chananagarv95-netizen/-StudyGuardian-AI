import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../../../core/utils/extensions.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/battery_indicator.dart';

/// Device info screen showing hardware, battery, storage, RAM, network.
class DeviceInfoScreen extends ConsumerWidget {
  final String deviceId;
  const DeviceInfoScreen({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(deviceStatusStreamProvider);
    final devicesAsync = ref.watch(devicesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Device Info'), centerTitle: true),
      body: statusAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (status) {
          if (status == null) return const Center(child: Text('No device status'));
          final device = devicesAsync.valueOrNull?.where((d) => d.id == deviceId).firstOrNull;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Device info
                _section(context, Icons.phone_android, 'Device', [
                  _row(context, 'Name', device?.deviceName ?? 'Unknown'),
                  _row(context, 'Model', device?.model ?? 'Unknown'),
                  _row(context, 'Manufacturer', device?.manufacturer ?? 'Unknown'),
                  _row(context, 'Android', device?.androidVersion ?? 'Unknown'),
                  _row(context, 'Serial', device?.serialNumber ?? 'N/A'),
                ]),
                const SizedBox(height: 12),

                // Battery
                _section(context, Icons.battery_std, 'Battery', [
                  Row(children: [
                    const Text('Level'), const Spacer(),
                    BatteryIndicator(percentage: status.battery, isCharging: status.isCharging),
                  ]),
                  _row(context, 'Health', status.batteryHealth),
                  _row(context, 'Temperature', '${status.temperature.toStringAsFixed(1)}°C'),
                  _row(context, 'Charging', status.isCharging ? 'Yes' : 'No'),
                ]),
                const SizedBox(height: 12),

                // Storage
                _section(context, Icons.storage, 'Storage', [
                  _row(context, 'Used', status.storageUsed.formatBytes),
                  _row(context, 'Total', status.storageTotal.formatBytes),
                  _row(context, 'Free', (status.storageTotal - status.storageUsed).formatBytes),
                  _progressBar(context, status.storageUsed / status.storageTotal.clamp(1, double.infinity), const Color(0xFF6366F1)),
                ]),
                const SizedBox(height: 12),

                // RAM
                _section(context, Icons.memory, 'RAM', [
                  _row(context, 'Used', status.ramUsed.formatBytes),
                  _row(context, 'Total', status.ramTotal.formatBytes),
                  _progressBar(context, status.ramUsed / status.ramTotal.clamp(1, double.infinity), const Color(0xFF8B5CF6)),
                ]),
                const SizedBox(height: 12),

                // Network
                _section(context, Icons.wifi, 'Network', [
                  _row(context, 'WiFi', status.wifiConnected ? 'Connected' : 'Disconnected'),
                  _row(context, 'SSID', status.wifiSSID.isNotEmpty ? status.wifiSSID : 'N/A'),
                  _row(context, 'Type', status.networkType),
                  _row(context, 'Signal', '${status.signalStrength} dBm'),
                ]),
                const SizedBox(height: 12),

                // Status
                _section(context, Icons.info, 'Status', [
                  _row(context, 'Screen', status.screenOn ? 'On' : 'Off'),
                  _row(context, 'Foreground App', status.foregroundApp),
                  _row(context, 'Uptime', '${(status.deviceUptime / 3600).toStringAsFixed(1)} hours'),
                  if (status.lastUnlockTime != null)
                    _row(context, 'Last Unlock', status.lastUnlockTime!.timeAgo),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _section(BuildContext context, IconData icon, String title, List<Widget> children) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: const Color(0xFF6366F1), size: 20),
            const SizedBox(width: 8),
            Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          ]),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _progressBar(BuildContext context, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: value.clamp(0, 1),
          backgroundColor: color.withValues(alpha: 0.15),
          valueColor: AlwaysStoppedAnimation(color),
          minHeight: 6,
        ),
      ),
    );
  }
}
